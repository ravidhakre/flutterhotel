import '../core/errors/failure.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository({UserService? userService})
      : _userService = userService ?? UserService();

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      return await _userService.getUserProfile(uid);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _userService.updateUserProfile(uid, data);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
