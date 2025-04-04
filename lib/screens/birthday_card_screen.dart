import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/language.dart';
import '../models/contact.dart';
import '../providers/settings_provider.dart';

class BirthdayCardScreen extends StatelessWidget {
  final Contact contact;

  Map<Language, List<Map<String, dynamic>>> get languageTemplates => {
    Language.en: [
      {
        'title': 'Happy Birthday!',
        'template': '''
🎉 Happy Birthday, {name}! 🎉

Wishing you a day filled with joy, laughter, and all the things that make you happy! May this year bring you success, good health, and wonderful moments.

Best wishes,
Your Friend
''',
        'image': '🎂',
      },
      {
        'title': 'Celebration Time!',
        'template': '''
🌟 Happy Birthday, {name}! 🌟

Another year of amazing memories and achievements! May your special day be as wonderful as you are. Here's to more adventures and happiness in the coming year!

Cheers to you!
''',
        'image': '🎈',
      },
      {
        'title': 'Special Day',
        'template': '''
🎁 Happy Birthday, {name}! 🎁

On your special day, I hope you're surrounded by love, joy, and all the things that make you smile. May this year be your best one yet!

Warmest wishes,
''',
        'image': '🎀',
      },
    ],
    Language.es: [
      {
        'title': '¡Feliz Cumpleaños!',
        'template': '''
🎉 ¡Feliz Cumpleaños, {name}! 🎉

¡Que este día esté lleno de alegría, risas y momentos inolvidables! Que la vida te regale todo lo que sueñas y mucho más.

Con mucho cariño,
Tu amigo/a
''',
        'image': '🎂',
      },
      {
        'title': '¡Día Especial!',
        'template': '''
🌟 ¡Felicidades, {name}! 🌟

¡Que la magia de este día te acompañe todo el año! Que cumplas muchos más y que cada día sea una nueva aventura llena de bendiciones.

¡Un abrazo fuerte!
''',
        'image': '🎈',
      },
      {
        'title': 'Celebración',
        'template': '''
🎁 ¡Feliz Cumpleaños, {name}! 🎁

Que este nuevo año de vida venga cargado de éxitos, salud y muchas alegrías. ¡Disfruta tu día al máximo!

Con mucho afecto,
''',
        'image': '🎀',
      },
    ],
    Language.zh: [
      {
        'title': '生日快乐！',
        'template': '''
🎉 亲爱的{name}，生日快乐！🎉

愿你生日充满欢乐和温暖，前程似锦，万事如意！
祝愿你：
心想事成
幸福安康

祝福您，
您的朋友
''',
        'image': '🎂',
      },
      {
        'title': '祝福时刻',
        'template': '''
🌟 {name}，生日快乐！🌟

愿这特别的日子里，
您能收获满满的祝福和喜悦！
愿未来的日子里，
事事顺心，平安喜乐！

真挚的祝福！
''',
        'image': '🎈',
      },
      {
        'title': '美好时光',
        'template': '''
🎁 亲爱的{name}：🎁

值此佳节，
祝您：
岁岁平安，
年年如意！
福寿安康！

温馨的祝福，
''',
        'image': '🎀',
      },
    ],
    Language.id: [
      {
        'title': 'Selamat Ulang Tahun!',
        'template': '''
🎉 Selamat Ulang Tahun, {name}! 🎉

Semoga di hari spesialmu ini penuh dengan kebahagiaan, tawa, dan semua hal yang membuatmu tersenyum! Semoga tahun ini membawa kesuksesan dan kesehatan!

Salam hangat,
Temanmu
''',
        'image': '🎂',
      },
      {
        'title': 'Hari Bahagia!',
        'template': '''
🌟 Selamat Ulang Tahun, {name}! 🌟

Semoga bertambah usia membawa berkah dan kebahagiaan! Semoga semua impianmu terwujud dan hidupmu selalu dilimpahi rahmat!

Peluk hangat!
''',
        'image': '🎈',
      },
      {
        'title': 'Momen Spesial',
        'template': '''
🎁 Selamat Ulang Tahun, {name}! 🎁

Di hari istimewamu ini, semoga kamu selalu dalam lindungan-Nya. Semoga umur yang bertambah membawa keberkahan dalam hidupmu!

Salam sayang,
''',
        'image': '🎀',
      },
    ],
  };

  BirthdayCardScreen({super.key, required this.contact});

  Future<void> _sendEmail(BuildContext context, String message) async {
    final settings = context.read<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    
    if (contact.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.get('no_email'))),
      );
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: contact.email,
      queryParameters: {
        'subject': settings.language == Language.es ? '¡Feliz Cumpleaños ${contact.name}!' :
                  settings.language == Language.zh ? '${contact.name}，生日快乐！' :
                  settings.language == Language.id ? 'Selamat Ulang Tahun ${contact.name}!' :
                  'Happy Birthday ${contact.name}!',
        'body': message,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.get('email_error'))),
      );
    }
  }

  Future<void> _sendSMS(BuildContext context, String message) async {
    final settings = context.read<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    
    if (contact.phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.get('no_phone'))),
      );
      return;
    }

    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: contact.phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsLaunchUri)) {
      await launchUrl(smsLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.get('sms_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations(settings.language);
    final templates = languageTemplates[settings.language] ?? languageTemplates[Language.en]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('birthday_card')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final message = template['template'].toString().replaceAll('{name}', contact.name);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        template['image'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          template['title'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _sendEmail(context, message),
                        icon: const Icon(Icons.email),
                        label: Text(localizations.get('send_email')),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _sendSMS(context, message),
                        icon: const Icon(Icons.sms),
                        label: Text(localizations.get('send_sms')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 