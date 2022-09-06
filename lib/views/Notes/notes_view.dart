// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';
import '../../Services/auth/auth_service.dart';
import '../../enums/Menu.dart';
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
        backgroundColor: Color.fromARGB(255, 200, 200, 200),
        appBar: AppBar(
          title: const Text('Pocket Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
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
