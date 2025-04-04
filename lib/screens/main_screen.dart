import 'package:flutter/material.dart';
import '../config/language.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'groups_screen.dart';
import 'birthday_reminders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    BirthdayRemindersScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(localizations)),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.contacts),
            label: localizations.get('contacts'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.star),
            label: localizations.get('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cake),
            label: localizations.get('birthdays'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.group),
            label: localizations.get('groups'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: localizations.get('profile'),
          ),
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations localizations) {
    switch (_selectedIndex) {
      case 0:
        return localizations.get('contacts');
      case 1:
        return localizations.get('favorites');
      case 2:
        return localizations.get('birthdays');
      case 3:
        return localizations.get('groups');
      case 4:
        return localizations.get('profile');
      default:
        return localizations.get('contacts');
    }
  }
} 