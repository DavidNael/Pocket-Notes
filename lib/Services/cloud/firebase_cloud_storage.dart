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
    required String text,
    required String json,
    required String date,
  }) async {
    try {
      await notes.doc(documentId).update(
          {textFieldName: text, jsonFieldName: json, dateFieldName: date});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

//Get Notes
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) =>
              note.ownerUserId == ownerUserId && note.text.trim().isNotEmpty));
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
      String formattedDate = DateFormat('yyyy-MM-dd–hh:mm:ss a').format(now);
      final document = await notes.add({
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
        jsonFieldName: '',
        dateFieldName: formattedDate,
      });
      final fetchedNote = await document.get();

      return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        text: '',
        json: '',
        date: formattedDate,
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
