import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ListView.separated(
        itemCount: notes.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          final notesList = notes.toList();
          notesList.sort(
              (a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
          final note = notesList[index];
          return ListTile(
            tileColor: Colors.amber,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            onTap: () {
              onTap(note);
            },
            title: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        },
      ),
    );
  }
}
