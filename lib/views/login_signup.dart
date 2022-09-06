import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnotes/Services/auth/exceptions.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../utilities/dialogs/error_dialog.dart';
import '../utilities/dialogs/verification_dialog.dart';

class LoginSignupView extends StatefulWidget {
  const LoginSignupView({Key? key}) : super(key: key);

  @override
  State<LoginSignupView> createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final _pageController = PageController();
  DateTime timeBackPressed = DateTime.now();
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  dispose() {
    _email.dispose();
    _password.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, 'Could not find user with the entered credentials.');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong Credentials.');
          } else if (state.exception is UserNotLoggedInAuthException) {
            await showErrorDialog(context, 'User not logged in.');
          } else if (state.exception is EmptyEmailAuthException) {
            await showErrorDialog(context, 'Email field can\'t be empty.');
          } else if (state.exception is EmptyPasswordAuthException) {
            await showErrorDialog(context, 'Password field can\'t be empty.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email format.');
          } else if (state.exception is UnknownException) {
            await showErrorDialog(context,
                'Unknown error, Make sure you are connected to the internet and try again.');
          }
        } else if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password');
          } else if (state.exception is EmailExistsAuthException) {
            await showErrorDialog(
                context, 'The email you are trying to enter already exists.');
          } else if (state.exception is VerifyEmailException) {
            final verifyDialog = await showVerificationDialog(context);
            if (verifyDialog) {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }
          } else if (state.exception is UserNotLoggedInAuthException) {
            await showErrorDialog(context, 'User not logged in.');
          } else if (state.exception is EmptyEmailAuthException) {
            await showErrorDialog(context, 'Email field can\'t be empty.');
          } else if (state.exception is EmptyPasswordAuthException) {
            await showErrorDialog(context, 'Password field can\'t be empty.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email format.');
          } else if (state.exception is UnknownException) {
            await showErrorDialog(context,
                'Unknown error, Make sure you are connected to the internet and try again.');
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.amber,
          body: Container(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: PageView(
              controller: _pageController,
              children: [
                ///Login Page
                Center(
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.black)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ///Sized Box
                              const SizedBox(
                                height: 20,
                              ),

                              ///Login Text
                              Container(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.lato(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ///E-mail Field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    controller: _email,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.amber,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Enter your Email...'),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),

                              ///Password Field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      // border: Border.all(color: Colors.white),
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: TextField(
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.black),
                                    controller: _password,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.amber,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Enter your Password...'),
                                  ),
                                ),
                              ),

                              ///Forgot password Button
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          context.read<AuthBloc>().add(
                                              const AuthEventForgotpassword(
                                                  null));
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(color: Colors.blue),
                                          // textAlign: TextAlign.right,
                                        )),
                                  ],
                                ),
                              ),

                              ///Login Button
                              Container(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: SizedBox(
                                  width: 250,
                                  height: 60,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.amber),
                                    ),
                                    onPressed: () async {
                                      final email = _email.text;
                                      final password = _password.text;
                                      context
                                          .read<AuthBloc>()
                                          .add(AuthEventLogIn(
                                            email,
                                            password,
                                          ));
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              ///Register Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don\'t have an Account?',
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Register Page
                Center(
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.black)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ///Sized Box
                              const SizedBox(
                                height: 20,
                              ),

                              ///Login Text
                              Container(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.lato(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ///E-mail Field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      // border: Border.all(color: Colors.white),
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    controller: _email,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.amber,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Enter your Email...'),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),

                              ///Password Field
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      // border: Border.all(color: Colors.white),
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: TextField(
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.black),
                                    controller: _password,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.amber,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Enter your Password...'),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: 250,
                                  height: 60,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.amber),
                                    ),
                                    onPressed: () async {
                                      final email = _email.text;
                                      final password = _password.text;
                                      context.read<AuthBloc>().add(
                                            AuthEventRegister(
                                              email,
                                              password,
                                            ),
                                          );
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an Account?',
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///Bottom Part
          bottomSheet: Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            height: 80,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const WormEffect(
                    spacing: 16,
                    dotColor: Colors.amber,
                    activeDotColor: Color.fromARGB(255, 255, 98, 0),
                  ),
                  onDotClicked: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
