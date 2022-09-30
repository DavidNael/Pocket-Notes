import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocketnotes/Services/cloud/cloud_user.dart';
import 'package:pocketnotes/utilities/dialogs/add_category.dart';
import 'package:pocketnotes/utilities/dialogs/rename_category.dart';
import 'package:pocketnotes/views/Constants/custom_classes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Services/auth/auth_service.dart';
import '../../Services/cloud/cloud_note.dart';
import '../../Services/cloud/firebase_cloud_storage.dart';
import '../../utilities/dialogs/cannot_share_empty_dialog.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../../utilities/dialogs/info_dialog.dart';
import '../../utilities/dialogs/select_category.dart';
import '../Constants/app_theme.dart';
import 'create_update_note_view.dart';

class CategoryNotesView extends StatefulWidget {
  const CategoryNotesView({Key? key}) : super(key: key);

  @override
  State<CategoryNotesView> createState() => _CategoryNotesViewState();
}

class _CategoryNotesViewState extends State<CategoryNotesView> {
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
  File? userImage;
  int selectedButton = -1;
  String noteCategory = '';
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
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    bool isDrawerOpened = false;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isList = Provider.of<AppTheme>(context).isList;
    bool isHourFormat = Provider.of<AppTheme>(context).hourFormat;
    int filterOption = Provider.of<AppTheme>(context).filterOption;
    int dateFormatOption = Provider.of<AppTheme>(context).dateFormatOption;
    Stream<Iterable<CloudNote>> getNotes(String category) {
      return _notesService.allNotesCategory(
          ownerUserId: user.ownerUserId, category: category);
    }

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
              return Scaffold(
                backgroundColor:
                    isDarkMode ? darkBorderTheme : lightBorderTheme,
                drawerEdgeDragWidth: 50,
                onDrawerChanged: (isOpened) {
                  isDrawerOpened = isOpened;
                },
                drawer: AppDrawer(
                  isDarkMode: isDarkMode,
                  themeColor: themeColor,
                  user: user,
                  notesService: _notesService,
                  isCategoryEnabled: false,
                  isCategorySelected: true,
                  updateProfile: updateProfilePicture,
                  uploading: uploading,
                ),
                appBar: AppBar(
                  centerTitle: true,
                  iconTheme: const IconThemeData(
                    color: Colors.black,
                  ),
                  title: const Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    final userCategories = user.userCategories;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //!Categories Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //!user Categories
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List<Widget>.generate(
                                  userCategories.length,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              selectedButton == index
                                                  ? null
                                                  : isDarkMode
                                                      ? darkTheme
                                                      : Colors.grey.shade500,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            noteCategory =
                                                userCategories[index];
                                            selectedButton = index;
                                          });
                                        },
                                        onLongPress: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  //!Rename Button
                                                  SettingsTile(
                                                    icon: Icons.edit,
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
                                                    title: 'Rename',
                                                    textColor: isDarkMode
                                                        ? darkTextTheme
                                                        : lightTextTheme,
                                                    subtitle: null,
                                                    trailing: null,
                                                    onTap: () async {
                                                      final oldName =
                                                          user.userCategories[
                                                              index];
                                                      final newName =
                                                          await renameCategory(
                                                        context,
                                                        title:
                                                            'Rename Category',
                                                        notesService:
                                                            _notesService,
                                                        user: user,
                                                        index: index,
                                                        isDarkMode: isDarkMode,
                                                        themeColor: themeColor,
                                                      );
                                                      await _notesService
                                                          .renameCategory(
                                                        ownerUserId:
                                                            user.ownerUserId,
                                                        oldCategory: oldName,
                                                        newCategory: newName,
                                                      );
                                                      if (selectedButton ==
                                                          index) {
                                                        setState(() {
                                                          noteCategory =
                                                              newName;
                                                        });
                                                      } else {
                                                        setState(() {});
                                                      }
                                                      // Future.delayed(
                                                      //   const Duration(
                                                      //       seconds: 1),
                                                      //   () {
                                                      //   },
                                                      // );
                                                    },
                                                  ),
                                                  //!Delete Buttton
                                                  SettingsTile(
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
                                                    title: 'Remove Category',
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
                                                        'Are you sure you want to delete this category?',
                                                      );
                                                      if (shouldDelete) {
                                                        await _notesService
                                                            .deleteCategory(
                                                          ownerUserId:
                                                              user.ownerUserId,
                                                          categoryName:
                                                              user.userCategories[
                                                                  index],
                                                        );
                                                        List<dynamic> newList =
                                                            user.userCategories;
                                                        newList.removeAt(index);
                                                        await _notesService
                                                            .updateUser(
                                                                documentId: user
                                                                    .documentId,
                                                                userName: user
                                                                    .userName,
                                                                userImage: user
                                                                    .userImage,
                                                                userPhone: user
                                                                    .userPhone,
                                                                userCategories:
                                                                    newList);
                                                        if (selectedButton ==
                                                            index) {
                                                          setState(() {
                                                            noteCategory = '';
                                                          });
                                                        } else {
                                                          setState(() {});
                                                        }
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          userCategories[index],
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? darkTextTheme
                                                : lightTextTheme,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              //!Add Category Button
                              TextButton.icon(
                                onPressed: () async {
                                  await addCategory(
                                    context,
                                    title: 'Add New Category',
                                    notesService: _notesService,
                                    user: user,
                                    isDarkMode: isDarkMode,
                                    themeColor: themeColor,
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Add Category',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //!Categories Note

                        Expanded(
                          child: StreamBuilder(
                            stream: getNotes(noteCategory),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (userCategories.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No Categories Yet...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme),
                                    ),
                                  );
                                }
                                final allNotes =
                                    snapshot.data as Iterable<CloudNote>;
                                if (allNotes.isEmpty) {
                                  return Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          selectedButton == -1
                                              ? 'Choose Category'
                                              : 'No Notes Available...',
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
                                              crossAxisCount: orientation ==
                                                      Orientation.portrait
                                                  ? 2
                                                  : 3,
                                              mainAxisExtent: orientation ==
                                                      Orientation.portrait
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
                                              final String noteDateCreated =
                                                  formatDate(
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
                                                        type: MaterialType
                                                            .transparency,
                                                        child: Ink(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          decoration:
                                                              ShapeDecoration(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .grey
                                                                        .shade500,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            color: themeColor,
                                                          ),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                                    top: Radius
                                                                        .circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            25,
                                                                      ),
                                                                      //!Pin Button
                                                                      SettingsTile(
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .push_pin,
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
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .pop(
                                                                            context,
                                                                          );
                                                                          _notesService
                                                                              .updateNotes(
                                                                            documentId:
                                                                                note.documentId,
                                                                            title:
                                                                                note.title,
                                                                            titleJson:
                                                                                note.titleJson,
                                                                            note:
                                                                                note.note,
                                                                            noteJson:
                                                                                note.noteJson,
                                                                            dateModified:
                                                                                note.dateModified,
                                                                            isPinned:
                                                                                !note.isPinned,
                                                                            isArchived:
                                                                                note.isArchived,
                                                                            isTrashed:
                                                                                note.isTrashed,
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
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .category,
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
                                                                        title:
                                                                            'Category',
                                                                        textColor: isDarkMode
                                                                            ? darkTextTheme
                                                                            : lightTextTheme,
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .pop(
                                                                            context,
                                                                          );
                                                                          selectCategory(
                                                                            context,
                                                                            title:
                                                                                'Choose Note Categories:',
                                                                            notesService:
                                                                                _notesService,
                                                                            user:
                                                                                user,
                                                                            note:
                                                                                note,
                                                                            isDarkMode:
                                                                                isDarkMode,
                                                                          );
                                                                        },
                                                                      ),

                                                                      //!Archive Button
                                                                      SettingsTile(
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .archive,
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
                                                                        title:
                                                                            'Archive',
                                                                        textColor: isDarkMode
                                                                            ? darkTextTheme
                                                                            : lightTextTheme,
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .pop(
                                                                            context,
                                                                          );
                                                                          _notesService
                                                                              .updateNotes(
                                                                            documentId:
                                                                                note.documentId,
                                                                            title:
                                                                                note.title,
                                                                            titleJson:
                                                                                note.titleJson,
                                                                            note:
                                                                                note.note,
                                                                            noteJson:
                                                                                note.noteJson,
                                                                            dateModified:
                                                                                note.dateModified,
                                                                            isPinned:
                                                                                note.isPinned,
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
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .delete,
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
                                                                        title:
                                                                            'Delete',
                                                                        textColor: isDarkMode
                                                                            ? darkTextTheme
                                                                            : lightTextTheme,
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () async {
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
                                                                            _notesService.updateNotes(
                                                                              documentId: note.documentId,
                                                                              title: note.title,
                                                                              titleJson: note.titleJson,
                                                                              note: note.note,
                                                                              noteJson: note.noteJson,
                                                                              dateModified: note.dateModified,
                                                                              isPinned: note.isPinned,
                                                                              isArchived: false,
                                                                              isTrashed: true,
                                                                              categories: note.noteCategories,
                                                                            );
                                                                          }
                                                                        },
                                                                      ),

                                                                      //!Share Buttton
                                                                      SettingsTile(
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .share,
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
                                                                        title:
                                                                            'Share',
                                                                        textColor: isDarkMode
                                                                            ? darkTextTheme
                                                                            : lightTextTheme,
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () async {
                                                                          final text =
                                                                              note.title + note.note;
                                                                          if (text
                                                                              .trim()
                                                                              .isEmpty) {
                                                                            await showCannotShareEmptyNoteDialog(context);
                                                                          } else {
                                                                            Share.share(text);
                                                                          }
                                                                        },
                                                                      ),

                                                                      //!Info Buttton
                                                                      SettingsTile(
                                                                        isEnabled:
                                                                            true,
                                                                        isSelected:
                                                                            false,
                                                                        icon: Icons
                                                                            .info,
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
                                                                        title:
                                                                            'Info',
                                                                        textColor: isDarkMode
                                                                            ? darkTextTheme
                                                                            : lightTextTheme,
                                                                        subtitle:
                                                                            null,
                                                                        trailing:
                                                                            null,
                                                                        onTap:
                                                                            () {
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
                                                              Offset position =
                                                                  box.localToGlobal(
                                                                      Offset
                                                                          .zero); //this is global position
                                                              final x = position
                                                                      .dx +
                                                                  (box.size
                                                                          .width /
                                                                      2);
                                                              final y = position
                                                                      .dy +
                                                                  (box.size
                                                                          .height /
                                                                      2);
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                ScalePageTransition(
                                                                  x: x,
                                                                  y: y,
                                                                  endDuration:
                                                                      0,
                                                                  child:
                                                                      CreateUpdateView(
                                                                    getNote:
                                                                        note,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      20.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  //!Title
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            10),
                                                                    child: Text(
                                                                      note.title
                                                                              .trim()
                                                                              .isNotEmpty
                                                                          ? note
                                                                              .title
                                                                              .trim()
                                                                          : 'Untitled',
                                                                      maxLines:
                                                                          1,
                                                                      softWrap:
                                                                          true,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textScaleFactor:
                                                                          1.2,
                                                                      style:
                                                                          TextStyle(
                                                                        color: isDarkMode
                                                                            ? Colors.grey.shade300
                                                                            : Colors.black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  //!Note
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
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
                                                                          ? note
                                                                              .note
                                                                          : 'Empty Note...',
                                                                      maxLines: orientation ==
                                                                              Orientation.portrait
                                                                          ? 7
                                                                          : 10,
                                                                      softWrap:
                                                                          true,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textScaleFactor:
                                                                          0.9,
                                                                      style:
                                                                          TextStyle(
                                                                        color: isDarkMode
                                                                            ? Colors.grey.shade300
                                                                            : Colors.black,
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
                                                        alignment:
                                                            Alignment.topRight,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Transform.rotate(
                                                          angle: 45,
                                                          child: note.isPinned
                                                              ? Icon(
                                                                  Icons
                                                                      .push_pin,
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
                                                (BuildContext context,
                                                        int index) =>
                                                    const Divider(),
                                            itemBuilder: (context, index) {
                                              final List<GlobalKey<FormState>>
                                                  keyListNote = List.generate(
                                                allNotes.length,
                                                (index) => GlobalKey(),
                                              );
                                              final note = notesList[index];
                                              final String noteDateCreated =
                                                  formatDate(
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
                                                              10),
                                                    ),
                                                    onTap: () {
                                                      RenderBox box = keyListNote[
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
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              bottom: 5),
                                                      child: Text(
                                                        note.title
                                                                .trim()
                                                                .isNotEmpty
                                                            ? note.title
                                                            : 'Untitled',
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textScaleFactor: 1.2,
                                                        style: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors
                                                                  .grey.shade300
                                                              : Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
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
                                                                ? 2
                                                                : 4,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textScaleFactor:
                                                                0.9,
                                                            style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors.grey
                                                                      .shade300
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  //!Pinned Icon
                                                  Container(
                                                    alignment:
                                                        Alignment.topRight,
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
                      ],
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return SafeArea(
                child: Center(
                  child: Scaffold(
                    body: Text('Error ${snapshot.error.toString()}'),
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                title: const Text(
                  'Categories',
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
          }),
    );
  }
}
