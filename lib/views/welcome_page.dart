import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Services/auth/bloc/auth_event.dart';
import 'Constants/app_theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final controller = PageController();
  bool isLastPage = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  dispose() {
    controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: PageView(
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            controller: controller,
            children: [
              ///Page 1
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.amber,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Image.asset(
                      'assets/images/app_logo.png',
                      scale: 2.5,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Center(
                      child: Text(
                        'Welcome To Pocket Notes App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ///Page 2
              Container(
                color: Colors.amber,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      '\u2022 Enjoy a fantastic writing experience with various Themes to choose from. \n\n \u2022 The app is as secure as you\'d like it to be. \n\n \u2022 Easily manage and filter all your notes. \n\n \u2022 Retrieve all your Data by simply logging into your account.',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              ///Page 3
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.amber,
                child: const Center(
                  child: Center(
                    child: Text(
                      'Let\'s Begin by Adding You to Your Account. ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: isLastPage
            ? Container(
                padding: const EdgeInsets.all(15),
                color: Colors.amber,
                child: TextButton(
                  onPressed: () async {
                    AppTheme.prefs.setBool('showWelcome', false);
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventShouldRegister());
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color.fromARGB(202, 0, 0, 0), width: 5)),
                    primary: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 255, 130, 0),
                    minimumSize: const Size.fromHeight(80),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 80,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.amber,
                        ),
                        onPressed: () => controller.jumpToPage(2),
                        child: const Text('SKIP'),
                      ),
                      Center(
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: 3,
                          effect: const WormEffect(
                            spacing: 16,
                            dotColor: Colors.amber,
                            activeDotColor: Color.fromARGB(255, 255, 98, 0),
                          ),
                          onDotClicked: (index) => controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      TextButton(
                                                style: TextButton.styleFrom(
                          primary: Colors.amber,
                        ),
                        onPressed: () => controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('Next'),
                      ),
                    ]),
              ),
      );
}
