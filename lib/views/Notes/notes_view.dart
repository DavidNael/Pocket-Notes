import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:provider/provider.dart';
import '../../Services/auth/auth_service.dart';
import '../../enums/enums.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import '../Constants/app_theme.dart';
import '../Constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int filterOption = Provider.of<AppTheme>(context).filterOption;
    int dateFormatOption = Provider.of<AppTheme>(context).dateFormatOption;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
    bool isHourFormat = Provider.of<AppTheme>(context).hourFormat;
    return Scaffold(
        backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
        appBar: AppBar(
          title: const Text(
            'Pocket Notes',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            ///Add Note Button
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),

            ///Menu Button

            PopupMenuButton<MenuBar>(
              color: isDarkMode ? darkTheme : lightTheme,
              onSelected: (value) async {
                switch (value) {
                  case MenuBar.logout:
                    final confirmLogout = await logoutConfirmation(context);
                    if (confirmLogout) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                    break;
                  case MenuBar.settings:
                    Navigator.of(context).pushNamed(
                      settingsRoute,
                    );
                    break;
                }
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<MenuBar>(
                    value: MenuBar.logout,
                    child: Text(
                      'Logout',
                      style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme),
                    ),
                  ),
                  PopupMenuItem<MenuBar>(
                    value: MenuBar.settings,
                    child: Text(
                      'Settings',
                      style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme),
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: SafeArea(
          child: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
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
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ListView.separated(
                          itemCount: allNotes.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemBuilder: (context, index) {
                            final notesList = allNotes.toList();
                            sortNotes(
                                notes: notesList, filterOption: filterOption);
                            final note = notesList[index];
                            final String noteDateCreated = formatDate(
                              date: note.dateCreated,
                              formatOption: dateFormatOption,
                              isHourFormat: isHourFormat,
                            );
                            final String noteDateModified = formatDate(
                              date: note.dateModified,
                              formatOption: dateFormatOption,
                              isHourFormat: isHourFormat,
                            );
                            return ListTile(
                              tileColor: themeColor,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    createOrUpdateNoteRoute,
                                    arguments: note);
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title.trim().isNotEmpty
                                        ? note.title
                                        : 'Untitled',
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.2,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date Modified: ${noteDateModified}',
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 0.7,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Date Created: ${noteDateCreated}',
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 0.7,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  final shouldDelete =
                                      await showDeleteDialog(context);
                                  if (shouldDelete) {
                                    await _notesService.deleteNotes(
                                        documentId: note.documentId);
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  } else {
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
                  }
                default:
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
                              color:
                                  isDarkMode ? darkTextTheme : lightTextTheme),
                        ),
                        const CircularProgressIndicator()
                      ],
                    ),
                  );
              }
            },
          ),
        ));
  }
}
