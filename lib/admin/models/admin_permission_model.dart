import '../../core/constants/role_constants.dart';

class AdminPermissionModel {
  final String role;
  final List<String> permissions;
  final List<String> propertyIds;

  AdminPermissionModel({
    required this.role,
    this.permissions = const [],
    this.propertyIds = const [],
  });

  bool can(String permission) {
    if (role == RoleConstants.superAdmin) return true;
    return permissions.contains(permission);
  }

  bool canAccessProperty(String propertyId) {
    if (role == RoleConstants.superAdmin) return true;
    return propertyIds.contains(propertyId);
  }
}
