// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pocketnotes/Services/auth/exceptions.dart';
// import 'package:pocketnotes/utilities/dialogs/verification_dialog.dart';
// import '../Services/auth/bloc/auth_bloc.dart';
// import '../Services/auth/bloc/auth_event.dart';
// import '../Services/auth/bloc/auth_state.dart';
// import '../utilities/dialogs/error_dialog.dart';

// class RegisterView extends StatefulWidget {
//   const RegisterView({Key? key}) : super(key: key);

//   @override
//   State<RegisterView> createState() => _RegisterViewState();
// }

// class _RegisterViewState extends State<RegisterView> {
//   late final TextEditingController _email;
//   late final TextEditingController _password;

//   @override
//   void initState() {
//     _email = TextEditingController();
//     _password = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) async {
//         if (state is AuthStateRegistering) {
//           if (state.exception is WeakPasswordAuthException) {
//             await showErrorDialog(context, 'Weak Password');
//           } else if (state.exception is EmailExistsAuthException) {
//             await showErrorDialog(
//                 context, 'The email you are trying to enter already exists.');
//           } else if (state.exception is VerifyEmailException) {
//             final verifyDialog = await showVerificationDialog(context);
//             if (verifyDialog) {
//               context.read<AuthBloc>().add(const AuthEventLogOut());
//             }
//           } else if (state.exception is UserNotLoggedInAuthException) {
//             await showErrorDialog(context, 'User not logged in.');
//           } else if (state.exception is EmptyEmailAuthException) {
//             await showErrorDialog(context, 'Email field can\'t be empty.');
//           } else if (state.exception is EmptyPasswordAuthException) {
//             await showErrorDialog(context, 'Password field can\'t be empty.');
//           } else if (state.exception is InvalidEmailAuthException) {
//             await showErrorDialog(context, 'Invalid email format.');
//           } else if (state.exception is UnknownException) {
//             await showErrorDialog(context,
//                 'Unknown error, Make sure you are connected to the internet and try again.');
//           }
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Center(
//             child: Text(
//               'Register',
//               style: GoogleFonts.roboto(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         backgroundColor: Colors.grey[300],
//         body: Center(
//           child: SingleChildScrollView(
//             child: SafeArea(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ///Sized Box
//                     const SizedBox(
//                       height: 20,
//                     ),

//                     ///E-mail Field
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             // border: Border.all(color: Colors.white),
//                             borderRadius: BorderRadius.circular(12.0)),
//                         child: TextField(
//                           keyboardType: TextInputType.emailAddress,
//                           style: const TextStyle(color: Colors.black),
//                           controller: _email,
//                           enableSuggestions: false,
//                           autocorrect: false,
//                           textAlign: TextAlign.center,
//                           decoration: InputDecoration(
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                     color: Colors.white, width: 1.0),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Colors.amber,
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               border: InputBorder.none,
//                               hintText: 'Enter your Email...'),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10.0,
//                     ),

//                     ///Password Field
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             // border: Border.all(color: Colors.white),
//                             borderRadius: BorderRadius.circular(12.0)),
//                         child: TextField(
//                           obscureText: true,
//                           style: const TextStyle(color: Colors.black),
//                           controller: _password,
//                           enableSuggestions: false,
//                           autocorrect: false,
//                           textAlign: TextAlign.center,
//                           decoration: InputDecoration(
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                     color: Colors.white, width: 1.0),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(
//                                   color: Colors.amber,
//                                   width: 1.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               border: InputBorder.none,
//                               hintText: 'Enter your Password...'),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       child: SizedBox(
//                         width: 250,
//                         height: 60,
//                         child: TextButton(
//                           style: ButtonStyle(
//                             shape: MaterialStateProperty.all(
//                                 RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12.0))),
//                             backgroundColor:
//                                 MaterialStateProperty.all<Color>(Colors.amber),
//                           ),
//                           onPressed: () async {
//                             final email = _email.text;
//                             final password = _password.text;
//                             context.read<AuthBloc>().add(
//                                   AuthEventRegister(
//                                     email,
//                                     password,
//                                   ),
//                                 );
//                           },
//                           child: const Text(
//                             'Register',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Already have an Account?',
//                         ),
//                         TextButton(
//                             onPressed: () {
//                               context
//                                   .read<AuthBloc>()
//                                   .add(const AuthEventLogOut());
//                             },
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(color: Colors.blue),
//                             )),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
