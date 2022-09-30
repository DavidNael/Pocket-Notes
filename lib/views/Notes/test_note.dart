// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../Constants/app_theme.dart';

// @override
// Widget build(BuildContext context) {
//   bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
//   toastColor = isDarkMode;
//   Color themeColor =
//       Provider.of<AppTheme>(context, listen: false).getColorTheme();
//   return FutureBuilder(
//     future: createOrGetExistingNote(context),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//          _quillTitleController.document.changes.listen((event) async {
//                   _saveNoteIfTextNotEmpty();
//                 });
//                 _quillNoteController.document.changes.listen((event) async {
//                   _saveNoteIfTextNotEmpty();
//                 });
//       return Scaffold(
//         backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
//         appBar: AppBar(
//           title: Builder(
//             builder: (context) {
//               final widgetNote = context.getArgument<CloudNote>();
//               if (widgetNote != null) {
//                 return Text(
//                   widgetNote.title,
//                   maxLines: 1,
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.black : Colors.white,
//                   ),
//                 );
//               } else {
//                 return Text(
//                   'New Note',
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.black : Colors.white,
//                   ),
//                 );
//               }
//             },
//           ),
//           actions: [
//             IconButton(
//               onPressed: () async {
//                 final text = _quillTitleController.document.toPlainText() +
//                     _quillNoteController.document.toPlainText();
//                 if (_note == null || text.isEmpty) {
//                   await showCannotShareEmptyNoteDialog(context);
//                 } else {
//                   Share.share(text);
//                 }
//               },
//               icon: Icon(
//                 Icons.share,
//                 color: isDarkMode ? Colors.black : Colors.white,
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 Clipboard.setData(
//                   ClipboardData(
//                     text: _quillTitleController.document.toPlainText() +
//                         _quillNoteController.document.toPlainText(),
//                   ),
//                 );
//                 Fluttertoast.showToast(
//                     msg: "Copied to clipboard",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.BOTTOM,
//                     timeInSecForIosWeb: 1,
//                     backgroundColor:
//                         isDarkMode ? darkBorderTheme : lightBorderTheme,
//                     textColor: isDarkMode ? darkTextTheme : lightTextTheme,
//                     fontSize: 16.0);
//               },
//               icon: Icon(
//                 Icons.copy,
//                 color: isDarkMode ? Colors.black : Colors.white,
//               ),
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.only(bottom: 15, left: 10),
//                         decoration: ShapeDecoration(
//                           shape: RoundedRectangleBorder(
//                             side: const BorderSide(
//                                 color: Colors.black,
//                                 width: 2),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         color: isDarkMode?darkTheme:lightTheme,
//                         ),
                        
//                         child: QuillEditor(
//                           controller: _quillTitleController,
//                           scrollController: ScrollController(),
//                           scrollable: true,
//                           focusNode: _focusTitleNode,
//                           autoFocus: false,
//                           readOnly: false,
//                           placeholder: 'Title',
//                           expands: false,
//                           padding: EdgeInsets.zero,
//                           customStyles: DefaultStyles(
//                             placeHolder: DefaultTextBlockStyle(
//                                 TextStyle(
//                                     color: isDarkMode
//                                         ? darkTextTheme
//                                         : lightTextTheme,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
//                             h1: DefaultTextBlockStyle(
//                                 TextStyle(
//                                   fontSize: 32,
//                                   color: isDarkMode
//                                       ? darkTextTheme
//                                       : lightTextTheme,
//                                   height: 1.15,
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
//                             paragraph: DefaultTextBlockStyle(
//                                 TextStyle(
//                                   fontSize: 20,
//                                   color: isDarkMode
//                                       ? darkTextTheme
//                                       : lightTextTheme,
//                                 ),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
                                
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.only(bottom: 15, left: 10),
//                         decoration: ShapeDecoration(
//                           shape: RoundedRectangleBorder(
//                             side: const BorderSide(
//                                 color: Colors.black,
//                                 width: 2),
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         color: isDarkMode?darkTheme:lightTheme,
//                         ),
//                         child: QuillEditor(
//                           controller: _quillNoteController,
//                           scrollController: ScrollController(),
//                           scrollable: true,
//                           focusNode: _focusNoteNode,
//                           autoFocus: false,
//                           readOnly: false,
//                           placeholder: 'Start Typing Your Note ...',
//                           expands: false,
//                           padding: EdgeInsets.zero,
//                           customStyles: DefaultStyles(
//                             placeHolder: DefaultTextBlockStyle(
//                                 TextStyle(
//                                     color: isDarkMode
//                                         ? darkTextTheme
//                                         : lightTextTheme,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 15),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
//                             h1: DefaultTextBlockStyle(
//                                 TextStyle(
//                                   fontSize: 32,
//                                   color: isDarkMode
//                                       ? darkTextTheme
//                                       : lightTextTheme,
//                                   // height: 1.15,
//                                   fontWeight: FontWeight.w300,
//                                 ),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
//                             paragraph: DefaultTextBlockStyle(
//                                 TextStyle(
//                                   fontSize: 15,
//                                   color: isDarkMode
//                                       ? darkTextTheme
//                                       : lightTextTheme,
//                                 ),
//                                 const Tuple2(16, 0),
//                                 const Tuple2(0, 0),
//                                 null),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 200,
//                       ),
//                     ],
//                   ),
//                 )
//         ),
//       );
//       }
//       if (snapshot.hasError) {
//                 return Text(
//                     'Error loading, Check your internet connection and try again. ' +
//                         snapshot.error.toString());
//               } else {
//                 return const CircularProgressIndicator();
//               }
//     },
//   );
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pocketnotes/Services/auth/auth_service.dart';
// import 'package:pocketnotes/Services/cloud/cloud_note.dart';
// import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
// import 'package:pocketnotes/utilities/dialogs/cannot_share_empty_dialog.dart';
// import 'package:pocketnotes/utilities/generics/get_arguments.dart';
// import 'package:share_plus/share_plus.dart';

// class CreateUpdateNoteView extends StatefulWidget {
//   const CreateUpdateNoteView({Key? key}) : super(key: key);

//   @override
//   State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
// }

// class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
//   CloudNote? _note;
//   late final FirebaseCloudStorage _notesService;
//   late final TextEditingController _textController;
//   String? noteTitle;

//   @override
//   void initState() {
//     _notesService = FirebaseCloudStorage();
//     _textController = TextEditingController();
//     super.initState();
//   }

//   void _textControllerListener() async {
//     final note = _note;
//     if (note == null) {
//       return;
//     }
//     final text = _textController.text;
//     await _notesService.updateNotes(documentId: note.documentId, text: text);
//   }

//   void _setupTextControllerListener() {
//     _textController.removeListener(_textControllerListener);
//     _textController.addListener(_textControllerListener);
//   }

//   Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
//     final widgetNote = context.getArgument<CloudNote>();
//     if (widgetNote != null) {
//       _note = widgetNote;
//       _textController.text = widgetNote.text;
//       noteTitle = widgetNote.text;
//       return widgetNote;
//     }
//     final existingNote = _note;
//     if (existingNote != null) {
//       return existingNote;
//     }
//     final currentUser = AuthService.firebase().currentUser!;
//     final userId = currentUser.id;
//     final newNote = await _notesService.createNewNote(ownerUserId: userId);
//     _note = newNote;
//     return newNote;
//   }

//   void _deleteNoteIfTextIsEmpty() {
//     final note = _note;
//     if (_textController.text.isEmpty && note != null) {
//       _notesService.deleteNotes(documentId: note.documentId);
//     }
//   }

//   void _saveNoteIfTextNotEmpty() async {
//     final note = _note;
//     final text = _textController.text;
//     if (note != null && text.isNotEmpty) {
//       await _notesService.updateNotes(documentId: note.documentId, text: text);
//     }
//   }

//   @override
//   void dispose() {
//     _deleteNoteIfTextIsEmpty();
//     _saveNoteIfTextNotEmpty();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 200, 200, 200),
//       appBar: AppBar(
//         title: Builder(
//           builder: (Context) {
//             final widgetNote = context.getArgument<CloudNote>();
//             if (widgetNote != null) {
//               return Text(
//                 widgetNote.text,
//                 maxLines: 1,
//               );
//             } else {
//               return const Text('New Note');
//             }
//           },
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               final text = _textController.text;
//               if (_note == null || text.isEmpty) {
//                 await ShowCannotShareEmptyNoteDialog(context);
//               } else {
//                 Share.share(text);
//               }
//             },
//             icon: const Icon(Icons.share),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: FutureBuilder(
//           future: createOrGetExistingNote(context),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return TextField(
//                 enabled: false,
//                 minLines: 2,
//                 maxLines: 2,
//                 decoration: const InputDecoration(
//                     hintText:
//                         'Error loading, Check your internet connection and try again.'),
//                 style: GoogleFonts.roboto(
//                   fontSize: 18,
//                 ),
//               );
//             }
//             switch (snapshot.connectionState) {
//               case ConnectionState.done:
//                 return TextField(
//                   controller: _textController,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   decoration: const InputDecoration(
//                       hintText: 'Start Typing Your Note ...'),
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                   ),
//                 );
//               default:
//                 return const CircularProgressIndicator();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

