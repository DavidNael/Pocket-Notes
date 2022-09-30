import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocketnotes/Services/auth/auth_service.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:pocketnotes/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../Constants/app_theme.dart';

class CreateUpdateView extends StatefulWidget {
  final CloudNote? getNote;

  const CreateUpdateView({
    Key? key,
    this.getNote,
  }) : super(key: key);

  @override
  State<CreateUpdateView> createState() => _CreateUpdateViewState();
}

class _CreateUpdateViewState extends State<CreateUpdateView> {
  late final FirebaseCloudStorage _notesService;
  CloudNote? noteCopy;

  QuillController _quillNoteController = QuillController.basic();
  QuillController _quillTitleController = QuillController.basic();

  String initialTitleJson = '';
  String initialNoteJson = '';

  final FocusNode _focusNoteNode = FocusNode();
  final FocusNode _focusTitleNode = FocusNode();

  String? user = AuthService.firebase().currentUser?.id;
  ValueNotifier<int> showToolbar = ValueNotifier<int>(0);

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
    final widgetNote = widget.getNote;
    //! Update Note
    if (widgetNote != null) {
      noteCopy = widgetNote;
      final titleJSON = await jsonDecode(noteCopy!.titleJson);
      final noteJSON = await jsonDecode(noteCopy!.noteJson);

      _quillTitleController = QuillController(
        document: Document.fromJson(titleJSON),
        selection: const TextSelection.collapsed(
          offset: 0,
        ),
      );

      _quillNoteController = QuillController(
        document: Document.fromJson(noteJSON),
        selection: const TextSelection.collapsed(
          offset: 0,
        ),
      );

      initialTitleJson = noteCopy!.titleJson;
      initialNoteJson = noteCopy!.noteJson;
      return widgetNote;
    }

