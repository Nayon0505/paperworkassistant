import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const PaperworkAssistantApp());
}

class PaperworkAssistantApp extends StatelessWidget {
  const PaperworkAssistantApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppStrings.of(context).appName,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('de')],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale?.languageCode == 'de') {
          return const Locale('de');
        }
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315B7D)),
        useMaterial3: true,
      ),
      home: const DocumentInboxScreen(),
    );
  }
}

class DocumentInboxScreen extends StatelessWidget {
  const DocumentInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.appName)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 88,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.emptyInboxTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.emptyInboxBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('camera-import'),
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(strings.cameraImport),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('file-import'),
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(strings.fileImport),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  bool get _isGerman => locale.languageCode == 'de';

  String get appName => 'Paperwork Assistant';
  String get emptyInboxTitle =>
      _isGerman ? 'Dein Posteingang ist leer' : 'Your inbox is empty';
  String get emptyInboxBody => _isGerman
      ? 'Importiere dein erstes Dokument, um loszulegen.'
      : 'Import your first document to get started.';
  String get cameraImport =>
      _isGerman ? 'Mit Kamera importieren' : 'Import with camera';
  String get fileImport => _isGerman ? 'Datei importieren' : 'Import file';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'de';

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
