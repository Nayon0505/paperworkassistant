## Problem

Das Repository enthält noch keine ausführbare Anwendung oder Backend-Struktur. Mobile App, API und gemeinsamer Analysevertrag benötigen ein reproduzierbares Grundgerüst.

## Acceptance Criteria

- [ ] AC-1.1 — Das Repository enthält `apps/mobile`, `services/api` und `packages/contracts` mit dokumentierten Installations-, Start- und Testbefehlen.
- [ ] AC-1.2 — Die Flutter-App läuft unter Android und iOS als `Paperwork Assistant` mit der Kennung `de.nayon.paperworkassistant`.
- [ ] AC-1.3 — Die App unterstützt Deutsch und Englisch, folgt der Gerätesprache und verwendet Englisch für nicht unterstützte Gerätesprachen.
- [ ] AC-1.4 — Die Startansicht zeigt einen leeren Dokumenten-Posteingang mit primären Aktionen für Kamera- und Dateiimport.
- [ ] AC-1.5 — Der Fastify-Dienst stellt einen getesteten Health-Endpunkt bereit und kann lokal sowie über Docker gestartet werden.
- [ ] AC-1.6 — Flutter-Analyse und -Tests sowie API-Linting und -Tests laufen erfolgreich.

## Non-goals

- NG-1.1 — Noch keine Dokumentpersistenz oder funktionsfähigen Importe.
- NG-1.2 — Noch keine KI-Integration.
- NG-1.3 — Noch kein Deployment in eine Produktionsumgebung.

## Relevant files

- README.md — Monorepo-Einrichtung und Arbeitsbefehle
- apps/mobile/pubspec.yaml — Flutter-Abhängigkeiten und App-Metadaten
- apps/mobile/lib/main.dart — App-Einstieg und lokalisierte Startansicht
- services/api/package.json — Node-/Fastify-Konfiguration
- services/api/src/server.ts — API-Einstieg und Health-Endpunkt
- packages/contracts — Gemeinsame API- und Analyseschemata

## Test expectations

- Flutter-Widgettest für beide Sprachen und den leeren Posteingang; API-Test für den Health-Endpunkt; erfolgreiche statische Analysen beider Projekte.

## How to verify

1. App auf einem Android- und iOS-Ziel starten und deutschen sowie englischen leeren Posteingang prüfen.
2. API lokal und per Docker starten und den Health-Endpunkt aufrufen.
3. Alle im README dokumentierten Analyse-, Lint- und Testbefehle ausführen.
