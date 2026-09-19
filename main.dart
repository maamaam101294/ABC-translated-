import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';


/// Simple English/Arabic strings. English is the base language.
const Map<String, Map<String, String>> _t = {
  'en': {
    'app_name': 'AI Translate ABC',
    'home_title': 'What do you want to translate?',
    'free': 'Free',
    'paid': 'Paid',
    'soon': 'Coming in the next phase',
    'f_text': 'Text',
    'f_image': 'Image',
    'f_voice': 'Voice',
    'f_pdf': 'PDF',
    'f_video_text': 'Video subtitles',
    'f_dub': 'Video dubbing',
    'f_link': 'Video link',
    'f_tts': 'Text to speech',
    'f_float': 'Floating button',
    'f_free_video': 'Free video',
    'history': 'History',
    'settings': 'Settings',
    'from': 'From',
    'to': 'To',
    'type_here': 'Type or paste text',
    'translate': 'Translate',
    'copy': 'Copy',
    'copied': 'Copied',
    'save': 'Save to history',
    'saved': 'Saved',
    'swap': 'Swap languages',
    'downloading': 'Downloading language pack (needs internet once)',
    'error': 'Translation failed. Check your internet for the first download.',
    'empty_history': 'No translations yet. Translate something and save it here.',
    'delete': 'Delete',
    'app_language': 'App language',
    'device_default': 'Device default',
    'font_color': 'Text color',
    'premium': 'Premium features',
    'premium_desc': 'Video dubbing, subtitles, PDF and voice will be added in the next phases.',
    'ok': 'OK',
    'gallery': 'Gallery',
    'camera': 'Camera',
    'ocr_note': 'Reads printed text in Latin letters (English, French, Spanish, German...). Arabic, Chinese and other scripts come in a later phase.',
    'no_text': 'No text found in the image.',
    'recognized': 'Text found',
    'tap_mic': 'Tap the mic and speak',
    'listening': 'Listening... tap to stop',
    'stt_unavailable': 'Speech recognition is not available. Allow the microphone and install the speech pack for this language in your phone settings.',
    'heard': 'You said',
    'speak': 'Listen',
    'stop': 'Stop',
    'voice_girl': 'Girl',
    'voice_boy': 'Boy',
    'voice_hint': 'The girl/boy tone is adjusted on your phone\'s own voice engine, so results vary by device.',
    'type_speak': 'Type the text to read aloud',
  },
  'ar': {
    'app_name': 'AI Translate ABC',
    'home_title': 'ماذا تريد أن تترجم؟',
    'free': 'مجاني',
    'paid': 'مدفوع',
    'soon': 'سيتم إضافتها في المرحلة القادمة',
    'f_text': 'النصوص',
    'f_image': 'الصور',
    'f_voice': 'الصوت',
    'f_pdf': 'ملفات PDF',
    'f_video_text': 'ترجمة الفيديو نصياً',
    'f_dub': 'دبلجة الفيديو',
    'f_link': 'رابط فيديو',
    'f_tts': 'نص إلى صوت',
    'f_float': 'الزر العائم',
    'f_free_video': 'فيديو مجاني',
    'history': 'السجل',
    'settings': 'الإعدادات',
    'from': 'من',
    'to': 'إلى',
    'type_here': 'اكتب النص أو الصقه هنا',
    'translate': 'ترجم',
    'copied': 'تم النسخ',
    'copy': 'نسخ',
    'save': 'حفظ في السجل',
    'saved': 'تم الحفظ',
    'swap': 'تبديل اللغتين',
    'downloading': 'جاري تحميل حزمة اللغة (تحتاج إنترنت مرة واحدة)',
    'error': 'فشلت الترجمة. تأكد من الإنترنت عند أول تحميل للغة.',
    'empty_history': 'لا توجد ترجمات بعد. ترجم شيئاً واحفظه هنا.',
    'delete': 'حذف',
    'app_language': 'لغة التطبيق',
    'device_default': 'لغة الجهاز',
    'font_color': 'لون الخط',
    'premium': 'المميزات المدفوعة',
    'premium_desc': 'الدبلجة وترجمة الفيديو و PDF والصوت ستضاف في المراحل القادمة.',
    'ok': 'حسناً',
    'gallery': 'المعرض',
    'camera': 'الكاميرا',
    'ocr_note': 'يقرأ النصوص المطبوعة بالحروف اللاتينية (إنجليزي، فرنسي، إسباني، ألماني...). العربية والصينية وباقي الأنظمة تضاف لاحقاً.',
    'no_text': 'لم يتم العثور على نص في الصورة.',
    'recognized': 'النص المقروء',
    'tap_mic': 'اضغط على الميكروفون وتحدث',
    'listening': 'أستمع... اضغط للإيقاف',
    'stt_unavailable': 'التعرف على الصوت غير متاح. اسمح بالميكروفون وثبّت حزمة الصوت لهذه اللغة من إعدادات الهاتف.',
    'heard': 'ما قلته',
    'speak': 'استماع',
    'stop': 'إيقاف',
    'voice_girl': 'بنت',
    'voice_boy': 'ولد',
    'voice_hint': 'نبرة بنت/ولد تُضبط عبر محرك الصوت في هاتفك، فقد تختلف النتيجة حسب الجهاز.',
    'type_speak': 'اكتب النص المراد نطقه',
  },
};

