import 'package:flutter/cupertino.dart';

@immutable
class CloudStorageException implements Exception {
  const CloudStorageException();
}
///User Exceptions
class CouldNotGetUserException implements CloudStorageException {}
class CouldNotUpdateUserException implements CloudStorageException {}

///Note Exception
///CRUD C:Create R:Read U:Update D:Delete
class CouldNotCreateNoteException implements CloudStorageException {}

class CouldNotGetAllNotesException implements CloudStorageException {}

class CouldNotUpdateNoteException implements CloudStorageException {}

class CouldNotDeleteNoteException implements CloudStorageException {}

class CouldNotRenameNoteCategoryException implements CloudStorageException {}
