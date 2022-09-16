import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_exception.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  //Delete Notes
  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

//Update Notes
  Future<void> updateNotes({
    required String documentId,
    required String title,
    required String titleJson,
    required String note,
    required String noteJson,
    required String dateModified,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        titleJsonFieldName: titleJson,
        noteFieldName: note,
        noteJsonFieldName: noteJson,
        dateModifiedFieldName: dateModified
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

//Get Notes
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) =>
              note.ownerUserId == ownerUserId && (note.note.trim().isNotEmpty || note.title.trim().isNotEmpty)));
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

//Create Note
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try {
      await InternetAddress.lookup('www.google.com');
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
      final document = await notes.add({
        ownerUserIdFieldName: ownerUserId,
        noteFieldName: '',
        noteJsonFieldName: '',
        titleFieldName: '',
        titleJsonFieldName: '',
        dateCreatedFieldName: formattedDate,
        dateModifiedFieldName: '',
      });
      final fetchedNote = await document.get();

      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        title: '',
        titleJson: '',
        note: '',
        noteJson: '',
        dateCreated: formattedDate,
        dateModified: '',
      );
    } catch (e) {
      return Future.error('Couldn\'t create Note');
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedinstance();
  FirebaseCloudStorage._sharedinstance();
  factory FirebaseCloudStorage() => _shared;
}
