import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language.dart';
import '../providers/settings_provider.dart';
import '../services/contact_service.dart';
import '../models/contact.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'birthday_card_screen.dart';
import 'dart:convert';

class BirthdayRemindersScreen extends StatefulWidget {
  const BirthdayRemindersScreen({super.key});

  @override
  State<BirthdayRemindersScreen> createState() => _BirthdayRemindersScreenState();
}

class _BirthdayRemindersScreenState extends State<BirthdayRemindersScreen> {
  final _contactService = ContactService();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Contact>> _events = {};
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _loadBirthdays();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('id_ID');
    await initializeDateFormatting('es_ES');
    await initializeDateFormatting('zh_CN');
    if (mounted) {
      setState(() {
        _localeInitialized = true;
      });
    }
  }

  Future<void> _loadBirthdays() async {
    final contactsStream = _contactService.getContacts();
    final birthdaysByDate = <DateTime, List<Contact>>{};
    
    final contacts = await contactsStream.first;
    final currentMonth = _focusedDay.month;
    final currentYear = _focusedDay.year;
    
    for (final contact in contacts) {
      if (contact.birthday != null) {
        // Only process birthdays for the current month
        if (contact.birthday!.month == currentMonth) {
          // Create a date for this year's birthday
          final birthday = DateTime(
            currentYear,
            contact.birthday!.month,
            contact.birthday!.day,
          );
          
          // Don't filter out any birthdays - show all for the current month
          if (!birthdaysByDate.containsKey(birthday)) {
            birthdaysByDate[birthday] = [];
          }
          birthdaysByDate[birthday]!.add(contact);
        }
      }
    }
    
    setState(() {
      _events = birthdaysByDate;
    });
  }

  List<Contact> _getEventsForDay(DateTime day) {
    // Only show events for the current month
    if (day.month != _focusedDay.month) {
      return [];
    }
    // Normalize the date to midnight to ensure proper comparison
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    // Clear events when changing months
    setState(() {
      _focusedDay = focusedDay;
      _events = {};
    });
    // Load new events for the new month
    _loadBirthdays();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    final upcomingBirthdays = _getUpcomingBirthdays();

    if (!_localeInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: TableCalendar<Contact>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              formatButtonVisible: false,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
              titleCentered: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(fontWeight: FontWeight.w500),
              defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
              cellMargin: const EdgeInsets.all(8),
              cellPadding: const EdgeInsets.all(0),
            ),
            locale: settings.language == Language.en ? 'en_US' : 
                   settings.language == Language.id ? 'id_ID' :
                   settings.language == Language.es ? 'es_ES' :
                   'zh_CN',
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.cake,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.get('upcoming_birthdays'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: upcomingBirthdays.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.get('no_birthday_reminders'),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: upcomingBirthdays.length,
                  itemBuilder: (context, index) {
                    final birthdayInfo = upcomingBirthdays[index];
                    final contact = birthdayInfo.contact;
                    final daysUntil = birthdayInfo.daysUntil;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
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
                            if (daysUntil == 0)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cake,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(contact.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getBirthdayText(daysUntil, localizations)),
                            if (contact.birthday != null)
                              Text(
                                DateFormat.yMMMd(settings.language == Language.en ? 'en_US' : 'id_ID')
                                    .format(contact.birthday!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.card_giftcard),
                              tooltip: localizations.get('send_birthday_card'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BirthdayCardScreen(contact: contact),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<BirthdayInfo> _getUpcomingBirthdays() {
    final now = DateTime.now();
    final upcomingBirthdays = <BirthdayInfo>[];
    
    _events.forEach((date, contacts) {
      for (final contact in contacts) {
        final daysUntil = _calculateDaysUntil(contact.birthday!);
        if (daysUntil >= 0) {  // Include today and future birthdays
          upcomingBirthdays.add(BirthdayInfo(contact: contact, daysUntil: daysUntil));
        }
      }
    });
    
    // Sort by days until birthday
    upcomingBirthdays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    
    return upcomingBirthdays;
  }

  int _calculateDaysUntil(DateTime birthday) {
    final now = DateTime.now();
    // Normalize the dates to midnight to avoid timezone issues
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final thisYearBirthday = DateTime(
      now.year,
      birthday.month,
      birthday.day,
    );
    
    // If birthday is today, return 0
    if (thisYearBirthday.year == normalizedNow.year && 
        thisYearBirthday.month == normalizedNow.month && 
        thisYearBirthday.day == normalizedNow.day) {
      return 0;
    }
    
    // If birthday has passed this year, calculate for next year
    if (thisYearBirthday.isBefore(normalizedNow)) {
      final nextYearBirthday = DateTime(
        now.year + 1,
        birthday.month,
        birthday.day,
      );
      return nextYearBirthday.difference(normalizedNow).inDays;
    }
    
    // Birthday is coming up this year
    return thisYearBirthday.difference(normalizedNow).inDays;
  }

  String _getBirthdayText(int daysUntil, AppLocalizations localizations) {
    if (daysUntil == 0) {
      return localizations.get('birthday_today');
    } else if (daysUntil == 1) {
      return localizations.get('birthday_tomorrow');
    } else {
      return localizations.get('birthday_in_days').replaceAll('{days}', daysUntil.toString());
    }
  }
}

class BirthdayInfo {
  final Contact contact;
  final int daysUntil;

  BirthdayInfo({required this.contact, required this.daysUntil});
} 