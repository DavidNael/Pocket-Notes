import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocketnotes/Services/auth/exceptions.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utilities/dialogs/error_dialog.dart';
import '../utilities/dialogs/verification_dialog.dart';
import 'Settings/settings.dart';

class LoginSignupView extends StatefulWidget {
  const LoginSignupView({Key? key}) : super(key: key);

  @override
  State<LoginSignupView> createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  late final TextEditingController _email;
  late final TextEditingController _username;
  late final TextEditingController _password;
  final _pageController = PageController();
  DateTime? lastPressed;

  DateTime timeBackPressed = DateTime.now();
  @override
  void initState() {
    _username = TextEditingController();
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
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    Color accent = Provider.of<AppTheme>(context, listen: false).getAccent();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
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
                'Unknown error. Make sure you are connected to the internet and try again.');
          }
        } else if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context,
                'Weak Password. password must contain capital letter, small letter, numirical digit, and at least 8 characters long.');
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
                'Unknown error. Make sure you are connected to the internet and try again.');
          }
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            final now = DateTime.now();
            final isWarning = lastPressed == null ||
                now.difference(lastPressed!) > const Duration(seconds: 2);
            if (isWarning) {
              lastPressed = DateTime.now();
              Fluttertoast.showToast(
                  msg: 'Press back again to exit',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor:
                      isDarkMode ? darkBorderTheme : lightBorderTheme,
                  textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                  fontSize: 16.0);
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            backgroundColor: themeColor,
            body: Container(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: PageView(
                controller: _pageController,
                children: [
                  //!Login Page
                  Center(
                    child: SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: isDarkMode
                                        ? darkBorderTheme
                                        : lightBorderTheme,
                                    border: Border.all(color: Colors.black)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ///Sized Box
                                    const SizedBox(
                                      height: 20,
                                    ),

                                    //!Login Text
                                    Container(
                                      alignment: Alignment.topCenter,
                                      padding:
                                          const EdgeInsets.only(bottom: 50),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkHeaderTheme
                                              : lightHeaderTheme,
                                        ),
                                      ),
                                    ),

                                    //!E-mail Field
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? darkBorderTheme
                                            : lightBorderTheme,
                                      ),
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                        ),
                                        controller: _email,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          labelText: 'Email:',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 15.0,
                                    ),

                                    //!Password Field
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? darkBorderTheme
                                            : lightBorderTheme,
                                      ),
                                      child: TextField(
                                        obscureText: true,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                        ),
                                        controller: _password,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          labelText: 'Password:',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    //!Forgot password Button
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                              onPressed: () async {
                                                context.read<AuthBloc>().add(
                                                    const AuthEventForgotpassword(
                                                        null));
                                              },
                                              child: const Text(
                                                'Forgot Password?',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                                // textAlign: TextAlign.right,
                                              )),
                                        ],
                                      ),
                                    ),

                                    //!Login Button
                                    Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: SizedBox(
                                        width: 250,
                                        height: 60,
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0))),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(themeColor),
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
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    //!Register Button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an Account?',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              _pageController.nextPage(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.easeOut,
                                              );
                                            },
                                            child: const Text(
                                              'Register',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //!Settings Button
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    focusColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        FadePageTransition(
                                          child: const SettingsView(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.settings,
                                      color: isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  //!Register Page
                  Center(
                    child: SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: isDarkMode
                                        ? darkBorderTheme
                                        : lightBorderTheme,
                                    border: Border.all(color: Colors.black)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ///Sized Box
                                    const SizedBox(
                                      height: 20,
                                    ),

                                    //!Register Text
                                    Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 50),
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkHeaderTheme
                                              : lightHeaderTheme,
                                        ),
                                      ),
                                    ),

                                    //!Username Field
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? darkBorderTheme
                                            : lightBorderTheme,
                                      ),
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                        ),
                                        controller: _username,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          labelText: 'Username:',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),

                                    //!E-mail Field
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? darkBorderTheme
                                            : lightBorderTheme,
                                      ),
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                        ),
                                        controller: _email,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          labelText: 'Email:',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),

                                    //!Password Field
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? darkBorderTheme
                                            : lightBorderTheme,
                                      ),
                                      child: TextField(
                                        obscureText: true,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                        ),
                                        controller: _password,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          labelText: 'Password:',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: themeColor,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //!Register Button
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
                                                        BorderRadius.circular(
                                                            12.0))),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(themeColor),
                                          ),
                                          onPressed: () async {
                                            final userName = _username.text;
                                            final email = _email.text;
                                            final password = _password.text;
                                            if (userName.trim().isEmpty) {
                                              await showErrorDialog(context,
                                                  'Username can\'t be empty.');
                                            } else if (userName.length < 8) {
                                              await showErrorDialog(context,
                                                  'Username must be at least 8 characters long.');
                                            } else {
                                              context.read<AuthBloc>().add(
                                                    AuthEventRegister(
                                                      email,
                                                      password,
                                                      userName,
                                                    ),
                                                  );
                                            }
                                          },
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an Account?',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          child: const Text(
                                            'Login',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //!Settings Button
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    focusColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        FadePageTransition(
                                          child: const SettingsView(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.settings,
                                      color: isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: WormEffect(
                        spacing: 16,
                        dotColor: accent,
                        activeDotColor: themeColor,
                      ),
                      onDotClicked: (index) => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
