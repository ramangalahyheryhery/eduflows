// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'shared/widgets/role_based_view.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const CourseManagerApp());
}

class CourseManagerApp extends StatelessWidget {
  const CourseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Initialiser l'authentification au démarrage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.initialize();
          });

          return MaterialApp(
            title: 'Course Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const RoleBasedView(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}