String tr(BuildContext context, String key) {
  final code = Localizations.localeOf(context).languageCode;
  return _t[code]?[key] ?? _t['en']![key] ?? key;
}

/// 59 languages supported on-device by Google ML Kit (bcp code -> [English, Arabic]).
const Map<String, List<String>> kLanguages = {
  'af': ['Afrikaans', 'الأفريقانية'],
  'sq': ['Albanian', 'الألبانية'],
  'ar': ['Arabic', 'العربية'],
  'be': ['Belarusian', 'البيلاروسية'],
  'bg': ['Bulgarian', 'البلغارية'],
  'bn': ['Bengali', 'البنغالية'],
  'ca': ['Catalan', 'الكتالونية'],
  'zh': ['Chinese', 'الصينية'],
  'hr': ['Croatian', 'الكرواتية'],
  'cs': ['Czech', 'التشيكية'],
  'da': ['Danish', 'الدنماركية'],
  'nl': ['Dutch', 'الهولندية'],
  'en': ['English', 'الإنجليزية'],
  'eo': ['Esperanto', 'الإسبرانتو'],
  'et': ['Estonian', 'الإستونية'],
  'fi': ['Finnish', 'الفنلندية'],
  'fr': ['French', 'الفرنسية'],
  'gl': ['Galician', 'الجاليكية'],
  'ka': ['Georgian', 'الجورجية'],
  'de': ['German', 'الألمانية'],
  'el': ['Greek', 'اليونانية'],
  'gu': ['Gujarati', 'الغوجاراتية'],
  'ht': ['Haitian Creole', 'الكريولية الهايتية'],
  'he': ['Hebrew', 'العبرية'],
  'hi': ['Hindi', 'الهندية'],
  'hu': ['Hungarian', 'المجرية'],
  'is': ['Icelandic', 'الآيسلندية'],
  'id': ['Indonesian', 'الإندونيسية'],
  'ga': ['Irish', 'الأيرلندية'],
  'it': ['Italian', 'الإيطالية'],
  'ja': ['Japanese', 'اليابانية'],
  'kn': ['Kannada', 'الكانادا'],
  'ko': ['Korean', 'الكورية'],
  'lt': ['Lithuanian', 'الليتوانية'],
  'lv': ['Latvian', 'اللاتفية'],
  'mk': ['Macedonian', 'المقدونية'],
  'mr': ['Marathi', 'الماراثية'],
  'ms': ['Malay', 'الماليزية'],
  'mt': ['Maltese', 'المالطية'],
  'no': ['Norwegian', 'النرويجية'],
  'fa': ['Persian', 'الفارسية'],
  'pl': ['Polish', 'البولندية'],
  'pt': ['Portuguese', 'البرتغالية'],
  'ro': ['Romanian', 'الرومانية'],
  'ru': ['Russian', 'الروسية'],
  'sk': ['Slovak', 'السلوفاكية'],
  'sl': ['Slovenian', 'السلوفينية'],
  'es': ['Spanish', 'الإسبانية'],
  'sv': ['Swedish', 'السويدية'],
  'sw': ['Swahili', 'السواحيلية'],
  'tl': ['Tagalog', 'التاغالوغية'],
  'ta': ['Tamil', 'التاميلية'],
  'te': ['Telugu', 'التيلوغوية'],
  'th': ['Thai', 'التايلاندية'],
  'tr': ['Turkish', 'التركية'],
  'uk': ['Ukrainian', 'الأوكرانية'],
  'ur': ['Urdu', 'الأردية'],
  'vi': ['Vietnamese', 'الفيتنامية'],
  'cy': ['Welsh', 'الويلزية'],
};

