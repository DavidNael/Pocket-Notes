import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnotes/Services/auth/auth_service.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:pocketnotes/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:pocketnotes/utilities/generics/get_arguments.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../Constants/app_theme.dart';
import '../settings.dart';

class CreateUpdateView extends StatefulWidget {
  const CreateUpdateView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateView> createState() => _CreateUpdateViewState();
}

class _CreateUpdateViewState extends State<CreateUpdateView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final QuillController _quillController;
  String initialText = '';
  final FocusNode _focusNode = FocusNode();
  late bool toastColor;

  String? noteTitle;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    super.dispose();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      final myJSON = jsonDecode(_note?.json ?? '');
      initialText = _note?.text ?? '';
      _quillController = QuillController(
        document: Document.fromJson(myJSON),
        selection: const TextSelection.collapsed(offset: 0),
      );
      noteTitle = widgetNote.text;
      return widgetNote;
    }
    _quillController = QuillController.basic();

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;

    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    final text = _quillController.document.toPlainText().trim();
    if (text.isEmpty && note != null) {
      _notesService.deleteNotes(documentId: note.documentId);
      Fluttertoast.showToast(
          msg: 'Can\'t save empty note',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: toastColor?darkBorderTheme:lightBorderTheme,
          textColor: toastColor?darkTextTheme:lightTextTheme,
          fontSize: 16.0);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _quillController.document.toPlainText();
    final json = jsonEncode(_quillController.document.toDelta().toJson());
    DateTime now = DateTime.now();
    String updatedDate = DateFormat('yyyy/MM/dd hh:mm:ss a').format(now);
    if (note != null && text.trim().isNotEmpty) {
      if (initialText == text) {
        await _notesService.updateNotes(
            documentId: note.documentId,
            text: text,
            json: json,
            date: note.date);
      } else {
        await _notesService.updateNotes(
            documentId: note.documentId,
            text: text,
            json: json,
            date: updatedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
    toastColor = isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? darkTheme : lightTheme,
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final widgetNote = context.getArgument<CloudNote>();
            if (widgetNote != null) {
              return Text(
                widgetNote.text,
                maxLines: 1,
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              );
            } else {
              return Text(
                'New Note',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _quillController.document.toPlainText();
              if (_note == null || text.isEmpty) {
                await ShowCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: Icon(
              Icons.share,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: _quillController.document.toPlainText(),
                ),
              );
              Fluttertoast.showToast(
                  msg: "Copied to clipboard",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.yellow.shade900,
                  textColor: Colors.black,
                  fontSize: 16.0);
            },
            icon: Icon(
              Icons.copy,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FutureBuilder(
            future: createOrGetExistingNote(context),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return TextField(
                  enabled: false,
                  minLines: 2,
                  maxLines: 2,
                  
                  decoration:  InputDecoration(
                      hintText:
                          'Error loading, Check your internet connection and try again.',hintStyle: TextStyle(color: isDarkMode?darkTextTheme:lightTextTheme)),
                          
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                  ),
                );
              }
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _quillController.document.changes.listen((event) async {
                    _saveNoteIfTextNotEmpty();
                  });
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        QuillEditor(
                          controller: _quillController,
                          scrollController: ScrollController(),
                          scrollable: true,
                          focusNode: _focusNode,
                          autoFocus: false,
                          readOnly: false,
                          placeholder: 'Start Typing Your Note ...',
                          expands: false,
                          padding: EdgeInsets.zero,
                          customStyles: DefaultStyles(
                            placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                const Tuple2(16, 0),
                                const Tuple2(0, 0),
                                null),
                            h1: DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 32,
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
                                  height: 1.15,
                                  fontWeight: FontWeight.w300,
                                ),
                                const Tuple2(16, 0),
                                const Tuple2(0, 0),
                                null),
                            paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
                                ),
                                const Tuple2(16, 0),
                                const Tuple2(0, 0),
                                null),
                          ),
                        ),
                        const SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  );
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(15.0),
        child: QuillToolbar.basic(controller: _quillController),
      ),
    );
  }
}
