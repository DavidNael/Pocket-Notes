import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_exception.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pocketnotes/Services/cloud/cloud_user.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  final users = FirebaseFirestore.instance.collection('users');

//!User
  //!Get User
  Future<CloudUser> getUser({required String ownerUserId}) async {
    try {
      return await users
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => CloudUser.fromSnapshot(value.docs[0]),
          );
      // return await users.doc(ownerUserId).get().then((doc) =>
      //     CloudUser.fromSnapshot(
      //         doc.data() as QueryDocumentSnapshot<Map<String, dynamic>>));
    } catch (e) {
      throw CouldNotGetUserException();
    }
  }

  //!Check User
  Future<bool> checkUser({required String ownerUserId}) async {
    try {
      final list = await users
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.isEmpty ? false : true,
          );
      return list;
    } catch (e) {
      return false;
    }
  }

  //!Update User
  Future<void> updateUser({
    required String documentId,
    required String userName,
    required String userImage,
    required String userPhone,
    required List<dynamic> userCategories,
  }) async {
    try {
      await users.doc(documentId).update({
        userNameFieldName: userName,
        userImageFieldName: userImage,
        userPhoneFieldName: userPhone,
        userCategoriesFieldName: userCategories,
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  //!Create User
  Future<CloudUser> createNewUser(
      {required String ownerUserId, required String username}) async {
    try {
      await InternetAddress.lookup('www.google.com');
      await users.doc(ownerUserId).set({
        ownerUserIdFieldName: ownerUserId,
        userNameFieldName: username,
        userImageFieldName: '',
        userPhoneFieldName: '',
        userCategoriesFieldName: [],
      });

      return CloudUser(
        ownerUserId: ownerUserId,
        documentId: ownerUserId,
        userName: username,
        userImage: '',
        userPhone: '',
        userCategories: [],
      );
    } catch (e) {
      return Future.error('Couldn\'t create Note');
    }
  }

  //!Get All Users Stream
  Stream<Iterable<CloudUser>> allUsers({required String ownerUserId}) {
    return users.snapshots().map(
          (event) => event.docs
              .map((doc) => CloudUser.fromSnapshot(doc))
              .where((user) => user.ownerUserId == ownerUserId),
        );
  }

//!Notes
  //!Delete Notes
  Future<void> deleteNotes({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  //!Update Notes
  Future<void> updateNotes({
    required String documentId,
    required String title,
    required String titleJson,
    required String note,
    required String noteJson,
    required String dateModified,
    required bool isPinned,
    required bool isArchived,
    required bool isTrashed,
    required List<dynamic> categories,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        titleJsonFieldName: titleJson,
        noteFieldName: note,
        noteJsonFieldName: noteJson,
        dateModifiedFieldName: dateModified,
        isPinnedFieldName: isPinned,
        isArchivedFieldName: isArchived,
        isTrashedFieldName: isTrashed,
        noteCategoriesFieldName: categories,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  //!Rename note Category
  Future<void> renameCategory({
    required String ownerUserId,
    required String oldCategory,
    required String newCategory,
  }) async {
    try {
      final allNotes = await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((e) => CloudNote.fromSnapshot(e)),
          );

      for (var note in allNotes) {
        if (note.noteCategories.contains(oldCategory)) {
          List<dynamic> newList = note.noteCategories;
          final index = note.noteCategories.indexOf(oldCategory);
          newList[index] = newCategory;
          updateNotes(
            documentId: note.documentId,
            title: note.title,
            titleJson: note.titleJson,
            note: note.note,
            noteJson: note.noteJson,
            dateModified: note.dateModified,
            isPinned: note.isPinned,
            isArchived: note.isArchived,
            isTrashed: note.isTrashed,
            categories: newList,
          );
        }
      }

    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  //!Delete note Category
  Future<void> deleteCategory({
    required String ownerUserId,
    required String categoryName,
  }) async {
    try {
      final allNotes = await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((e) => CloudNote.fromSnapshot(e)),
          );

      for (var note in allNotes) {
        if (note.noteCategories.contains(categoryName)) {
          List<dynamic> newList = note.noteCategories;
          newList.remove(categoryName);
          updateNotes(
            documentId: note.documentId,
            title: note.title,
            titleJson: note.titleJson,
            note: note.note,
            noteJson: note.noteJson,
            dateModified: note.dateModified,
            isPinned: note.isPinned,
            isArchived: note.isArchived,
            isTrashed: note.isTrashed,
            categories: newList,
          );
        }
      }

    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  //!Get All Notes Stream
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map(
          (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
                (note) =>
                    note.ownerUserId == ownerUserId &&
                    (note.note.trim().isNotEmpty ||
                        note.title.trim().isNotEmpty) &&
                    !note.isArchived &&
                    !note.isTrashed,
              ),
        );
  }

  //!Get All Notes Category Stream
  Stream<Iterable<CloudNote>> allNotesCategory(
      {required String ownerUserId, required String category}) {
    return notes.snapshots().map(
          (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
                (note) =>
                    note.ownerUserId == ownerUserId &&
                    (note.note.trim().isNotEmpty ||
                        note.title.trim().isNotEmpty) &&
                    !note.isArchived &&
                    !note.isTrashed &&
                    note.noteCategories.contains(category),
              ),
        );
  }

  //!Get All Archived Notes Stream
  Stream<Iterable<CloudNote>> archivedNotes({required String ownerUserId}) {
    return notes.snapshots().map(
          (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
                (note) =>
                    note.ownerUserId == ownerUserId &&
                    (note.note.trim().isNotEmpty ||
                        note.title.trim().isNotEmpty) &&
                    note.isArchived,
              ),
        );
  }

  //!Get All Trash Notes Stream
  Stream<Iterable<CloudNote>> trashNotes({required String ownerUserId}) {
    return notes.snapshots().map(
          (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where(
                (note) =>
                    note.ownerUserId == ownerUserId &&
                    (note.note.trim().isNotEmpty ||
                        note.title.trim().isNotEmpty) &&
                    note.isTrashed,
              ),
        );
  }

  //!Get Notes List
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

  //!Create Note
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
        isPinnedFieldName: false,
        isArchivedFieldName: false,
        isTrashedFieldName: false,
        noteCategoriesFieldName: [],
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
        isPinned: false,
        isArchived: false,
        isTrashed: false,
        noteCategories: [],
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
