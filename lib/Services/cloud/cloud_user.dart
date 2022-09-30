import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketnotes/Services/cloud/cloud_storage_constants.dart';

class CloudUser {
  final String ownerUserId;
  final String documentId;
  final String userName;
  final String userImage;
  final String userPhone;
  final List<dynamic> userCategories;

  CloudUser({
    required this.ownerUserId,
    required this.documentId,
    required this.userName,
    required this.userImage,
    required this.userPhone,
    required this.userCategories,
  });
  CloudUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
        userName = snapshot.data()[userNameFieldName] as String,
        userImage = snapshot.data()[userImageFieldName] as String,
        userPhone = snapshot.data()[userPhoneFieldName] as String,
        userCategories = snapshot.data()[userCategoriesFieldName] as List<dynamic>;
}
