import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_user.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:pocketnotes/utilities/dialogs/select_category.dart';
import 'package:pocketnotes/utilities/dialogs/info_dialog.dart';
import 'package:pocketnotes/views/Constants/custom_classes.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:pocketnotes/views/Notes/create_update_note_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Services/auth/auth_service.dart';
import '../../utilities/dialogs/cannot_share_empty_dialog.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../Constants/app_theme.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  updateProfilePicture(File file) async {
    setState(() {
      uploading = true;
    });
    await FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${Uri.file(file.path).pathSegments.last}')
        .putFile(file)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        setState(() {
          uploading = false;
          user;
        });
        _notesService.updateUser(
          documentId: user.documentId,
          userName: user.userName,
          userImage: value,
          userPhone: user.userPhone,
          userCategories: user.userCategories,
        );
      });
    });
  }

  bool uploading = false;
  late final FirebaseCloudStorage _notesService;
  late CloudUser user;
  String get userId => AuthService.firebase().currentUser!.id;
  DateTime? lastPressed;
  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<bool> getUser() async {
    if (await _notesService.checkUser(ownerUserId: userId)) {
      user = await _notesService.getUser(ownerUserId: userId);
    } else {
      user = await _notesService.createNewUser(
          ownerUserId: userId, username: 'Default');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool isDrawerOpened = false;
    int filterOption = Provider.of<AppTheme>(context).filterOption;
    int dateFormatOption = Provider.of<AppTheme>(context).dateFormatOption;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    bool isList = Provider.of<AppTheme>(context).isList;
    bool isHourFormat = Provider.of<AppTheme>(context).hourFormat;
    return WillPopScope(
      onWillPop: () async {
        if (isDrawerOpened) {
          Navigator.pop(context);
          return false;
        }
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
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            textColor: isDarkMode ? darkTextTheme : lightTextTheme,
            fontSize: 16.0,
          );
          return false;
        } else {
          return true;
        }
      },
      child: FutureBuilder(
          future: getUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              GlobalKey addNoteButton =
                  GlobalKey(debugLabel: 'Add-Note-Button');
              return Scaffold(
                backgroundColor:
                    isDarkMode ? darkBorderTheme : lightBorderTheme,
                floatingActionButton: Material(
                  key: addNoteButton,
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(200, 0, 0, 0),
                        width: 6.0,
                      ),
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(500.0),
                      onTap: () {
                        {
                          RenderBox box = addNoteButton.currentContext
                              ?.findRenderObject() as RenderBox;
                          Offset position = box.localToGlobal(
                              Offset.zero); //this is global position
                          final x = position.dx + (box.size.width / 2);
                          final y = position.dy + (box.size.height / 2);
                          Navigator.of(context).push(
                            ScalePageTransition(
                              x: x,
                              y: y,
                              child: const CreateUpdateView(),
                            ),
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.add,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                // bottomNavigationBar: Container(
                //   height: 64,
                //   color: Colors.black,
                // ),
                drawerEdgeDragWidth: 150,
                onDrawerChanged: (isOpened) {
                  isDrawerOpened = isOpened;
                },
                drawer: AppDrawer(
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                  user: user,
                  notesService: _notesService,
                  isHomeEnabled: false,
                  isHomeSelected: true,
                  updateProfile: updateProfilePicture,
                  uploading: uploading,
                ),
                appBar: AppBar(
                  centerTitle: true,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Pocket Notes',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Provider.of<AppTheme>(context, listen: false)
                            .setNoteView(option: !isList);
                        AppTheme.prefs.setBool(keyNotesViewOption, !isList);
                      },
                      icon: Icon(
                        isList ? Icons.list : Icons.grid_view,
                      ),
                    )
                  ],
                ),
                body: SafeArea(
                  child: StreamBuilder(
                    stream: _notesService.allNotes(ownerUserId: userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        if (allNotes.isEmpty) {
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No Notes Available...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return OrientationBuilder(
                              builder: (context, orientation) {
                            final notesList = allNotes.toList();
                            sortNotes(
                              notes: notesList,
                              filterOption: filterOption,
                            );

                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                //!Grid View
                                Visibility(
                                  visible: !isList,
                                  child: GridView.builder(
                                    itemCount: allNotes.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          orientation == Orientation.portrait
                                              ? 2
                                              : 3,
                                      mainAxisExtent:
                                          orientation == Orientation.portrait
                                              ? 200
                                              : 250,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                    ),
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      bottom: 100,
                                      top: 15,
                                    ),
                                    itemBuilder: (context, index) {
                                      final List<GlobalKey<FormState>>
                                          keyGridNote = List.generate(
                                        allNotes.length,
                                        (index) => GlobalKey(),
                                      );

                                      final note = notesList[index];
                                      final String noteDateCreated = formatDate(
                                        date: note.dateCreated,
                                        formatOption: dateFormatOption,
                                        isHourFormat: isHourFormat,
                                      );
                                      final String noteDateModified =
                                          formatDate(
                                        date: note.dateModified,
                                        formatOption: dateFormatOption,
                                        isHourFormat: isHourFormat,
                                      );
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              //!Note Tile
                                              Material(
                                                key: keyGridNote[index],
                                                type: MaterialType.transparency,
                                                child: Ink(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: ShapeDecoration(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        color: isDarkMode
                                                            ? Colors.black
                                                            : Colors
                                                                .grey.shade500,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    color: themeColor,
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    onLongPress: () {
                                                      showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    20),
                                                          ),
                                                        ),
                                                        context: context,
                                                        builder: (context) {
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              const SizedBox(
                                                                height: 25,
                                                              ),
                                                              //!Pin Button
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon: Icons
                                                                    .push_pin,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title: note
                                                                        .isPinned
                                                                    ? 'Unpin'
                                                                    : 'Pin',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  _notesService
                                                                      .updateNotes(
                                                                    documentId:
                                                                        note.documentId,
                                                                    title: note
                                                                        .title,
                                                                    titleJson: note
                                                                        .titleJson,
                                                                    note: note
                                                                        .note,
                                                                    noteJson: note
                                                                        .noteJson,
                                                                    dateModified:
                                                                        note.dateModified,
                                                                    isPinned: !note
                                                                        .isPinned,
                                                                    isArchived:
                                                                        note.isArchived,
                                                                    isTrashed: note
                                                                        .isTrashed,
                                                                    categories:
                                                                        note.noteCategories,
                                                                  );
                                                                  sortNotes(
                                                                    notes:
                                                                        notesList,
                                                                    filterOption:
                                                                        filterOption,
                                                                  );
                                                                },
                                                              ),

                                                              //!Category Button
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon: Icons
                                                                    .category,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title:
                                                                    'Category',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  selectCategory(
                                                                    context,
                                                                    title:
                                                                        'Choose Note Categories:',
                                                                    notesService:
                                                                        _notesService,
                                                                    user: user,
                                                                    note: note,
                                                                    isDarkMode:
                                                                        isDarkMode,
                                                                  );
                                                                },
                                                              ),

                                                              //!Archive Button
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon: Icons
                                                                    .archive,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title:
                                                                    'Archive',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  _notesService
                                                                      .updateNotes(
                                                                    documentId:
                                                                        note.documentId,
                                                                    title: note
                                                                        .title,
                                                                    titleJson: note
                                                                        .titleJson,
                                                                    note: note
                                                                        .note,
                                                                    noteJson: note
                                                                        .noteJson,
                                                                    dateModified:
                                                                        note.dateModified,
                                                                    isPinned: note
                                                                        .isPinned,
                                                                    isArchived:
                                                                        true,
                                                                    isTrashed:
                                                                        false,
                                                                    categories:
                                                                        note.noteCategories,
                                                                  );
                                                                },
                                                              ),

                                                              //!Trash Buttton
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon: Icons
                                                                    .delete,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title: 'Delete',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap:
                                                                    () async {
                                                                  final shouldDelete =
                                                                      await showDeleteDialog(
                                                                    context,
                                                                    'Delete Note',
                                                                    'Are you sure you want to trash this note?',
                                                                  );
                                                                  if (shouldDelete) {
                                                                    Navigator
                                                                        .pop(
                                                                      context,
                                                                    );
                                                                    _notesService
                                                                        .updateNotes(
                                                                      documentId:
                                                                          note.documentId,
                                                                      title: note
                                                                          .title,
                                                                      titleJson:
                                                                          note.titleJson,
                                                                      note: note
                                                                          .note,
                                                                      noteJson:
                                                                          note.noteJson,
                                                                      dateModified:
                                                                          note.dateModified,
                                                                      isPinned:
                                                                          note.isPinned,
                                                                      isArchived:
                                                                          false,
                                                                      isTrashed:
                                                                          true,
                                                                      categories:
                                                                          note.noteCategories,
                                                                    );
                                                                  }
                                                                },
                                                              ),

                                                              //!Share Buttton
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon:
                                                                    Icons.share,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title: 'Share',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap:
                                                                    () async {
                                                                  final text = note
                                                                          .title +
                                                                      note.note;
                                                                  if (text
                                                                      .trim()
                                                                      .isEmpty) {
                                                                    await showCannotShareEmptyNoteDialog(
                                                                        context);
                                                                  } else {
                                                                    Share.share(
                                                                        text);
                                                                  }
                                                                },
                                                              ),

                                                              //!Info Buttton
                                                              SettingsTile(
                                                                isEnabled: true,
                                                                isSelected:
                                                                    false,
                                                                icon:
                                                                    Icons.info,
                                                                circleColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : themeColor,
                                                                iconColor: isDarkMode
                                                                    ? themeColor
                                                                    : Colors
                                                                        .white,
                                                                tileColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                borderColor: isDarkMode
                                                                    ? darkBorderTheme
                                                                    : lightBorderTheme,
                                                                title: 'Info',
                                                                textColor: isDarkMode
                                                                    ? darkTextTheme
                                                                    : lightTextTheme,
                                                                subtitle: null,
                                                                trailing: null,
                                                                onTap: () {
                                                                  showInfoDialog(
                                                                    context,
                                                                    title:
                                                                        'Info',
                                                                    content:
                                                                        'Modified On: $noteDateModified\n\nCreated On: $noteDateCreated',
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    onTap: () {
                                                      RenderBox box = keyGridNote[
                                                                  index]
                                                              .currentContext
                                                              ?.findRenderObject()
                                                          as RenderBox;
                                                      Offset position = box
                                                          .localToGlobal(Offset
                                                              .zero); //this is global position
                                                      final x = position.dx +
                                                          (box.size.width / 2);
                                                      final y = position.dy +
                                                          (box.size.height / 2);
                                                      Navigator.of(context)
                                                          .push(
                                                        ScalePageTransition(
                                                          x: x,
                                                          y: y,
                                                          endDuration: 0,
                                                          child:
                                                              CreateUpdateView(
                                                            getNote: note,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          //!Title
                                                          Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5,
                                                                    bottom: 10),
                                                            child: Text(
                                                              note.title
                                                                      .trim()
                                                                      .isNotEmpty
                                                                  ? note.title
                                                                      .trim()
                                                                  : 'Untitled',
                                                              maxLines: 1,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textScaleFactor:
                                                                  1.2,
                                                              style: TextStyle(
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .grey
                                                                        .shade300
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          //!Note
                                                          Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 5,
                                                              bottom: 5,
                                                            ),
                                                            child: Text(
                                                              note.note
                                                                      .trim()
                                                                      .isNotEmpty
                                                                  ? note.note
                                                                  : 'Empty Note...',
                                                              maxLines: orientation ==
                                                                      Orientation
                                                                          .portrait
                                                                  ? 7
                                                                  : 10,
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textScaleFactor:
                                                                  0.9,
                                                              style: TextStyle(
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .grey
                                                                        .shade300
                                                                    : Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              //!Pinned Icon
                                              Container(
                                                alignment: Alignment.topRight,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Transform.rotate(
                                                  angle: 45,
                                                  child: note.isPinned
                                                      ? Icon(
                                                          Icons.push_pin,
                                                          color: isDarkMode
                                                              ? darkTextTheme
                                                              : lightTextTheme,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                //!List View
                                Visibility(
                                  visible: isList,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      bottom: 100,
                                      top: 15,
                                    ),
                                    itemCount: allNotes.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(),
                                    itemBuilder: (context, index) {
                                      final List<GlobalKey<FormState>>
                                          keyListNote = List.generate(
                                        allNotes.length,
                                        (index) => GlobalKey(),
                                      );
                                      final note = notesList[index];
                                      final String noteDateCreated = formatDate(
                                        date: note.dateCreated,
                                        formatOption: dateFormatOption,
                                        isHourFormat: isHourFormat,
                                      );
                                      final String noteDateModified =
                                          formatDate(
                                        date: note.dateModified,
                                        formatOption: dateFormatOption,
                                        isHourFormat: isHourFormat,
                                      );
                                      return Stack(
                                        children: [
                                          //!Note Tile
                                          ListTile(
                                            key: keyListNote[index],
                                            tileColor: themeColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: isDarkMode
                                                    ? Colors.black
                                                    : Colors.grey.shade500,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            onTap: () {
                                              RenderBox box = keyListNote[index]
                                                      .currentContext
                                                      ?.findRenderObject()
                                                  as RenderBox;
                                              Offset position =
                                                  box.localToGlobal(Offset
                                                      .zero); //this is global position
                                              final x = position.dx +
                                                  (box.size.width / 2);
                                              final y = position.dy +
                                                  (box.size.height / 2);
                                              Navigator.of(context).push(
                                                ScalePageTransition(
                                                  x: x,
                                                  y: y,
                                                  endDuration: 0,
                                                  child: CreateUpdateView(
                                                    getNote: note,
                                                  ),
                                                ),
                                              );
                                            },
                                            onLongPress: () {
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                context: context,
                                                builder: (context) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const SizedBox(
                                                        height: 25,
                                                      ),
                                                      //!Pin Button
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.push_pin,
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
                                                        title: note.isPinned
                                                            ? 'Unpin'
                                                            : 'Pin',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _notesService
                                                              .updateNotes(
                                                            documentId:
                                                                note.documentId,
                                                            title: note.title,
                                                            titleJson:
                                                                note.titleJson,
                                                            note: note.note,
                                                            noteJson:
                                                                note.noteJson,
                                                            dateModified: note
                                                                .dateModified,
                                                            isPinned:
                                                                !note.isPinned,
                                                            isArchived:
                                                                note.isArchived,
                                                            isTrashed:
                                                                note.isTrashed,
                                                            categories: note
                                                                .noteCategories,
                                                          );
                                                          sortNotes(
                                                            notes: notesList,
                                                            filterOption:
                                                                filterOption,
                                                          );
                                                        },
                                                      ),

                                                      //!Category Button
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.category,
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
                                                        title: 'Category',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          selectCategory(
                                                            context,
                                                            title:
                                                                'Choose Note Categories:',
                                                            notesService:
                                                                _notesService,
                                                            user: user,
                                                            note: note,
                                                            isDarkMode:
                                                                isDarkMode,
                                                          );
                                                        },
                                                      ),

                                                      //!Archive Button
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.archive,
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
                                                        title: 'Archive',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _notesService
                                                              .updateNotes(
                                                            documentId:
                                                                note.documentId,
                                                            title: note.title,
                                                            titleJson:
                                                                note.titleJson,
                                                            note: note.note,
                                                            noteJson:
                                                                note.noteJson,
                                                            dateModified: note
                                                                .dateModified,
                                                            isPinned:
                                                                note.isPinned,
                                                            isArchived: true,
                                                            isTrashed: false,
                                                            categories: note
                                                                .noteCategories,
                                                          );
                                                        },
                                                      ),

                                                      //!Trash Buttton
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.delete,
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
                                                        title: 'Delete',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () async {
                                                          final shouldDelete =
                                                              await showDeleteDialog(
                                                            context,
                                                            'Delete Note',
                                                            'Are you sure you want to trash this note?',
                                                          );
                                                          if (shouldDelete) {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            _notesService
                                                                .updateNotes(
                                                              documentId: note
                                                                  .documentId,
                                                              title: note.title,
                                                              titleJson: note
                                                                  .titleJson,
                                                              note: note.note,
                                                              noteJson:
                                                                  note.noteJson,
                                                              dateModified: note
                                                                  .dateModified,
                                                              isPinned:
                                                                  note.isPinned,
                                                              isArchived: false,
                                                              isTrashed: true,
                                                              categories: note
                                                                  .noteCategories,
                                                            );
                                                          }
                                                        },
                                                      ),

                                                      //!Share Buttton
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.share,
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
                                                        title: 'Share',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () async {
                                                          final text =
                                                              note.title +
                                                                  note.note;
                                                          if (text
                                                              .trim()
                                                              .isEmpty) {
                                                            await showCannotShareEmptyNoteDialog(
                                                                context);
                                                          } else {
                                                            Share.share(text);
                                                          }
                                                        },
                                                      ),

                                                      //!Info Buttton
                                                      SettingsTile(
                                                        isEnabled: true,
                                                        isSelected: false,
                                                        icon: Icons.info,
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
                                                        title: 'Info',
                                                        textColor: isDarkMode
                                                            ? darkTextTheme
                                                            : lightTextTheme,
                                                        subtitle: null,
                                                        trailing: null,
                                                        onTap: () {
                                                          showInfoDialog(
                                                            context,
                                                            title: 'Info',
                                                            content:
                                                                'Modified On: $noteDateModified\n\nCreated On: $noteDateCreated',
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Text(
                                                note.title.trim().isNotEmpty
                                                    ? note.title
                                                    : 'Untitled',
                                                maxLines: 1,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey.shade300
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 5,
                                                  ),
                                                  child: Text(
                                                    note.note.trim().isNotEmpty
                                                        ? note.note
                                                        : 'Empty Note...',
                                                    maxLines: orientation ==
                                                            Orientation.portrait
                                                        ? 2
                                                        : 4,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor: 0.9,
                                                    style: TextStyle(
                                                      color: isDarkMode
                                                          ? Colors.grey.shade300
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //!Pinned Icon
                                          Container(
                                            alignment: Alignment.topRight,
                                            padding: const EdgeInsets.all(5),
                                            child: Transform.rotate(
                                              angle: 45,
                                              child: note.isPinned
                                                  ? Icon(
                                                      Icons.push_pin,
                                                      color: isDarkMode
                                                          ? darkTextTheme
                                                          : lightTextTheme,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          });
                        }
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error Loading Notes..',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme),
                              ),
                            ],
                          ),
                        );
                      }
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Loading Notes...',
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
                      );
                    },
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Scaffold(
                backgroundColor:
                    isDarkMode ? darkBorderTheme : lightBorderTheme,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: Container(
                  height: 64,
                  color: Colors.black,
                ),
                appBar: AppBar(
                  centerTitle: true,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Pocket Notes',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error Loading Notes..',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? darkTextTheme : lightTextTheme),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor:
                    isDarkMode ? darkBorderTheme : lightBorderTheme,
                floatingActionButton: Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode ? darkBorderTheme : lightBorderTheme,
                        width: 6.0,
                      ),
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(500.0),
                      onTap: () {
                        Navigator.of(context).push(
                          ScalePageTransition(
                            child: const CreateUpdateView(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.add,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: Container(
                  height: 64,
                  color: Colors.black,
                ),
                appBar: AppBar(
                  centerTitle: true,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Pocket Notes',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Provider.of<AppTheme>(context, listen: false)
                            .setNoteView(option: !isList);
                        AppTheme.prefs.setBool(keyNotesViewOption, !isList);
                      },
                      icon: Icon(
                        isList ? Icons.list : Icons.grid_view,
                      ),
                    )
                  ],
                ),
                body: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Loading Notes...',
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
          }),
    );
  }
}
