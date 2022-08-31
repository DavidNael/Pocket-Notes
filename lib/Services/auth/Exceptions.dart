///Login Exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

///Register Exceptions
class WeakPasswordAuthException implements Exception {}

class EmailExistsAuthException implements Exception {}

///Login & Register Exceptions
class UserNotLoggedInAuthException implements Exception {}

class EmptyEmailAuthException implements Exception {}

class EmptyPasswordAuthException implements Exception {}

class EmptyEmailPasswordAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class VerifyEmailException implements Exception {}

class ResetPasswordException implements Exception {}

class UnknownException implements Exception {}
