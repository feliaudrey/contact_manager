import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../config/language.dart';
import '../models/contact.dart';
import '../providers/settings_provider.dart';
import '../services/contact_service.dart';
import 'package:intl/intl.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({super.key, this.contact});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactService = ContactService();
  final _imagePicker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _groupController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;
  bool _birthdayReminder = false;
  late String _selectedGroup;
  late bool _isFavorite;
  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;
  String? _imageData;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneController = TextEditingController(text: widget.contact?.phone);
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _addressController = TextEditingController(text: widget.contact?.address ?? '');
    _groupController = TextEditingController(text: widget.contact?.group ?? ContactGroup.other);
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
    _selectedGroup = widget.contact?.group ?? ContactGroup.other;
    _isFavorite = widget.contact?.isFavorite ?? false;
    _selectedDate = widget.contact?.birthday;
    _birthdayReminder = widget.contact?.birthdayReminder ?? false;
    _imageData = widget.contact?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _groupController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Reduced quality for smaller size
        maxWidth: 400,    // Reduced dimensions
        maxHeight: 400,
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageData = base64Image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    final isEditing = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get(isEditing ? 'edit_contact' : 'add_contact')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: _buildAvatarContent(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading && _uploadProgress > 0 && _uploadProgress < 100) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _uploadProgress / 100),
                const SizedBox(height: 8),
                Text(
                  '${_uploadProgress.toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizations.get('name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: localizations.get('phone'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: localizations.get('email'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: localizations.get('address'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: localizations.get('notes'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                ),
                items: ContactGroup.values.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGroup = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                localizations.get('birthday'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat.yMMMd().format(_selectedDate!)
                        : localizations.get('select_birthday'),
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(localizations.get('enable_reminder')),
                  value: _birthdayReminder,
                  onChanged: (bool value) {
                    setState(() {
                      _birthdayReminder = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Add to Favorites'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(localizations.get('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contact = Contact(
        id: widget.contact?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
        isFavorite: _isFavorite,
        birthday: _selectedDate,
        birthdayReminder: _birthdayReminder,
        groupId: _selectedGroup,
        group: _selectedGroup,
        notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
        address: _addressController.text.isEmpty ? null : _addressController.text.trim(),
        imageUrl: _imageData,
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.contact == null) {
        await _contactService.addContact(contact);
      } else {
        await _contactService.updateContact(contact);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarContent() {
    if (_imageFile != null) {
      return ClipOval(
        child: Image.file(
          _imageFile!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    
    if (_imageData != null) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(_imageData!),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image: $error');
              return _buildDefaultAvatar();
            },
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return _buildDefaultAvatar();
      }
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 60,
      color: Theme.of(context).colorScheme.primary,
    );
  }
} 