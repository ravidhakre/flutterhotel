/// Role and permission constants for Flutter Hotel & Resort system.
class RoleConstants {
  static const String guest = 'guest';
  static const String superAdmin = 'superAdmin';
  static const String propertyAdmin = 'propertyAdmin';
  static const String manager = 'manager';
  static const String receptionist = 'receptionist';
  static const String bookingManager = 'bookingManager';
  static const String contentManager = 'contentManager';

  static const List<String> allAdminRoles = [
    superAdmin,
    propertyAdmin,
    manager,
    receptionist,
    bookingManager,
    contentManager,
  ];

  static bool isAdminRole(String role) {
    return allAdminRoles.contains(role);
  }
}

class PermissionConstants {
  static const String viewDashboard = 'view_dashboard';
  static const String manageProperties = 'manage_properties';
  static const String manageRooms = 'manage_rooms';
  static const String manageRoomTypes = 'manage_room_types';
  static const String manageInventory = 'manage_inventory';
  static const String viewBookings = 'view_bookings';
  static const String manageBookings = 'manage_bookings';
  static const String cancelBookings = 'cancel_bookings';
  static const String modifyBookings = 'modify_bookings';
  static const String manageGuests = 'manage_guests';
  static const String checkIn = 'check_in';
  static const String checkOut = 'check_out';
  static const String managePayments = 'manage_payments';
  static const String manageRefunds = 'manage_refunds';
  static const String manageOffers = 'manage_offers';
  static const String manageCoupons = 'manage_coupons';
  static const String managePackages = 'manage_packages';
  static const String manageAddons = 'manage_addons';
  static const String manageReviews = 'manage_reviews';
  static const String manageCms = 'manage_cms';
  static const String viewReports = 'view_reports';
  static const String manageAdmins = 'manage_admins';
  static const String manageSettings = 'manage_settings';
  static const String viewAuditLogs = 'view_audit_logs';

  /// Default permissions mapped by admin role
  static List<String> getDefaultPermissions(String role) {
    switch (role) {
      case RoleConstants.superAdmin:
        return [
          viewDashboard, manageProperties, manageRooms, manageRoomTypes,
          manageInventory, viewBookings, manageBookings, cancelBookings,
          modifyBookings, manageGuests, checkIn, checkOut, managePayments,
          manageRefunds, manageOffers, manageCoupons, managePackages,
          manageAddons, manageReviews, manageCms, viewReports, manageAdmins,
          manageSettings, viewAuditLogs,
        ];
      case RoleConstants.propertyAdmin:
        return [
          viewDashboard, manageProperties, manageRooms, manageRoomTypes,
          manageInventory, viewBookings, manageBookings, cancelBookings,
          modifyBookings, manageGuests, checkIn, checkOut, manageOffers,
          managePackages, manageAddons, viewReports,
        ];
      case RoleConstants.manager:
        return [
          viewDashboard, manageRooms, manageInventory, viewBookings,
          manageBookings, manageGuests, checkIn, checkOut, viewReports,
        ];
      case RoleConstants.receptionist:
        return [
          viewBookings, manageGuests, checkIn, checkOut, manageRooms,
        ];
      case RoleConstants.bookingManager:
        return [
          viewBookings, manageBookings, cancelBookings, modifyBookings,
          manageGuests, manageInventory,
        ];
      case RoleConstants.contentManager:
        return [
          manageOffers, manageCoupons, managePackages, manageAddons,
          manageReviews, manageCms,
        ];
      default:
        return [];
    }
  }
}