String languageName(String code, String appLang) {
  final n = kLanguages[code];
  if (n == null) return code;
  return appLang == 'ar' ? n[1] : n[0];
}


class HistoryItem {
  final String source;
  final String target;
  final String from;
  final String to;
  final DateTime time;

  HistoryItem({
    required this.source,
    required this.target,
    required this.from,
    required this.to,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'source': source,
        'target': target,
        'from': from,
        'to': to,
        'time': time.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        source: j['source'],
        target: j['target'],
        from: j['from'],
        to: j['to'],
        time: DateTime.parse(j['time']),
      );
}

class AppState extends ChangeNotifier {
  /// null = follow device language.
  String? localeCode;
  int fontColorIndex = 0;
  List<HistoryItem> history = [];

  /// Default text color + 3 extra colors the user can choose from.
  static const List<Color> fontColors = [
    Color(0xFF14213D),
    Color(0xFF0B6E4F),
    Color(0xFF8A2BE2),
    Color(0xFFB3261E),
  ];

  Color get fontColor => fontColors[fontColorIndex];
  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  late SharedPreferences _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    localeCode = _prefs.getString('locale');
    fontColorIndex = _prefs.getInt('fontColor') ?? 0;
    final raw = _prefs.getString('history');
    if (raw != null) {
      history = (jsonDecode(raw) as List)
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> setLocale(String? code) async {
    localeCode = code;
    code == null ? await _prefs.remove('locale') : await _prefs.setString('locale', code);
    notifyListeners();
  }

  Future<void> setFontColor(int i) async {
    fontColorIndex = i;
    await _prefs.setInt('fontColor', i);
    notifyListeners();
  }

  Future<void> addHistory(HistoryItem item) async {
    history.insert(0, item);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeHistory(HistoryItem item) async {
    history.remove(item);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() =>
      _prefs.setString('history', jsonEncode(history.map((e) => e.toJson()).toList()));
}


/// On-device translation (Google ML Kit). Language packs download once, then work offline.
class TranslatorService {
  static final OnDeviceTranslatorModelManager _manager = OnDeviceTranslatorModelManager();

  static Future<String> translate(
    String text,
    String from,
    String to, {
    void Function(bool downloading)? onDownloading,
  }) async {
    if (from == to) return text;
    for (final code in [from, to]) {
      if (!await _manager.isModelDownloaded(code)) {
        onDownloading?.call(true);
        await _manager.downloadModel(code);
      }
    }
    onDownloading?.call(false);
    final translator = OnDeviceTranslator(
      sourceLanguage: BCP47Code.fromRawValue(from)!,
      targetLanguage: BCP47Code.fromRawValue(to)!,
    );
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  }
}

const Map<String, String> _ttsOverrides = {
  'zh': 'zh-CN',
  'en': 'en-US',
  'pt': 'pt-BR',
  'no': 'nb-NO',
  'he': 'he-IL',
  'ar': 'ar',
};

/// Text-to-speech using the phone's own voice engine (no server).
class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text, String lang, {required bool male}) async {
    await _tts.stop();
    await _tts.setLanguage(_ttsOverrides[lang] ?? lang);
    await _tts.setPitch(male ? 0.75 : 1.25);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  static Future<void> stop() => _tts.stop();
}



class LangDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const LangDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final appLang = Localizations.localeOf(context).languageCode;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
        ),
      ),
      items: kLanguages.keys
          .map((c) => DropdownMenuItem(value: c, child: Text(languageName(c, appLang))))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}

class LanguageBar extends StatelessWidget {
  final String from;
  final String to;
  final ValueChanged<String> onFrom;
  final ValueChanged<String> onTo;
  final VoidCallback onSwap;
  const LanguageBar({
    super.key,
    required this.from,
    required this.to,
    required this.onFrom,
    required this.onTo,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: LangDropdown(value: from, onChanged: onFrom)),
        IconButton(
          tooltip: tr(context, 'swap'),
          onPressed: onSwap,
          icon: const Icon(Icons.swap_horiz),
        ),
        Expanded(child: LangDropdown(value: to, onChanged: onTo)),
      ],
    );
  }
}

