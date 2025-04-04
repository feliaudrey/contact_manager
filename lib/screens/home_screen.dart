import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language.dart';
import '../models/contact.dart';
import '../providers/settings_provider.dart';
import '../services/contact_service.dart';
import 'contact_form_screen.dart';
import 'contact_detail_screen.dart';
import 'dart:convert';

enum SortOption {
  nameAsc,
  nameDesc,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Contact>> _groupContactsByAlphabet(List<Contact> contacts) {
    final map = <String, List<Contact>>{};
    
    for (final contact in contacts) {
      final firstLetter = contact.name[0].toUpperCase();
      if (!map.containsKey(firstLetter)) {
        map[firstLetter] = [];
      }
      map[firstLetter]!.add(contact);
    }
    
    // Sort contacts within each letter
    for (final list in map.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.get('search_contacts'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: localizations.get('sort_contacts'),
                  onSelected: (SortOption option) {
                    setState(() {
                      _sortOption = option;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: SortOption.nameAsc,
                      child: Row(
                        children: [
                          const Icon(Icons.sort_by_alpha),
                          const SizedBox(width: 8),
                          Text(localizations.get('sort_az')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: SortOption.nameDesc,
                      child: Row(
                        children: [
                          const Icon(Icons.sort_by_alpha),
                          const SizedBox(width: 8),
                          Text(localizations.get('sort_za')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Contact>>(
              stream: _contactService.getContacts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.get('error_general').replaceAll('{0}', snapshot.error.toString()),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var contacts = snapshot.data!;
                
                // Apply search filter
                contacts = contacts.where((contact) {
                  final searchLower = _searchQuery.toLowerCase();
                  return contact.name.toLowerCase().contains(searchLower) ||
                      (contact.phone?.toLowerCase().contains(searchLower) ?? false) ||
                      (contact.email?.toLowerCase().contains(searchLower) ?? false);
                }).toList();

                if (contacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? localizations.get('no_contacts')
                              : localizations.get('no_results'),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Sort contacts based on the selected option
                if (_sortOption == SortOption.nameDesc) {
                  contacts.sort((a, b) => b.name.compareTo(a.name));
                } else {
                  contacts.sort((a, b) => a.name.compareTo(b.name));
                }

                final groupedContacts = _groupContactsByAlphabet(contacts);
                
                final sortedLetters = groupedContacts.keys.toList();
                if (_sortOption == SortOption.nameDesc) {
                  sortedLetters.sort((a, b) => b.compareTo(a));
                } else {
                  sortedLetters.sort();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: groupedContacts.length,
                  itemBuilder: (context, index) {
                    final letter = sortedLetters[index];
                    final letterContacts = groupedContacts[letter]!;

                    // Sort contacts within each group based on the selected option
                    if (_sortOption == SortOption.nameDesc) {
                      letterContacts.sort((a, b) => b.name.compareTo(a.name));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            letter,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ...letterContacts.map((contact) => _buildContactTile(contact)).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addContact(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactTile(Contact contact) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'contact_image_${contact.id}',
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: contact.imageUrl != null
                ? MemoryImage(base64Decode(contact.imageUrl!))
                : null,
            child: contact.imageUrl == null
                ? Text(
                    contact.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.phone != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contact.phone!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.group,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contact.group ?? localizations.get('no_group'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: contact.isFavorite
            ? Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              )
            : Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactDetailScreen(contact: contact),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Contact contact) async {
    final settings = context.read<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.get('delete_contact')),
        content: Text(localizations.get('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              _contactService.deleteContact(contact.id!);
              Navigator.pop(context);
            },
            child: Text(localizations.get('delete')),
          ),
        ],
      ),
    );
  }

  void _addContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactFormScreen(),
      ),
    );
  }
} 