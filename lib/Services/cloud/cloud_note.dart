import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String note;
  final String noteJson;
  final String title;
  final String titleJson;
  final String dateCreated;
  final String dateModified;
  final bool isPinned;
  final bool isArchived;
  final bool isTrashed;
  final List<dynamic> noteCategories;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.note,
    required this.noteJson,
    required this.title,
    required this.titleJson,
    required this.dateCreated,
    required this.dateModified,
    required this.isPinned,
    required this.isArchived,
    required this.isTrashed,
    required this.noteCategories,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        note = snapshot.data()[noteFieldName] as String,
        noteJson = snapshot.data()[noteJsonFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        titleJson = snapshot.data()[titleJsonFieldName] as String,
        dateCreated = snapshot.data()[dateCreatedFieldName] as String,
        dateModified = snapshot.data()[dateModifiedFieldName] as String,
        isPinned = snapshot.data()[isPinnedFieldName] as bool,
        isArchived = snapshot.data()[isArchivedFieldName] as bool,
        isTrashed = snapshot.data()[isTrashedFieldName] as bool,
        noteCategories = snapshot.data()[noteCategoriesFieldName] as List<dynamic>;
}