/// Translation result with copy / save / listen actions.
class ResultCard extends StatelessWidget {
  final String text;
  final String source;
  final String from;
  final String to;
  const ResultCard({
    super.key,
    required this.text,
    required this.source,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(text, style: const TextStyle(fontSize: 18, height: 1.5)),
          const SizedBox(height: 8),
          Wrap(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(tr(context, 'copied'))));
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(tr(context, 'copy')),
              ),
              TextButton.icon(
                onPressed: () async {
                  await context.read<AppState>().addHistory(HistoryItem(
                        source: source,
                        target: text,
                        from: from,
                        to: to,
                        time: DateTime.now(),
                      ));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(tr(context, 'saved'))));
                  }
                },
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: Text(tr(context, 'save')),
              ),
              TextButton.icon(
                onPressed: () => TtsService.speak(text, to, male: false),
                icon: const Icon(Icons.volume_up_outlined, size: 18),
                label: Text(tr(context, 'speak')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _Feature {
  final String key;
  final IconData icon;
  final bool paid;
  final Widget Function()? page;
  bool get ready => page != null;
  const _Feature(this.key, this.icon, {this.paid = false, this.page});
}

final _features = [
  _Feature('f_text', Icons.translate, page: () => const TextTranslateScreen()),
  _Feature('f_image', Icons.image_outlined, page: () => const ImageTranslateScreen()),
  _Feature('f_voice', Icons.mic_none, page: () => const VoiceTranslateScreen()),
  _Feature('f_pdf', Icons.picture_as_pdf_outlined, paid: true),
  _Feature('f_video_text', Icons.subtitles_outlined, paid: true),
  _Feature('f_dub', Icons.record_voice_over_outlined, paid: true),
  _Feature('f_link', Icons.link, paid: true),
  _Feature('f_tts', Icons.volume_up_outlined, paid: true, page: () => const TtsScreen()),
  _Feature('f_float', Icons.bubble_chart_outlined, paid: true),
  _Feature('f_free_video', Icons.ondemand_video_outlined),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, _Feature f) {
    if (f.ready) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => f.page!()));
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(tr(context, f.key)),
          content: Text(tr(context, 'soon')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(context, 'ok'))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'app_name'), style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: tr(context, 'history'),
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            tooltip: tr(context, 'settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(tr(context, 'home_title'),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, i) {
              final f = _features[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _open(context, f),
                child: Ink(
                  decoration: BoxDecoration(
                    color: f.ready ? scheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDDE3EE)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(f.icon,
                              size: 28, color: f.ready ? Colors.white : scheme.primary),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: f.paid ? const Color(0xFFFFE9A8) : const Color(0xFFDFF5E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tr(context, f.paid ? 'paid' : 'free'),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF3A3A3A),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(tr(context, f.key),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: f.ready ? Colors.white : null)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



/// Phase 1: on-device text translation (free, offline after first language download).
class TextTranslateScreen extends StatefulWidget {
  const TextTranslateScreen({super.key});

  @override
  State<TextTranslateScreen> createState() => _TextTranslateScreenState();
}

class _TextTranslateScreenState extends State<TextTranslateScreen> {
  final _input = TextEditingController();
  final _modelManager = OnDeviceTranslatorModelManager();

  String _from = 'en';
  String _to = 'ar';
  String _result = '';
  bool _busy = false;
  bool _downloading = false;
  bool _failed = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _ensureModel(String code) async {
    if (!await _modelManager.isModelDownloaded(code)) {
      setState(() => _downloading = true);
      await _modelManager.downloadModel(code);
      setState(() => _downloading = false);
    }
  }

  Future<void> _translate() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await _ensureModel(_from);
      await _ensureModel(_to);
      final translator = OnDeviceTranslator(
        sourceLanguage: BCP47Code.fromRawValue(_from)!,
        targetLanguage: BCP47Code.fromRawValue(_to)!,
      );
      final out = await translator.translateText(text);
      await translator.close();
      setState(() => _result = out);
    } catch (_) {
      setState(() {
        _failed = true;
        _downloading = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
      if (_result.isNotEmpty) {
        _input.text = _result;
        _result = '';
      }
    });
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final appLang = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;

    Widget picker(String value, ValueChanged<String> onChanged) {
      return Expanded(
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
            ),
          ),
          items: kLanguages.keys
              .map((c) => DropdownMenuItem(value: c, child: Text(languageName(c, appLang))))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'f_text'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              picker(_from, (v) => setState(() => _from = v)),
              IconButton(
                tooltip: tr(context, 'swap'),
                onPressed: _swap,
                icon: const Icon(Icons.swap_horiz),
              ),
              picker(_to, (v) => setState(() => _to = v)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            minLines: 5,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: tr(context, 'type_here'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _translate,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.translate),
            label: Text(tr(context, 'translate')),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'downloading'), textAlign: TextAlign.center),
            ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'error'),
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
            ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(_result, style: const TextStyle(fontSize: 18, height: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _result));
                          _snack(tr(context, 'copied'));
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: Text(tr(context, 'copy')),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await context.read<AppState>().addHistory(HistoryItem(
                                source: _input.text.trim(),
                                target: _result,
                                from: _from,
                                to: _to,
                                time: DateTime.now(),
                              ));
                          _snack(tr(context, 'saved'));
                        },
                        icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                        label: Text(tr(context, 'save')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}




/// On-device OCR (Google ML Kit) + on-device translation.
class ImageTranslateScreen extends StatefulWidget {
  const ImageTranslateScreen({super.key});

  @override
  State<ImageTranslateScreen> createState() => _ImageTranslateScreenState();
}

class _ImageTranslateScreenState extends State<ImageTranslateScreen> {
  final _picker = ImagePicker();
  String _from = 'en';
  String _to = 'ar';
  String _recognized = '';
  String _result = '';
  File? _image;
  bool _busy = false;
  bool _downloading = false;
  bool _failed = false;
  bool _noText = false;

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(source: source, imageQuality: 90);
    if (x == null) return;
    setState(() {
      _image = File(x.path);
      _busy = true;
      _failed = false;
      _noText = false;
      _recognized = '';
      _result = '';
    });
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final res = await recognizer.processImage(InputImage.fromFilePath(x.path));
      await recognizer.close();
      if (res.text.trim().isEmpty) {
        setState(() => _noText = true);
        return;
      }
      setState(() => _recognized = res.text);
      final out = await TranslatorService.translate(res.text, _from, _to,
          onDownloading: (d) {
        if (mounted) setState(() => _downloading = d);
      });
      setState(() => _result = out);
    } catch (_) {
      setState(() {
        _failed = true;
        _downloading = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'f_image'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LanguageBar(
            from: _from,
            to: _to,
            onFrom: (v) => setState(() => _from = v),
            onTo: (v) => setState(() => _to = v),
            onSwap: _swap,
          ),
          const SizedBox(height: 8),
          Text(tr(context, 'ocr_note'), style: const TextStyle(fontSize: 12.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(tr(context, 'gallery')),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(tr(context, 'camera')),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'downloading'), textAlign: TextAlign.center),
            ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'error'),
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
            ),
          if (_noText)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'no_text'), textAlign: TextAlign.center),
            ),
          if (_image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_image!, height: 220, fit: BoxFit.cover),
            ),
          ],
          if (_recognized.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(tr(context, 'recognized'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SelectableText(_recognized),
          ],
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            ResultCard(text: _result, source: _recognized, from: _from, to: _to),
          ],
        ],
      ),
    );
  }
}



