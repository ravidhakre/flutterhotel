import 'package:flutter/material.dart';
import 'admin/screens/admin_dashboard_screen.dart';
import 'admin/screens/admin_login_screen.dart';
import 'core/constants/app_constants.dart';
import 'firebase/firebase_config.dart';
import 'models/admin_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const FlutterHotelApp());
}

class FlutterHotelApp extends StatelessWidget {
  const FlutterHotelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5F86C1),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5F86C1),
          primary: const Color(0xFF5F86C1),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreenPlaceholder(),
        AdminLoginScreen.routeName: (context) => const AdminLoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AdminDashboardScreen.routeName) {
          final admin = settings.arguments as AdminModel?;
          if (admin != null) {
            return MaterialPageRoute(
              builder: (context) => AdminDashboardScreen(admin: admin),
            );
          }
        }
        return null;
      },
    );
  }
}

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Hotels & Resorts'),
        backgroundColor: const Color(0xFF5F86C1),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Portal Login',
            onPressed: () => Navigator.of(context).pushNamed(AdminLoginScreen.routeName),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 80, color: Color(0xFF5F86C1)),
            const SizedBox(height: 20),
            const Text(
              'Flutter Hotels & Resorts Booking Portal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Phase 1 — Firebase Foundation & Security Architecture Ready',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('ACCESS ADMIN PORTAL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162234),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () => Navigator.of(context).pushNamed(AdminLoginScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
