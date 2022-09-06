import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_exception.dart';
import 'dart:io';

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
  Future<void> updateNotes(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

//Get Notes
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));
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

      final document = await notes.add({
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
      });
      final fetchedNote = await document.get();
      return CloudNote(
          documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
    } catch (e) {
      return Future.error('Couldn\'t create Note');
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedinstance();
  FirebaseCloudStorage._sharedinstance();
  factory FirebaseCloudStorage() => _shared;
}
