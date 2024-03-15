import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lurkur/app/secrets.dart' as secrets;
import 'package:uuid/uuid.dart';

extension BuildContextXAuthCubit on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();

  AuthCubit get watchAuthCubit => watch<AuthCubit>();
}

/// Manages the user's authorization session.
class AuthCubit extends Cubit<AuthState> {
  static const clientId = secrets.clientId;
  static const redirectUri = 'https://www.reddit.com';

  AuthCubit() : super(const Unauthorized());

  final _storage = _AuthStorage();

  /// Spins up this auth cubit and begins checking storage for previously
  /// acquired tokens.
  ///
  /// If the stored tokens are still valid,
  void initialize() async {
    emit(const CheckingAuthorization());

    final accessToken = await _storage.accessToken;
    final expirationTime = await _storage.expirationTime;
    final refreshToken = await _storage.refreshToken;

    // If any token is null, then the user has never signed in or their
    // storage system was wiped.
    if (accessToken == null || expirationTime == null || refreshToken == null) {
      emit(const Unauthorized());
      return;
    }

    // If the expiration time is before *right now*, then we need to refresh
    // their access token.
    //
    // If it fails for any reason, sign the user out.
    //
    // If it succeeds, then sign the user in.
    if (expirationTime.isBefore(DateTime.now())) {
      // This user's access token is out of date and can be refreshed.
      final result = await _refreshAccessToken(refreshToken);
      if (result == null) {
        // We failed to refresh the user's access token.
        logout();
        return;
      } else {
        // We succeeded in refreshing the user's access token.
        emit(Authorized(accessToken: result));
        return;
      }
    }

    // In this situation, the user has all the token info that they need
    // and their expiration time hasn't happened yet. In this case, we can
    // just sign the user in as normal.
    emit(Authorized(accessToken: accessToken));
  }

  /// Puts this cubit into the [Authorizing] state with a newly generated
  /// "state" unique identifier required for the reddit api.
  ///
  /// Returns the auth url for reddit's web view sign in process.
  String startAuthorizingViaWeb() {
    final state = Authorizing(stateId: const Uuid().v4());
    emit(state);
    return state.authUrl;
  }

  /// Completes this cubit's [Authorizing] state by fetching an access token
  /// with the given state and code.
  void completeAuthorizingViaWeb(String stateId, String code) async {
    final state = this.state;
    if (state is! Authorizing || stateId != state.stateId) return;

    final accessToken = await _fetchAccessToken(stateId: stateId, code: code);
    if (accessToken == null) {
      // Sign in failed.
      emit(const Unauthorized());
    } else {
      emit(Authorized(accessToken: accessToken));
    }
  }

  /// Signs the user out and deletes their stored tokens.
  void logout() async {
    await _storage.deleteAllKeys();
    emit(const Unauthorized());
  }

  /// Fetches an access token from the reddit api using the given [code].
  ///
  /// A matching [stateId] must be provided.
  ///
  /// For more information on how to retrieve a code string, reference
  /// https://github.com/reddit-archive/reddit/wiki/OAuth2#token-retrieval-code-flow
  Future<String?> _fetchAccessToken({
    required String stateId,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse(
        'https://www.reddit.com/api/v1/access_token',
      ),
      body: [
        'grant_type=authorization_code',
        'code=$code',
        'redirect_uri=$redirectUri',
      ].join('&'),
      headers: {
        'Authorization': 'Basic ${base64.encode(utf8.encode('$clientId:'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)
          case {
            'access_token': String accessToken,
            'refresh_token': String refreshToken,
            'expires_in': int expiresInMs,
          }) {
        await _storage.setAccessToken(accessToken);
        await _storage.setExpirationTimeFromNow(expiresInMs);
        await _storage.setRefreshToken(refreshToken);
        return accessToken;
      }
    }
    return null;
  }

  /// Fetches a new access token from the reddit api using the stored refresh token.
  ///
  /// Returns the access token if this succeeds, or null otherwise.
  ///
  /// (A successful refresh will update storage with the new token info.)
  ///
  /// For more information on how to refresh an access token, reference
  /// https://github.com/reddit-archive/reddit/wiki/OAuth2#refreshing-the-token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(
        'https://www.reddit.com/api/v1/access_token',
      ),
      body: [
        'grant_type=refresh_token',
        'refresh_token=$refreshToken',
      ].join('&'),
      headers: {
        'Authorization': 'Basic ${base64.encode(utf8.encode('$clientId:'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)
          case {
            'access_token': String accessToken,
            'expires_in': int expiresInMs,
          }) {
        await _storage.setAccessToken(accessToken);
        await _storage.setExpirationTimeFromNow(expiresInMs);
        return accessToken;
      }
    }
    return null;
  }
}

/// Wraps [FlutterSecureStorage] and provides convenient access to all the
/// auth info you may need (like auth tokens).
final class _AuthStorage {
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const expirationTimeKey = 'expiration_time';
  static const _storage = FlutterSecureStorage();

  Future<String?> get accessToken async => await _storage.read(
        key: accessTokenKey,
      );

  Future<String?> get refreshToken async => await _storage.read(
        key: refreshTokenKey,
      );

  Future<DateTime?> get expirationTime async {
    final millisecondsSinceEpoch = int.tryParse(
      await _storage.read(key: expirationTimeKey) ?? '',
    );
    return millisecondsSinceEpoch == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            millisecondsSinceEpoch,
          );
  }

  Future<void> setAccessToken(String token) => _storage.write(
        key: accessTokenKey,
        value: token,
      );

  Future<void> setRefreshToken(String token) => _storage.write(
        key: refreshTokenKey,
        value: token,
      );

  Future<void> setExpirationTime(DateTime time) => _storage.write(
        key: expirationTimeKey,
        value: time.millisecondsSinceEpoch.toString(),
      );

  Future<void> setExpirationTimeFromNow(int ms) => setExpirationTime(
        DateTime.now().add(Duration(milliseconds: ms)),
      );

  Future<void> deleteAllKeys() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: expirationTimeKey);
  }
}

/// Represents the user's current authentication status.
///
/// Each child implementation provides access to the urls and tokens required
/// to transition to the next state or to authenticate http requests.
sealed class AuthState {
  const AuthState();
}

extension AuthStateX on AuthState {
  String? get accessToken => switch (this) {
        (Authorized authorized) => authorized.accessToken,
        _ => null,
      };
}

/// Logged out state when the user has no credentials.
class Unauthorized extends AuthState {
  const Unauthorized();
}

class CheckingAuthorization extends AuthState {
  const CheckingAuthorization();
}

/// The state when attempting to authorize via the reddit web view.
class Authorizing extends AuthState {
  const Authorizing({
    required this.stateId,
  });

  final String stateId;

  String get authUrl => 'https://old.reddit.com/api/v1/authorize?$queryParams';

  String get queryParams => [
        'client_id=${AuthCubit.clientId}',
        'response_type=code',
        'state=$stateId',
        'redirect_uri=${AuthCubit.redirectUri}',
        'duration=permanent',
        'scope=mysubreddits read subscribe',
      ].join('&');
}

/// The state after a successful authorization flow.
class Authorized extends AuthState {
  const Authorized({
    required this.accessToken,
  });

  final String accessToken;
}
