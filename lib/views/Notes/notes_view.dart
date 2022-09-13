import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/auth/auth_service.dart';
import '../../enums/Menu.dart';
import '../../enums/filter.dart';
import '../../utilities/dialogs/delete_dialog.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import '../Constants/app_theme.dart';
import '../Constants/routes.dart';
import '../settings.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  late SharedPreferences prefs;
  int filterOption = 0;
  late bool isDarkMode;
  @override
  void initState() {
    getFilter().then(
      (value) {
        filterOption = value;
      },
    );
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<int> getFilter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final option = prefs.getInt('filter') ?? 0;
    return option;
  }

  sortNotes({required List notes}) async {
    switch (filterOption) {
      case 0:
        notes.sort(
          (a, b) => a.text.toLowerCase().compareTo(
                b.text.toLowerCase(),
              ),
        );
        break;
      case 1:
        notes.sort(
          (b, a) => a.text.toLowerCase().compareTo(
                b.text.toLowerCase(),
              ),
        );
        break;
      case 2:
        notes.sort(
          (b, a) => a.date.toLowerCase().compareTo(
                b.date.toLowerCase(),
              ),
        );
        return notes;

      case 3:
        notes.sort(
          (a, b) => a.date.toLowerCase().compareTo(
                b.date.toLowerCase(),
              ),
        );
        break;
      default:
        notes.sort(
          (b, a) => a.text.toLowerCase().compareTo(
                b.text.toLowerCase(),
              ),
        );
        break;
    }
    return notes.toList();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
bool isDarkMode=Provider.of<AppTheme>(context).darkMood;
      return Scaffold(
          backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
          appBar: AppBar(
            title:  const Text(
              'Pocket Notes',
              style: TextStyle(
                color: lightTextTheme,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon:const  Icon(Icons.add,color: lightTextTheme,),
              ),
              PopupMenuButton<FilterNotes>(
                onSelected: (value) async {
                  switch (value) {
                    case FilterNotes.alphabiticalN:
                      filterOption = 0;
                      break;
                    case FilterNotes.alphabiticalO:
                      filterOption = 1;
                      break;
                    case FilterNotes.dateN:
                      filterOption = 2;
                      break;
                    case FilterNotes.dateO:
                      filterOption = 3;
                      break;
                  }
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('filter', filterOption);
                  setState(() {});
                },
                icon: const Icon(Icons.sort,color:lightTextTheme),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<FilterNotes>(
                      value: FilterNotes.alphabiticalN,
                      child: Text('Title Ascending'),
                    ),
                    const PopupMenuItem<FilterNotes>(
                      value: FilterNotes.alphabiticalO,
                      child: Text('Title Descending'),
                    ),
                    const PopupMenuItem<FilterNotes>(
                      value: FilterNotes.dateN,
                      child: Text('Date Modified Newer First'),
                    ),
                    const PopupMenuItem<FilterNotes>(
                      value: FilterNotes.dateO,
                      child: Text('Date Modified Older First'),
                    ),
                  ];
                },
              ),
              PopupMenuButton<MenuBar>(
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
                icon: const Icon(Icons.more_vert,color:lightTextTheme,),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<MenuBar>(
                      value: MenuBar.logout,
                      child: Text('Logout'),
                    ),
                    const PopupMenuItem<MenuBar>(
                      value: MenuBar.settings,
                      child: Text('Settings'),
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
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
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
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                            itemBuilder: (context, index) {
                              final notesList = allNotes.toList();
                              sortNotes(notes: notesList);
                              final note = notesList[index];
                              return ListTile(
                                tileColor: themeColor,
                                visualDensity: const VisualDensity(vertical: 1),
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
                                      note.text,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textScaleFactor: 1.2,
                                      style:  TextStyle(
                                          color: lightTextTheme,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      note.date,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textScaleFactor: 0.7,
                                      style:  TextStyle(
                                          color: lightTextTheme,
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
                                  icon: const Icon(Icons.delete),
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
                              style: GoogleFonts.montserrat(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const CircularProgressIndicator()
                          ],
                        ),
                      );
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              },
            ),
          ));

  }
}
