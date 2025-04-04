import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../config/language.dart';
import '../models/contact.dart';
import '../providers/settings_provider.dart';
import '../services/contact_service.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  final ContactService _contactService = ContactService();

  ContactDetailScreen({super.key, required this.contact});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch email app'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching email app: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite ? Icons.star : Icons.star_border,
              color: contact.isFavorite ? Colors.amber : null,
            ),
            onPressed: () => _toggleFavorite(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editContact(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _deleteContact(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'contact_image_${contact.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: contact.imageUrl != null
                      ? MemoryImage(base64Decode(contact.imageUrl!))
                      : null,
                  child: contact.imageUrl == null
                      ? Text(
                          contact.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(localizations.get('group')),
                    subtitle: Text(contact.group ?? localizations.get('no_group')),
                  ),
                  const Divider(height: 1),
                  if (contact.phone != null) ...[
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(contact.phone!),
                      trailing: IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () => _makePhoneCall(context, contact.phone!),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  if (contact.email != null) ...[
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(contact.email!),
                      trailing: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _sendEmail(context, contact.email!),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  if (contact.address != null) ...[
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(contact.address!),
                    ),
                    const Divider(height: 1),
                  ],
                  if (contact.notes != null) ...[
                    ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(contact.notes!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final updatedContact = contact.copyWith(
      isFavorite: !contact.isFavorite,
    );
    await _contactService.updateContact(updatedContact);
  }

  void _editContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(contact: contact),
      ),
    );
  }

  Future<void> _deleteContact(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.get('delete_contact')),
        content: Text(localizations.get('delete_contact_confirmation', [contact.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.get('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && contact.id != null) {
      await _contactService.deleteContact(contact.id!);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
} 