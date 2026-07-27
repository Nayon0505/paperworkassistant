# Paperwork Assistant

Plattformübergreifendes Flutter-Grundgerüst für eine deutsche Anwendung, die
Schreiben verständlich aufbereitet. Der aktuelle Stand umfasst die öffentliche
Landingpage, das Designsystem und gekennzeichnete App-Seitengerüste. Es gibt
noch keine echte Authentifizierung oder Dokumentverarbeitung.

## Voraussetzungen

- Flutter 3.44 oder neuer auf dem stabilen Kanal
- Dart 3.12 oder neuer (wird mit Flutter installiert)
- Für iOS: macOS mit Xcode und CocoaPods
- Für Android: Android Studio bzw. ein eingerichtetes Android SDK
- Für Web: Chrome oder ein anderer unterstützter Browser

Die Installation lässt sich mit `flutter doctor` prüfen.

## Lokale Einrichtung

```powershell
flutter pub get
flutter analyze
flutter test
```

Für die App selbst werden aktuell keine Umgebungsvariablen benötigt. Die
lokale `.env` ist ausschließlich für den Finn-Workflow vorgesehen und wird
nicht in Git eingecheckt. Als Vorlage dient `.env.example`.

## Plattformen starten

Verfügbare Geräte anzeigen:

```powershell
flutter devices
```

Web:

```powershell
flutter run -d chrome
```

Android (bei laufendem Emulator oder angeschlossenem Gerät):

```powershell
flutter run -d <android-device-id>
```

iOS auf macOS (bei laufendem Simulator):

```powershell
flutter run -d <ios-device-id>
```

Alle Plattformen verwenden denselben Einstiegspunkt in `lib/main.dart`.

## Routen

- `/` — öffentliche Landingpage
- `/app/overview` — Übersicht
- `/app/documents` — Dokumente
- `/app/tasks` — Aufgaben und Fristen
- `/app/profile` — Profil
- `/app/settings` — Einstellungen

Die `/app/*`-Routen sind derzeit UI-Seitengerüste. Eine echte Zugriffskontrolle
wird erst mit der späteren Authentifizierungsfunktion ergänzt.

## Projektstruktur

- `lib/app/` — App-Einstieg, Routing, Theme und wiederverwendbare Tokens
- `lib/features/landing/` — öffentliche Landingpage
- `lib/features/shell/` — responsive Navigation und App-Seitengerüste
- `test/` — Widgettests für Landingpage, Routen und responsive Navigation

## Finn-Workflow

- `$finn-spec` erstellt nach Freigabe einen Linear-Vertrag.
- `$finn-build` implementiert genau ein `agent-ready`-Issue und eröffnet einen
  Pull Request.
- `$finn-review` prüft den Pull Request in einem separaten frischen Chat.

Gemerged wird weiterhin durch einen Menschen.
