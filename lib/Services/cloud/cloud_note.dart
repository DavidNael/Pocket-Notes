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

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.note,
    required this.noteJson,
    required this.title,
    required this.titleJson,
    required this.dateCreated,
    required this.dateModified,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        note = snapshot.data()[noteFieldName] as String,
        noteJson = snapshot.data()[noteJsonFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        titleJson = snapshot.data()[titleJsonFieldName] as String,
        dateCreated = snapshot.data()[dateCreatedFieldName] as String,
        dateModified = snapshot.data()[dateModifiedFieldName] as String;
}
