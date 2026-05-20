import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentations/login_screen.dart';
import 'features/auth/presentations/register_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'features/home/presentations/home_screen.dart';
import 'features/map/presentations/map_screen.dart';
import 'features/order/providers/order_provider.dart';
import 'features/merchant/providers/merchant_provider.dart';
import 'features/merchant/presentations/merchant_dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArudoCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF39A28F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39A28F)),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/merchant-home': (context) => const MerchantDashboardScreen(),
      },
    );
  }
}
