import 'package:flutter/cupertino.dart';

@immutable
class CloudStorageException implements Exception {
  const CloudStorageException();
}

//CRUD C:Create R:Read U:Update D:Delete
class CouldNotCreateNoteException implements CloudStorageException {}

class CouldNotGetAllNotesException implements CloudStorageException {}

class CouldNotUpdateNoteException implements CloudStorageException {}

class CouldNotDeleteNoteException implements CloudStorageException {}
