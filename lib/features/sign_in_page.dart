import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/popups.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: const FractionalOffset(0.5, 0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Title().animate().fadeIn(),
            const _Subtitle().animate().fadeIn(delay: 0.15.seconds),
            const SizedBox(height: 16),
            switch (context.watchAuthCubit.state) {
              CheckingAuthorization _ => const LoadingIndicator(),
              _ => FilledButton(
                  onPressed: () => _showSignInWebView(context),
                  child: const Text('sign in'),
                )
                    .animate(
                      delay: 0.3.seconds,
                    )
                    .scaleX(
                      duration: 1.seconds,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),
            },
            // FutureBuilder(
            //   future: context.read<AuthCubit>().areTokensStoredAndValid(),
            //   builder: (context, snapshot) {
            //     final areValid = snapshot.data;
            //     if (areValid == null) {
            //       return const LoadingIndicator();
            //     } else if (areValid) {
            //       return Text(
            //         'welcome back',
            //         style: context.textTheme.bodyMedium,
            //       )
            //           .animate(
            //             delay: 0.5.seconds,
            //             onComplete: (_) => _signInViaStorage(context),
            //           )
            //           .scaleX(
            //             duration: 0.75.seconds,
            //             curve: Curves.elasticOut,
            //           );
            //     } else {
            //       return FilledButton(
            //         onPressed: () => _showSignInWebView(context),
            //         child: const Text('sign in'),
            //       )
            //           .animate(
            //             delay: 0.3.seconds,
            //           )
            //           .scaleX(
            //             duration: 1.seconds,
            //             curve: Curves.elasticOut,
            //           )
            //           .fadeIn();
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  void _showSignInWebView(
    BuildContext context,
  ) {
    showPrimaryPopup(
      context: context,
      expand: true,
      builder: (context, _) {
        return _AuthWebView(
          onComplete: ({required stateId, required code}) async {
            final routerCubit = context.read<RouterCubit>();
            final authCubit = context.read<AuthCubit>();

            // Do a little delay to make the experience nicer.
            routerCubit.goBack(context);
            await Future.delayed(400.milliseconds);
            authCubit.completeAuthorizingViaWeb(stateId, code);
          },
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      'lurkur',
      style: context.textTheme.displayLarge,
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Reddit, but simpler.',
      style: context.textTheme.titleMedium,
    );
  }
}

class _AuthWebView extends StatefulWidget {
  const _AuthWebView({
    required this.onComplete,
  });

  final void Function({
    required String stateId,
    required String code,
  }) onComplete;

  @override
  State<_AuthWebView> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends State<_AuthWebView> {
  late final _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _checkForAuthRedirect,
        ),
      );
    _loadAuthUrl();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  void _loadAuthUrl() {
    _controller.loadRequest(
      Uri.parse(
        context.read<AuthCubit>().startAuthorizingViaWeb(),
      ),
    );
  }

  NavigationDecision _checkForAuthRedirect(NavigationRequest request) {
    if (request.url.startsWith(AuthCubit.redirectUri)) {
      if (Uri.parse(request.url).queryParameters
          case {'state': String stateId, 'code': String code}) {
        widget.onComplete(stateId: stateId, code: code);
      }
    }
    return NavigationDecision.navigate;
  }
}
