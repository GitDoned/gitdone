import 'package:flutter/material.dart';
import 'package:gitdone/ui/view_models/login_github_view_model.dart';
import 'package:gitdone/ui/widgets/app_bar.dart';
import 'package:gitdone/ui/widgets/page_title.dart';
import 'package:provider/provider.dart';

class LoginGithubView extends StatefulWidget {
  const LoginGithubView({super.key});

  @override
  State<LoginGithubView> createState() => _LoginGithubViewState();
}

class _LoginGithubViewState extends State<LoginGithubView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<LoginGithubViewModel>().startLogin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<LoginGithubViewModel>().disposeHandler();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    context
        .read<LoginGithubViewModel>()
        .handleAppLifecycleState(state, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NormalAppBar(),
        body: ChangeNotifierProvider(
          create: (_) => LoginGithubViewModel(
            infoCallback: (text) {},
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitleWidget(
                  title: "GitHub OAuth Login",
                ),
                RichText(
                    text: TextSpan(
                  style: TextStyle(fontSize: 18),
                  text:
                      "To log in with GitHub, please copy the code below and open the browser. There authenticate with your GitHub account, paste the device code and authorize the app. After that, close the browser.",
                )),
                Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                Center(
                  child: ValueListenableBuilder<bool>(
                      valueListenable:
                          context.watch<LoginGithubViewModel>().fetchedUserCode,
                      builder: (context, fetchedUserCode, child) {
                        if (!fetchedUserCode) {
                          return CircularProgressIndicator();
                        }
                        return Column(
                          children: [
                            Text("Please enter this code in the browser: "),
                            SelectableText(
                              context.watch<LoginGithubViewModel>().userCode,
                              style: TextStyle(fontSize: 20),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Provider.of<LoginGithubViewModel>(context,
                                          listen: false)
                                      .launchBrowser(),
                              child: Text("Copy code and open browser"),
                            )
                          ],
                        );
                      }),
                ),
                ValueListenableBuilder(
                    valueListenable: context
                        .watch<LoginGithubViewModel>()
                        .showProgressIndicatorNotifier,
                    builder: (context, showProgressIndicatorNotifier, child) {
                      if (showProgressIndicatorNotifier) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showProgressIndicator();
                        });
                      }
                      return SizedBox.shrink();
                    })
              ],
            ),
          ),
        ));
  }

  void _showProgressIndicator() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
    );
  }
}
