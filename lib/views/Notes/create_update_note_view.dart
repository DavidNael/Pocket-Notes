import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocketnotes/Services/auth/auth_service.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:pocketnotes/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:pocketnotes/utilities/generics/get_arguments.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../Constants/app_theme.dart';

class CreateUpdateView extends StatefulWidget {
  const CreateUpdateView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateView> createState() => _CreateUpdateViewState();
}

class _CreateUpdateViewState extends State<CreateUpdateView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;

  QuillController _quillNoteController = QuillController.basic();
  QuillController _quillTitleController = QuillController.basic();

  String initialText = '';
  String initialTitleText = '';

  final FocusNode _focusNoteNode = FocusNode();
  final FocusNode _focusTitleNode = FocusNode();

  Offset noteOffset = const Offset(0, 0);
  Offset titleOffset = const Offset(0, 0);

  ValueNotifier<bool> isNoteFocused = ValueNotifier<bool>(false);
  
  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  void dispose() {
    _quillNoteController.dispose();
    _quillTitleController.dispose();
    _focusNoteNode.dispose();
    _focusTitleNode.dispose();
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    super.dispose();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      final titleJSON = await jsonDecode(_note?.titleJson ?? '');
      final noteJSON = await jsonDecode(_note?.noteJson ?? '');

      _quillTitleController = QuillController(
          document: Document.fromJson(titleJSON),
          selection: const TextSelection.collapsed(offset: 0));

      _quillNoteController = QuillController(
          document: Document.fromJson(noteJSON),
          selection: const TextSelection.collapsed(offset: 0));

      initialTitleText = _note?.title ?? '';
      initialText = _note?.note ?? '';
      return widgetNote;
    }

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
    bool isDark = AppTheme.prefs.getBool(keyDarkMode) ?? true;
    final note = _note;
    final noteText = _quillNoteController.document.toPlainText().trim();
    final title = _quillTitleController.document.toPlainText().trim();
    if (note != null && noteText.isEmpty && title.isEmpty) {
      _notesService.deleteNotes(documentId: note.documentId);
      Fluttertoast.showToast(
          msg: 'Can\'t save empty note',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: isDark ? darkBorderTheme : lightBorderTheme,
          textColor: isDark ? darkTextTheme : lightTextTheme,
          fontSize: 16.0);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final titleText = _quillTitleController.document.toPlainText();
    final titleJson =
        jsonEncode(_quillTitleController.document.toDelta().toJson());

    final noteText = _quillNoteController.document.toPlainText();
    final noteJson =
        jsonEncode(_quillNoteController.document.toDelta().toJson());
    DateTime now = DateTime.now();
    String updatedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
    if (note != null &&
        (titleText.trim().isNotEmpty || noteText.trim().isNotEmpty)) {
      if (initialText != noteText || initialTitleText != titleText) {
        await _notesService.updateNotes(
            documentId: note.documentId,
            title: titleText,
            titleJson: titleJson,
            note: noteText,
            noteJson: noteJson,
            dateModified: updatedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    return FutureBuilder(
      future: createOrGetExistingNote(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _quillTitleController.document.changes.listen((event) async {
            _saveNoteIfTextNotEmpty();
          });
          _quillNoteController.document.changes.listen((event) async {
            _saveNoteIfTextNotEmpty();
          });
          return Scaffold(
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            bottomSheet: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: isNoteFocused,
                builder: ((context, value, child) {
                  return value
                      ? QuillToolbar.basic(
                          iconTheme: QuillIconTheme(
                            iconSelectedColor:
                                isDarkMode ? darkBorderTheme : lightBorderTheme,
                            iconSelectedFillColor: themeColor,
                            iconUnselectedColor:
                                isDarkMode ? darkTextTheme : lightTextTheme,
                          ),
                          controller: _quillNoteController,
                        )
                      : QuillToolbar.basic(
                          iconTheme: QuillIconTheme(
                            iconSelectedColor:
                                isDarkMode ? darkBorderTheme : lightBorderTheme,
                            iconSelectedFillColor: themeColor,
                            iconUnselectedColor:
                                isDarkMode ? darkTextTheme : lightTextTheme,
                          ),
                          controller: _quillTitleController,
                        );
                }),
              ),
            ),
            appBar: AppBar(
              backgroundColor: themeColor,
              iconTheme: IconThemeData(
                color: isDarkMode ? darkTextTheme : lightTextTheme,
              ),
              title: Builder(
                builder: (context) {
                  final widgetNote = context.getArgument<CloudNote>();
                  if (widgetNote != null) {
                    return Text(
                      widgetNote.title,
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
                    final text = _quillTitleController.document.toPlainText() +
                        _quillNoteController.document.toPlainText();
                    if (_note == null || text.isEmpty) {
                      await showCannotShareEmptyNoteDialog(context);
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
                        text: _quillTitleController.document.toPlainText() +
                            _quillNoteController.document.toPlainText(),
                      ),
                    );
                    Fluttertoast.showToast(
                        msg: "Copied to clipboard",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                            isDarkMode ? darkBorderTheme : lightBorderTheme,
                        textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                        fontSize: 16.0);
                  },
                  icon: Icon(
                    Icons.copy,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 15, left: 10),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: isDarkMode ? darkTheme : lightTheme,
                        ),
                        child: Listener(
                          onPointerDown: (event) {
                            isNoteFocused.value = false;
                          },
                          child: QuillEditor(
                            controller: _quillTitleController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: _focusTitleNode,
                            autoFocus: true,
                            readOnly: false,
                            placeholder: 'Title',
                            expands: false,
                            padding: EdgeInsets.zero,
                            customStyles: DefaultStyles(
                              placeHolder: DefaultTextBlockStyle(
                                  TextStyle(
                                      color: isDarkMode
                                          ? darkTextTheme
                                          : lightTextTheme,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  const Tuple2(16, 0),
                                  const Tuple2(0, 0),
                                  null),
                              h1: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 40,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    height: 1.15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  const Tuple2(16, 0),
                                  const Tuple2(0, 0),
                                  null),
                              h2: DefaultTextBlockStyle(
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
                              h3: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 24,
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
                                    fontSize: 20,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                  ),
                                  const Tuple2(16, 0),
                                  const Tuple2(0, 0),
                                  null),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 15, left: 10),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: isDarkMode ? darkTheme : lightTheme,
                        ),
                        child: Listener(
                          onPointerDown: (event) {
                            isNoteFocused.value = true;
                          },
                          child: QuillEditor(
                            controller: _quillNoteController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: _focusNoteNode,
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
                                    fontSize: 40,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    height: 1.15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  const Tuple2(16, 0),
                                  const Tuple2(0, 0),
                                  null),
                              h2: DefaultTextBlockStyle(
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
                              h3: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 24,
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
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                  ),
                                  const Tuple2(16, 0),
                                  const Tuple2(0, 0),
                                  null),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 200,
                      ),
                    ],
                  ),
                )),
          );
        }
        else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  final widgetNote = context.getArgument<CloudNote>();
                  if (widgetNote != null) {
                    return Text(
                      widgetNote.title,
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
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Error loading, Check your internet connection and try again.',
                style: TextStyle(
                  color: isDarkMode ? darkTextTheme : lightTextTheme,
                  fontSize: 25,
                ),
              ),
            ),
          );
        }
         else {
          return Scaffold(
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  final widgetNote = context.getArgument<CloudNote>();
                  if (widgetNote != null) {
                    return Text(
                      widgetNote.title,
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
            ),
            body: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Loading Note...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? darkTextTheme
                                    : lightTextTheme),
                          ),
                          const CircularProgressIndicator()
                        ],
                      ),
                    )
          );
        }
      },
    );
  }
}
