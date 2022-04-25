import 'package:flutter_firebase/firebase_auth/auth_result.dart';

abstract class AuthInterface {
  Future<AuthResult> login(String user, String pass);
  Future<AuthResult> register(String user, String pass);
}