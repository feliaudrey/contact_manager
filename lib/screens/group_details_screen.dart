import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../config/language.dart';
import '../models/contact.dart';
import '../providers/settings_provider.dart';
import '../services/contact_service.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;
  final ContactService _contactService = ContactService();

  GroupDetailsScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: StreamBuilder<List<Contact>>(
        stream: _contactService.getContactsByGroup(groupName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                localizations.get('error_general').replaceAll('{0}', snapshot.error.toString()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = snapshot.data!;

          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.get('no_contacts_in_group'),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: contact.imageUrl != null
                      ? MemoryImage(base64Decode(contact.imageUrl!))
                      : null,
                  child: contact.imageUrl == null
                      ? Text(
                          contact.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Text(contact.name),
                subtitle: contact.phone != null ? Text(contact.phone!) : null,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/contact_details',
                    arguments: contact,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 