/// Speak -> on-device recognition -> on-device translation -> spoken result.
class VoiceTranslateScreen extends StatefulWidget {
  const VoiceTranslateScreen({super.key});

  @override
  State<VoiceTranslateScreen> createState() => _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends State<VoiceTranslateScreen> {
  final _stt = SpeechToText();
  String _from = 'en';
  String _to = 'ar';
  String _heard = '';
  String _result = '';
  bool _available = true;
  bool _listening = false;
  bool _busy = false;
  bool _downloading = false;
  bool _failed = false;

  @override
  void dispose() {
    _stt.cancel();
    TtsService.stop();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_heard.trim().isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final out = await TranslatorService.translate(_heard, _from, _to,
          onDownloading: (d) {
        if (mounted) setState(() => _downloading = d);
      });
      setState(() => _result = out);
      await TtsService.speak(out, _to, male: false);
    } catch (_) {
      setState(() {
        _failed = true;
        _downloading = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle() async {
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      await _translate();
      return;
    }
    final ok = await _stt.initialize(
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'done' || s == 'notListening') {
          if (_listening) {
            setState(() => _listening = false);
            _translate();
          }
        }
      },
    );
    if (!ok) {
      setState(() => _available = false);
      return;
    }
    setState(() {
      _available = true;
      _heard = '';
      _result = '';
    });
    final locales = await _stt.locales();
    final match = locales
        .where((l) => l.localeId.toLowerCase().startsWith(_from.toLowerCase()))
        .toList();
    await _stt.listen(
      onResult: (r) => setState(() => _heard = r.recognizedWords),
      localeId: match.isNotEmpty ? match.first.localeId : null,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
    );
    setState(() => _listening = true);
  }

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'f_voice'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LanguageBar(
            from: _from,
            to: _to,
            onFrom: (v) => setState(() => _from = v),
            onTo: (v) => setState(() => _to = v),
            onSwap: _swap,
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: _busy ? null : _toggle,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _listening ? scheme.error : scheme.primary,
                ),
                child: Icon(_listening ? Icons.stop : Icons.mic,
                    color: Colors.white, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(tr(context, _listening ? 'listening' : 'tap_mic'), textAlign: TextAlign.center),
          if (!_available)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'stt_unavailable'),
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
            ),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'downloading'), textAlign: TextAlign.center),
            ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(tr(context, 'error'),
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
            ),
          if (_heard.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(tr(context, 'heard'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SelectableText(_heard, style: const TextStyle(fontSize: 17)),
          ],
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            ResultCard(text: _result, source: _heard, from: _from, to: _to),
          ],
        ],
      ),
    );
  }
}



