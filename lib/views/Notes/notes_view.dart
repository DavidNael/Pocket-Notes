import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import '../../Services/auth/auth_service.dart';
import '../../enums/Menu.dart';
import '../../enums/filter.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import '../Constants/routes.dart';
import 'notes_list_view.dart';

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
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 200, 200, 200),
        appBar: AppBar(
          title: const Text('Pocket Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<FilterNotes>(
              onSelected: (value) {
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
                setState(() {});
              },
              icon: const Icon(Icons.sort),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<FilterNotes>(
                    value: FilterNotes.alphabiticalN,
                    child: Text('Alphabitical (Ascending)'),
                  ),
                  const PopupMenuItem<FilterNotes>(
                    value: FilterNotes.alphabiticalO,
                    child: Text('Alphabitical (Descending)'),
                  ),
                  const PopupMenuItem<FilterNotes>(
                    value: FilterNotes.dateN,
                    child: Text('Date (Newer First)'),
                  ),
                  const PopupMenuItem<FilterNotes>(
                    value: FilterNotes.dateO,
                    child: Text('Date (Older First)'),
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
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<MenuBar>(
                    value: MenuBar.logout,
                    child: Text('Logout'),
                  )
                ];
              },
            )
          ],
        ),
        body: StreamBuilder(
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
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return NotesListView(
                      notes: allNotes,
                      onDeleteNote: (note) async {
                        await _notesService.deleteNotes(
                            documentId: note.documentId);
                      },
                      onTap: (note) {
                        Navigator.of(context).pushNamed(createOrUpdateNoteRoute,
                            arguments: note);
                      },
                    );
                  }
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Loading Notes...'),
                      CircularProgressIndicator()
                    ],
                  );
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
