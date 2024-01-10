import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lurkur/app/secrets.dart' as secrets;
import 'package:uuid/uuid.dart';

/// Manages the user's authorization session.
class AuthCubit extends Cubit<AuthState> {
  static const clientId = secrets.clientId;
  static const redirectUri = 'https://www.reddit.com';
  static const _storage = FlutterSecureStorage();

  AuthCubit() : super(const Unauthorized());

  /// Returns true if secure storage contains tokens required for login.
  Future<bool> areTokensStoredAndValid() async {
    final accessToken = await _storage.read(key: 'access_token');
    final expires = await _storage.read(key: 'expires');
    final refreshToken = await _storage.read(key: 'refresh_token');
    return [accessToken, expires, refreshToken].every((s) => s != null);
  }

  /// Puts this cubit [Authorized] state if secure storage contains valid tokens.
  void startAuthorizingViaStorage() async {
    final accessToken = await _storage.read(key: 'access_token');
    final expires = await _storage.read(key: 'expires');
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (accessToken == null || expires == null || refreshToken == null) {
      emit(const Unauthorized());
      return;
    }
    emit(
      Authorized(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expirationTime: DateTime.parse(expires),
      ),
    );
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

  /// Fetches an access token from the reddit api using the given [code].
  ///
  /// A matching [stateId] must be provided.
  ///
  /// For more information on how to retrieve a code string, reference
  /// https://github.com/reddit-archive/reddit/wiki/OAuth2#token-retrieval-code-flow
  void authorize({
    required String stateId,
    required String code,
  }) async {
    final state = this.state;
    if (state is! Authorizing || state.stateId != stateId) {
      return;
    }

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
      final {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
      } = jsonDecode(response.body);
      var expires = DateTime.now().add(Duration(seconds: expiresIn));
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'expires', value: expires.toString());
      await _storage.write(key: 'refresh_token', value: refreshToken);
      emit(
        Authorized(
          accessToken: accessToken,
          expirationTime: expires,
          refreshToken: refreshToken,
        ),
      );
    }
  }

  /// Signs the user out and deletes their stored tokens.
  void logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'expires');
    await _storage.delete(key: 'refresh_token');
    emit(const Unauthorized());
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
    required this.refreshToken,
    required this.expirationTime,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expirationTime;
}
