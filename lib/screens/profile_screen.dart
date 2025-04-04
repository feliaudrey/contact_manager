import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../config/language.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;
  String? _imageData;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 400,
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        photoUrl: _imageData,
      );
      
      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<SettingsProvider>().language == Language.en
                  ? 'Profile updated successfully'
                  : 'Profil berhasil diperbarui',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startEditing(app.User user) {
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _imageData = user.photoUrl;
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
      _imageFile = null;
    });
  }

  Widget _buildAvatarContent(app.User? user) {
    if (_isEditing) {
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
                return _buildDefaultAvatar(user);
              },
            ),
          );
        } catch (e) {
          return _buildDefaultAvatar(user);
        }
      }
    } else if (user?.photoUrl != null) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(user!.photoUrl!),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(user);
            },
          ),
        );
      } catch (e) {
        return _buildDefaultAvatar(user);
      }
    }
    
    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(app.User? user) {
    return Text(
      user?.name[0].toUpperCase() ?? 'U',
      style: const TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);

    return StreamBuilder<app.User?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.get('not_signed_in'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: Text(localizations.get('sign_in')),
                ),
              ],
            ),
          );
        }

        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: _buildAvatarContent(user),
                      ),
                      if (_isEditing)
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
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizations.get('name'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.get('name_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: localizations.get('phone'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : _cancelEditing,
                        child: Text(localizations.get('cancel')),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(localizations.get('save')),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _startEditing(user),
                    icon: const Icon(Icons.edit),
                    label: Text(localizations.get('edit')),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(localizations.get('phone')),
                          subtitle: Text(user.phone ?? localizations.get('not_provided')),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: Text(localizations.get('email')),
                          subtitle: Text(user.email),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(localizations.get('language')),
                          trailing: DropdownButton<Language>(
                            value: settings.language,
                            onChanged: (Language? newValue) {
                              if (newValue != null) {
                                context.read<SettingsProvider>().setLanguage(newValue);
                              }
                            },
                            items: Language.values.map((language) {
                              return DropdownMenuItem(
                                value: language,
                                child: Text(language.getDisplayName(settings.language)),
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode),
                          title: Text(localizations.get('dark_mode')),
                          value: Theme.of(context).brightness == Brightness.dark,
                          onChanged: (bool value) {
                            context.read<SettingsProvider>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(localizations.get('sign_out')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}