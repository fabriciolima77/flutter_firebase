class AuthResult {
  final String? msgError;

  AuthResult({this.msgError});

  bool get isSucess => msgError == null;
}