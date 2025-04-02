import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../utility/github_oauth_handler.dart';
import '../views/home_view.dart';

/*
  Widget to handle the GitHub device flow login.
 */
class GithubLoginButton extends StatefulWidget {
  const GithubLoginButton({super.key});

  @override
  State<GithubLoginButton> createState() => _GithubLoginButtonState();
}

class _GithubLoginButtonState extends State<GithubLoginButton>
    with WidgetsBindingObserver {
  late GitHubAuth githubAuth;

  @override
  void initState() {
    super.initState();
    githubAuth = GitHubAuth(callbackFunction: showSnackbar);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    githubAuth.resetHandler();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    developer.log("AppLifecycleState changed to: $state",
        level: 800, name: "com.GitDone.gitdone.login");
    if (state == AppLifecycleState.resumed && githubAuth.inLoginProcess) {
      continueLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          transitionDuration: Duration(milliseconds: 200),
        );
        await githubAuth.startLoginProcess(context);
      },
      child: Text("Login with GitHub"),
    );
  }

  Future<void> continueLogin() async {
    var authenticated = await githubAuth.pollForToken();
    if (mounted && authenticated) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Homeview()));
    } else {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      showSnackbar("Login failed. Please try again.");
    }
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
