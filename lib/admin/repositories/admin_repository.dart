import '../../core/errors/failure.dart';
import '../../models/admin_model.dart';
import '../services/admin_auth_service.dart';

class AdminRepository {
  final AdminAuthService _adminAuthService;

  AdminRepository({AdminAuthService? adminAuthService})
      : _adminAuthService = adminAuthService ?? AdminAuthService();

  Future<AdminModel> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      return await _adminAuthService.signInAdmin(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> logoutAdmin() async {
    try {
      await _adminAuthService.adminSignOut();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
