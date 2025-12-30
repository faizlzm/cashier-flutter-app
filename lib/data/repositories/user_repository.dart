import '../models/user_model.dart';

class UserRepository {
  static const User currentUser = User(
    name: 'Admin User',
    role: 'admin',
    email: 'admin@kasirpro.com',
  );

  User getCurrentUser() => currentUser;
}

