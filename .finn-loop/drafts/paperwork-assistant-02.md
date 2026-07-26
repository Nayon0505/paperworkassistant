## Problem

Sensible Dokumente und Metadaten müssen ausschließlich lokal, verschlüsselt und migrationsfähig gespeichert werden.

## Acceptance Criteria

- [ ] AC-2.1 — Drift/SQLite speichert versionierte Datensätze für Dokumente, Seiten, Analyseergebnisse, Fristen und nächste Schritte.
- [ ] AC-2.2 — Beim ersten Start wird ein installationsgebundener Schlüssel erzeugt und ausschließlich über Android Keystore beziehungsweise iOS Keychain verwaltet.
- [ ] AC-2.3 — Datenbank und Originalseiten sind im Ruhezustand verschlüsselt; Originaldateien verwenden authentifizierte Verschlüsselung und liegen im privaten App-Verzeichnis.
- [ ] AC-2.4 — Temporäre Klartextdateien werden nach Erfolg, Fehler und Abbruch entfernt.
- [ ] AC-2.5 — Datenbank und Dokumentdateien sind von automatischen Betriebssystem- und Cloud-Backups ausgeschlossen.
- [ ] AC-2.6 — Schema-Version 1 besitzt Migrationstests; es gibt keine Migration bestehender Nutzerdaten, da das Produkt neu ist.
- [ ] AC-2.7 — Persistierte Dokumente und Statuswerte bleiben nach einem App-Neustart erhalten.

## Non-goals

- NG-2.1 — Keine biometrische oder PIN-basierte App-Sperre.
- NG-2.2 — Keine Cloud-Synchronisierung oder Schlüsselwiederherstellung.
- NG-2.3 — Noch keine Benutzeroberfläche für Importe oder Analyse.

## Relevant files

- apps/mobile/lib/data/database — Drift-Schema und Migrationen
- apps/mobile/lib/data/secure_storage — Schlüsselverwaltung
- apps/mobile/lib/data/document_files — Verschlüsselter Dateispeicher
- apps/mobile/android/app/src/main — Android-Backupausschlüsse
- apps/mobile/ios/Runner — iOS-Dateischutz und Backupausschlüsse
- apps/mobile/test/data — Persistenz-, Verschlüsselungs- und Migrationstests

## Test expectations

- Automatisierte Tests für Schlüsselwiederverwendung, Verschlüsselung, Neustartpersistenz, Kaskadenlöschung, temporäre Dateien und Schema-Migration.

## How to verify

1. Testdokument speichern, App neu starten und Datensatz erneut laden.
2. App-Container inspizieren und bestätigen, dass Originalinhalt und Datenbankwerte nicht als Klartext lesbar sind.
3. Dokument löschen und prüfen, dass Datensätze und verschlüsselte Dateien entfernt wurden.
