import 'package:flutter/material.dart';
import '../../Administrateur/presentation/views/dashboard_view.dart';
import '../../Administrateur/presentation/views/programme_view.dart';
import '../../Administrateur/presentation/views/gestion_cours_view.dart';
import '../../Administrateur/presentation/views/gestion_profs_view.dart';
import '../../Administrateur/presentation/views/retour_eleves_view.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const DashboardView(),
    const ProgrammeView(),
    const GestionCours(),
    const GestionProfs(),
    const RetourEleves(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: mobile ? _buildMobileNavigationBar() : _buildDesktopNavigationBar(),
    );
  }

  Widget _buildMobileNavigationBar() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6BA5BD),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 22,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Programme',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Cours',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: 'Retour',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6BA5BD),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Programme',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feedback),
          label: 'Retour',
        ),
      ],
    );
  }
}