    final existingNote = noteCopy;
    if (existingNote != null) {
      return existingNote;
    }
    //! Create Note
    final newNote = await _notesService.createNewNote(ownerUserId: user!);
    noteCopy = newNote;

    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    bool isDark = AppTheme.prefs.getBool(keyDarkMode) ?? true;
    final note = noteCopy;
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
    final note = noteCopy;
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
      if (initialTitleJson != titleJson || initialNoteJson != noteJson) {
        await _notesService.updateNotes(
          documentId: note.documentId,
          title: titleText,
          titleJson: titleJson,
          note: noteText,
          noteJson: noteJson,
          dateModified: updatedDate,
          isPinned: note.isPinned,
          isArchived: note.isArchived,
          isTrashed: note.isTrashed,
          categories: note.noteCategories,
        );
      } else {
        await _notesService.updateNotes(
          documentId: note.documentId,
          title: titleText,
          titleJson: titleJson,
          note: noteText,
          noteJson: noteJson,
          dateModified: note.dateModified,
          isPinned: note.isPinned,
          isArchived: note.isArchived,
          isTrashed: note.isTrashed,
          categories: note.noteCategories,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    return FutureBuilder(
      future: createOrGetExistingNote(context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            _quillTitleController.document.changes.listen((event) async {
              _saveNoteIfTextNotEmpty();
            });
            _quillNoteController.document.changes.listen((event) async {
              _saveNoteIfTextNotEmpty();
            });

            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor:
                    isDarkMode ? darkBorderTheme : lightBorderTheme,
                appBar: AppBar(
                  title: Builder(
                    builder: (context) {
                      final widgetNote = widget.getNote;
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
            return Scaffold(
              backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
              bottomSheet: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: showToolbar,
                  builder: ((context, value, child) {
                    //! Quill Toolbar
                    return Stack(
                      children: [
                        Visibility(
                          visible: value == 1,
                          child: QuillToolbar.basic(
                            multiRowsDisplay: false,
                            showQuote: false,
                            showInlineCode: false,
                            showCodeBlock: false,
                            dialogTheme: QuillDialogTheme(
                              inputTextStyle: TextStyle(
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                              labelTextStyle: TextStyle(
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                              dialogBackgroundColor: isDarkMode
                                  ? darkBorderTheme
                                  : lightBorderTheme,
                            ),
                            iconTheme: QuillIconTheme(
                              borderRadius: 10,
                              iconSelectedColor: isDarkMode
                                  ? darkBorderTheme
                                  : lightBorderTheme,
                              iconSelectedFillColor: themeColor,
                              iconUnselectedColor:
                                  isDarkMode ? darkTextTheme : lightTextTheme,
                              disabledIconColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                            ),
                            controller: _quillTitleController,
                          ),
                        ),
                        Visibility(
                          visible: value == 2,
                          child: QuillToolbar.basic(
                            multiRowsDisplay: false,
                            showQuote: false,
                            showInlineCode: false,
                            showCodeBlock: false,
                            dialogTheme: QuillDialogTheme(
                              inputTextStyle: TextStyle(
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                              labelTextStyle: TextStyle(
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                              dialogBackgroundColor: isDarkMode
                                  ? darkBorderTheme
                                  : lightBorderTheme,
                            ),
                            iconTheme: QuillIconTheme(
                              borderRadius: 10,
                              iconSelectedColor: isDarkMode
                                  ? darkBorderTheme
                                  : lightBorderTheme,
                              iconSelectedFillColor: themeColor,
                              iconUnselectedColor:
                                  isDarkMode ? darkTextTheme : lightTextTheme,
                              disabledIconColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                            ),
                            controller: _quillNoteController,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: themeColor,
                title: Builder(
                  builder: (context) {
                    final widgetNote = widget.getNote;

                    if (widgetNote != null) {
                      return Text(
                        widgetNote.title.trim().isNotEmpty
                            ? widgetNote.title.trim()
                            : 'Untitled',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      );
                    } else {
                      return const Text(
                        'New Note',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),
                actions: [
                  //!Share Button
                  IconButton(
                    onPressed: () async {
                      final text =
                          _quillTitleController.document.toPlainText() +
                              _quillNoteController.document.toPlainText();
                      if (noteCopy == null || text.isEmpty) {
                        await showCannotShareEmptyNoteDialog(context);
                      } else {
                        Share.share(text);
                      }
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.black,
                    ),
                  ),
                  //!Copy Button
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
                          textColor:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                          fontSize: 16.0);
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.black,
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
                          padding: const EdgeInsets.all(15),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.grey.shade500,
                                  width: 2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            color: isDarkMode ? darkTheme : lightTheme,
                          ),
                          child: QuillEditor(
                            onTapDown: (details, p1) {
                              showToolbar.value = 1;
                              return false;
                            },
                            controller: _quillTitleController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: _focusTitleNode,
                            linkActionPickerDelegate: (context, link, node) {
                              return Future<LinkMenuAction>(
                                () {
                                  Future<LinkMenuAction> _showMaterialMenu(
                                      BuildContext context, String link) async {
                                    final result = await showModalBottomSheet<
                                        LinkMenuAction>(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      context: context,
                                      builder: (ctx) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            //!Open Link button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.language_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Open Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.launch),
                                              trailing: Icon(
                                                size: 15,
                                                Icons.arrow_forward_ios,
                                                color: themeColor,
                                              ),
                                            ),
                                            //! Copy Link Button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.copy_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Copy Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.copy),
                                              trailing: null,
                                            ),
                                            //!Remove link Button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.link_off_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Remove Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.remove),
                                              trailing: null,
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    return result ?? LinkMenuAction.none;
                                  }

                                  return _showMaterialMenu(context, link);
                                },
                              );
                            },
                            autoFocus: false,
                            readOnly: false,
                            placeholder: 'Title',
                            expands: false,
                            padding: EdgeInsets.zero,
                            customStyles: DefaultStyles(
                              link: const TextStyle(
                                color: Colors.blue,
                              ),
                              lists: DefaultListBlockStyle(
                                const TextStyle(),
                                const Tuple2<double, double>(6.0, 0.0),
                                const Tuple2<double, double>(0.0, 6.0),
                                null,
                                const CustomCheckBox(),
                              ),
                              leading: DefaultTextBlockStyle(
                                TextStyle(
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                                const Tuple2(0, 0),
                                const Tuple2(0, 0),
                                null,
                              ),
                              placeHolder: DefaultTextBlockStyle(
                                TextStyle(
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                                const Tuple2(0, 0),
                                const Tuple2(0, 0),
                                null,
                              ),
                              h1: DefaultTextBlockStyle(
                                  TextStyle(
                                    fontSize: 40,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    height: 1.15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  const Tuple2(0, 0),
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
                                  const Tuple2(0, 0),
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
                                  const Tuple2(0, 0),
                                  const Tuple2(0, 0),
                                  null),
                              paragraph: DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 20,
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
                                ),
                                const Tuple2(0, 0),
                                const Tuple2(0, 0),
                                null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.grey.shade500,
                                  width: 2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            color: isDarkMode ? darkTheme : lightTheme,
                          ),
                          child: QuillEditor(
                            onTapDown: (details, p1) {
                              showToolbar.value = 2;
                              return false;
                            },
                            controller: _quillNoteController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: _focusNoteNode,
                            autoFocus: false,
                            readOnly: false,
                            placeholder: 'Start Typing Your Note ...',
                            expands: false,
                            padding: EdgeInsets.zero,
                            linkActionPickerDelegate: (context, link, node) {
                              return Future<LinkMenuAction>(
                                () {
                                  Future<LinkMenuAction> _showMaterialMenu(
                                      BuildContext context, String link) async {
                                    final result = await showModalBottomSheet<
                                        LinkMenuAction>(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      context: context,
                                      builder: (ctx) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            //!Open Link button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.language_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Open Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.launch),
                                              trailing: Icon(
                                                size: 15,
                                                Icons.arrow_forward_ios,
                                                color: themeColor,
                                              ),
                                            ),
                                            //! Copy Link Button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.copy_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Copy Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.copy),
                                              trailing: null,
                                            ),
                                            //!Remove link Button
                                            SettingsTile(
                                              isEnabled: true,
                                              isSelected: false,
                                              icon: Icons.link_off_sharp,
                                              circleColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : themeColor,
                                              iconColor: isDarkMode
                                                  ? themeColor
                                                  : Colors.white,
                                              tileColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              borderColor: isDarkMode
                                                  ? darkBorderTheme
                                                  : lightBorderTheme,
                                              title: 'Remove Link',
                                              textColor: isDarkMode
                                                  ? darkTextTheme
                                                  : lightTextTheme,
                                              subtitle: null,
                                              onTap: () => Navigator.of(context)
                                                  .pop(LinkMenuAction.remove),
                                              trailing: null,
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    return result ?? LinkMenuAction.none;
                                  }

                                  return _showMaterialMenu(context, link);
                                },
                              );
                            },
                            customStyles: DefaultStyles(
                              link: const TextStyle(
                                color: Colors.blue,
                              ),
                              lists: DefaultListBlockStyle(
                                const TextStyle(),
                                const Tuple2<double, double>(6.0, 0.0),
                                const Tuple2<double, double>(6.0, 0.0),
                                null,
                                const CustomCheckBox(),
                              ),
                              leading: DefaultTextBlockStyle(
                                TextStyle(
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                const Tuple2(0, 0),
                                const Tuple2(0, 0),
                                null,
                              ),
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
                                  const Tuple2(8, 0),
                                  const Tuple2(0, 0),
                                  null),
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
          default:
            return Scaffold(
              backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
              appBar: AppBar(
                title: Builder(
                  builder: (context) {
                    final widgetNote = widget.getNote;
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
                          color: isDarkMode ? darkTextTheme : lightTextTheme),
                    ),
                    const CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
