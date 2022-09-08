import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String json;
  final String date;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.json,
    required this.date,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        text = snapshot.data()[textFieldName] as String,
        json = snapshot.data()[jsonFieldName] as String,
        date = snapshot.data()[dateFieldName] as String;
}
