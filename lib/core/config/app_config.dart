enum AppEnvironment { development, staging, production }

class AppConfig {
  static AppEnvironment environment = AppEnvironment.production;

  static bool get isProduction => environment == AppEnvironment.production;

  // Security & App Check Flags
  static const bool enableAppCheck = true;
  static const bool enforceServerSidePricing = true;
  static const bool isGatewaySandboxMode = false;

  // App Identity & Support Metadata
  static const String appName = 'Flutter Hotels & Resorts Portal';
  static const String appVersion = '1.0.0+1';
  static const String supportEmail = 'support@flutterhotels.com';
  static const String supportPhone = '+91 9876543210';
  static const String brandLocation = 'Lansdowne, Uttarakhand, India';
}
