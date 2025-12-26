// lib/shared/widgets/role_based_view.dart
// lib/shared/widgets/role_based_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/models.dart';
import '../../core/auth/login_screen.dart';
import '../../core/navigation/main_navigation.dart';

class RoleBasedView extends StatelessWidget {
  const RoleBasedView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Vérifier si l'authentification est initialisée
    if (!authProvider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si l'utilisateur n'est pas connecté, afficher l'écran de login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Si l'utilisateur est connecté, rediriger selon son rôle
    final user = authProvider.user!;

    switch (user.role) {
      case UserRole.admin:
        return _buildAdminApp(context, authProvider);
      case UserRole.teacher:
        return _buildTeacherApp(context, authProvider);
      case UserRole.student:
        return _buildStudentApp(context, authProvider);
      case UserRole.unknown:
      // Déconnecter si le rôle est inconnu
        WidgetsBinding.instance.addPostFrameCallback((_) {
          authProvider.logout();
        });
        return const LoginScreen();
    // SUPPRIMÉ: Le cas default car tous les cas sont déjà couverts
    }
  }

  Widget _buildAdminApp(BuildContext context, AuthProvider authProvider) {
    // Au lieu de l'import dynamique, importons directement
    // Vous devrez ajuster le chemin selon votre structure
    try {
      // Import direct
      final mainNavigation = MainNavigationWrapper();

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, size: 20),
              const SizedBox(width: 8),
              Text('Admin - ${authProvider.user!.name}'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context, authProvider),
              tooltip: 'Déconnexion',
            ),
          ],
        ),
        body: mainNavigation,
      );
    } catch (e) {
      // Fallback si l'import échoue
      return Scaffold(
        appBar: AppBar(
          title: const Text('Espace Administrateur'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context, authProvider),
              tooltip: 'Déconnexion',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'Espace Administrateur',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Bienvenue ${authProvider.user!.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authProvider),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTeacherApp(BuildContext context, AuthProvider authProvider) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, size: 20),
            const SizedBox(width: 8),
            Text('Professeur - ${authProvider.user!.name}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authProvider),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            Text(
              'Espace Professeur',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Bienvenue ${authProvider.user!.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context, authProvider),
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Emploi du temps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Notes',
          ),
        ],
      ),
    );
  }

  Widget _buildStudentApp(BuildContext context, AuthProvider authProvider) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.school, size: 20),
            const SizedBox(width: 8),
            Text('Étudiant - ${authProvider.user!.name}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authProvider),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Espace Étudiant',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Bienvenue ${authProvider.user!.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context, authProvider),
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Emploi du temps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Devoirs',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
