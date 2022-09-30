// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pocketnotes/Services/auth/exceptions.dart';
// import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
// import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
// import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';

// import '../utilities/dialogs/error_dialog.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({Key? key}) : super(key: key);

//   @override
//   State<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
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
//         if (state is AuthStateLoggedOut) {
//           if (state.exception is UserNotFoundAuthException) {
//             await showErrorDialog(
//                 context, 'Could not find user with the entered credentials.');
//           } else if (state.exception is WrongPasswordAuthException) {
//             await showErrorDialog(context, 'Wrong Credentials.');
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
//               'Login',
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
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
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
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
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

//                     ///Forgot password Button
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                               onPressed: () {
//                                 context
//                                     .read<AuthBloc>()
//                                     .add(const AuthEventForgotpassword(null));
//                               },
//                               child: const Text(
//                                 'Forgot Password?',
//                                 style: TextStyle(color: Colors.blue),
//                                 // textAlign: TextAlign.right,
//                               )),
//                         ],
//                       ),
//                     ),

//                     ///Login Button
//                     Container(
//                       padding: const EdgeInsets.only(bottom: 20.0),
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
//                             context.read<AuthBloc>().add(AuthEventLogIn(
//                                   email,
//                                   password,
//                                 ));
//                           },
//                           child: const Text(
//                             'Login',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     ///Register Button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Don\'t have an Account?',
//                         ),
//                         TextButton(
//                             onPressed: () {
//                               context
//                                   .read<AuthBloc>()
//                                   .add(const AuthEventShouldRegister());
//                             },
//                             child: const Text(
//                               'Register',
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


// GridTile(
//   child: Container(
//     height: double.infinity,
//     decoration: ShapeDecoration(
//       shape:
//           RoundedRectangleBorder(
//         side: BorderSide(
//           color: isDarkMode
//               ? Colors.black
//               : Colors.grey
//                   .shade500,
//           width: 2,
//         ),
//         borderRadius:
//             BorderRadius
//                 .circular(
//           10,
//         ),
//       ),
//     ),
//     child: ListTile(
//       onLongPress: () {
//         showModalBottomSheet(
//           shape:
//               const RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius
//                     .vertical(
//               top: Radius
//                   .circular(20),
//             ),
//           ),
//           context: context,
//           builder: (context) {
//             return Padding(
//               padding:
//                   const EdgeInsets
//                       .all(8.0),
//               child: Column(
//                 mainAxisSize:
//                     MainAxisSize
//                         .min,
//                 crossAxisAlignment:
//                     CrossAxisAlignment
//                         .stretch,
//                 children: [
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   //!choose Option Text
//                   Text(
//                     'Choose Option:',
//                     style:
//                         TextStyle(
//                       color: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                     ),
//                     textAlign:
//                         TextAlign
//                             .center,
//                   ),

//                   //!Archive Button
//                   Padding(
//                     padding:
//                         const EdgeInsets.all(
//                             4.0),
//                     child:
//                         SettingsTile(
//                       icon: Icons
//                           .archive,
//                       circleColor: isDarkMode
//                           ? darkBorderTheme
//                           : themeColor,
//                       iconColor: isDarkMode
//                           ? themeColor
//                           : Colors
//                               .white,
//                       tileColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       borderColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       title:
//                           'Archive',
//                       textColor: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                       subtitle:
//                           null,
//                       trailing:
//                           null,
//                       onTap:
//                           () {},
//                     ),
//                   ),

//                   //!Pin Buttton
//                   Padding(
//                     padding:
//                         const EdgeInsets.all(
//                             4.0),
//                     child:
//                         SettingsTile(
//                       icon: Icons
//                           .push_pin,
//                       circleColor: isDarkMode
//                           ? darkBorderTheme
//                           : themeColor,
//                       iconColor: isDarkMode
//                           ? themeColor
//                           : Colors
//                               .white,
//                       tileColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       borderColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       title:
//                           'Pin',
//                       textColor: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                       subtitle:
//                           null,
//                       trailing:
//                           null,
//                       onTap:
//                           () {},
//                     ),
//                   ),
//                   //!Delete Buttton
//                   Padding(
//                     padding:
//                         const EdgeInsets.all(
//                             4.0),
//                     child:
//                         SettingsTile(
//                       icon: Icons
//                           .delete,
//                       circleColor: isDarkMode
//                           ? darkBorderTheme
//                           : themeColor,
//                       iconColor: isDarkMode
//                           ? themeColor
//                           : Colors
//                               .white,
//                       tileColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       borderColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       title:
//                           'Delete',
//                       textColor: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                       subtitle:
//                           null,
//                       trailing:
//                           null,
//                       onTap:
//                           () async {
//                         final shouldDelete =
//                             await showDeleteDialog(context);
//                         if (shouldDelete) {
//                           Navigator.pop(
//                               context);
//                           Future
//                               .delayed(
//                             const Duration(milliseconds: 500),
//                             () async {
//                               await _notesService.deleteNotes(documentId: note.documentId);
//                             },
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                   //!Share Buttton
//                   Padding(
//                     padding:
//                         const EdgeInsets.all(
//                             4.0),
//                     child:
//                         SettingsTile(
//                       icon: Icons
//                           .share,
//                       circleColor: isDarkMode
//                           ? darkBorderTheme
//                           : themeColor,
//                       iconColor: isDarkMode
//                           ? themeColor
//                           : Colors
//                               .white,
//                       tileColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       borderColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       title:
//                           'Share',
//                       textColor: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                       subtitle:
//                           null,
//                       trailing:
//                           null,
//                       onTap:
//                           () async {
//                         final text =
//                             note.title +
//                                 note.note;
//                         if (text
//                             .trim()
//                             .isEmpty) {
//                           await showCannotShareEmptyNoteDialog(
//                               context);
//                         } else {
//                           Share.share(
//                               text);
//                         }
//                       },
//                     ),
//                   ),
//                   //!Info Buttton
//                   Padding(
//                     padding:
//                         const EdgeInsets.all(
//                             4.0),
//                     child:
//                         SettingsTile(
//                       icon: Icons
//                           .info,
//                       circleColor: isDarkMode
//                           ? darkBorderTheme
//                           : themeColor,
//                       iconColor: isDarkMode
//                           ? themeColor
//                           : Colors
//                               .white,
//                       tileColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       borderColor: isDarkMode
//                           ? darkTheme
//                           : lightTheme,
//                       title:
//                           'Info',
//                       textColor: isDarkMode
//                           ? darkTextTheme
//                           : lightTextTheme,
//                       subtitle:
//                           null,
//                       trailing:
//                           null,
//                       onTap:
//                           () {
//                         showInfoDialog(
//                           context,
//                           title:
//                               'Info',
//                           content:
//                               'Created On: $noteDateCreated\n\nModified On: $noteDateModified',
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       tileColor: themeColor,
//       shape:
//           RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius
//                 .circular(
//           10,
//         ),
//       ),
//       onTap: () {
//         Navigator.of(context)
//             .push(
//           ScalePageTransition(
//             child:
//                 CreateUpdateView(
//               getNote: note,
//             ),
//           ),
//         );
//       },
//       title:
//           SingleChildScrollView(
//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,
//           children: [
//             //!Title
//             Padding(
//               padding:
//                   const EdgeInsets
//                           .only(
//                       top: 5,
//                       bottom:
//                           10),
//               child: Text(
//                 note.title
//                         .trim()
//                         .isNotEmpty
//                     ? note.title
//                     : 'Untitled',
//                 maxLines: 1,
//                 textAlign:
//                     TextAlign
//                         .center,
//                 softWrap: true,
//                 overflow:
//                     TextOverflow
//                         .ellipsis,
//                 textScaleFactor:
//                     1.2,
//                 style:
//                     TextStyle(
//                   color: isDarkMode
//                       ? Colors
//                           .grey
//                           .shade300
//                       : Colors
//                           .black,
//                   fontWeight:
//                       FontWeight
//                           .bold,
//                 ),
//               ),
//             ),
//             //!Note
//             Padding(
//               padding:
//                   const EdgeInsets
//                       .only(
//                 top: 5,
//                 bottom: 5,
//               ),
//               child: Text(
//                 note.note
//                         .trim()
//                         .isNotEmpty
//                     ? note.note
//                     : 'Empty Note...',

//                 maxLines: orientation ==
//                         Orientation
//                             .portrait
//                     ? 5
//                     : 8,

//                 // textAlign:
//                 //     TextAlign.center,
//                 softWrap: true,
//                 overflow:
//                     TextOverflow
//                         .ellipsis,
//                 textScaleFactor:
//                     0.9,
//                 style:
//                     TextStyle(
//                   color: isDarkMode
//                       ? Colors
//                           .grey
//                           .shade300
//                       : Colors
//                           .black,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     ),
//   ),
// )