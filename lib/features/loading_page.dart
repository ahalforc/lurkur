import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:provider/provider.dart';

import '../app/blocs/auth_cubit.dart';
import '../app/blocs/router_cubit.dart';


class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _checkAuth(BuildContext context) async {
    // Do a little delay to make the experience nicer.
    final authCubit = context.read<AuthCubit>();
    authCubit.checkExistingAuth();
    return Future(() => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: const FractionalOffset(0.5, 0.45),
        child: SeparatedColumn(
          mainAxisSize: MainAxisSize.min,
          space: ThemeCubit.medium2Padding,
          children: [
            FutureBuilder(future: _checkAuth(context), builder: (context, snapshot) {
              return const Center(child: Text('Auth Complete'));
            })
          ],
        ),
      ),
    );
  }
}