/// Text to speech with two tones (girl / boy) using the phone's voice engine.
class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final _input = TextEditingController();
  String _lang = 'en';
  bool _male = false;

  @override
  void dispose() {
    TtsService.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'f_tts'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LangDropdown(value: _lang, onChanged: (v) => setState(() => _lang = v)),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.face_3_outlined),
                  label: Text(tr(context, 'voice_girl'))),
              ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.face_6_outlined),
                  label: Text(tr(context, 'voice_boy'))),
            ],
            selected: {_male},
            onSelectionChanged: (v) => setState(() => _male = v.first),
          ),
          const SizedBox(height: 8),
          Text(tr(context, 'voice_hint'), style: const TextStyle(fontSize: 12.5)),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            minLines: 5,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: tr(context, 'type_speak'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final t = _input.text.trim();
                    if (t.isNotEmpty) TtsService.speak(t, _lang, male: _male);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(tr(context, 'speak')),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: TtsService.stop,
                  icon: const Icon(Icons.stop),
                  label: Text(tr(context, 'stop')),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final appLang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'history'))),
      body: state.history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(tr(context, 'empty_history'), textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = state.history[i];
                return Dismissible(
                  key: ValueKey(item.time.toIso8601String()),
                  background: Container(
                    decoration: BoxDecoration(
                        color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                    alignment: AlignmentDirectional.centerStart,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => state.removeHistory(item),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFDDE3EE)),
                    ),
                    child: ListTile(
                      title: Text(item.target, maxLines: 3, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${languageName(item.from, appLang)} ← ${languageName(item.to, appLang)}\n${item.source}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: item.target));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr(context, 'copied'))));
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}



class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr(context, 'app_language'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<String?>(
            segments: [
              ButtonSegment(value: null, label: Text(tr(context, 'device_default'))),
              const ButtonSegment(value: 'en', label: Text('English')),
              const ButtonSegment(value: 'ar', label: Text('العربية')),
            ],
            selected: {s.localeCode},
            onSelectionChanged: (v) => s.setLocale(v.first),
          ),
          const SizedBox(height: 28),
          Text(tr(context, 'font_color'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < AppState.fontColors.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 14),
                  child: GestureDetector(
                    onTap: () => s.setFontColor(i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppState.fontColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: s.fontColorIndex == i ? scheme.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: s.fontColorIndex == i
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(context, 'premium'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                Text(tr(context, 'premium_desc')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(ChangeNotifierProvider.value(value: state, child: const TranslateApp()));
}

class TranslateApp extends StatelessWidget {
  const TranslateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    const cobalt = Color(0xFF2F5BEA);
    return MaterialApp(
      title: 'AI Translate ABC',
      debugShowCheckedModeBanner: false,
      locale: s.locale, // null -> device language, falls back to English
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: cobalt),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        textTheme: Typography.blackMountainView.apply(
          bodyColor: s.fontColor,
          displayColor: s.fontColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8FB),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
