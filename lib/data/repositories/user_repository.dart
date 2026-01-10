import '../models/user_model.dart';

/// User repository - to be replaced with API calls in auth flow
/// This is kept for backward compatibility but will be deprecated
class UserRepository {
  // Mock user - will be replaced by auth provider
  static User currentUser = User(
    id: 'mock-user-id',
    name: 'Admin User',
    role: 'ADMIN',
    email: 'admin@kasirpro.com',
  );

  User getCurrentUser() => currentUser;
}
