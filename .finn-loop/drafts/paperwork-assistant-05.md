## Problem

Papierdokumente müssen als kontrollierbarer mehrseitiger Scan direkt in die lokale Dokumentenbibliothek übernommen werden können.

## Acceptance Criteria

- [ ] AC-5.1 — Die Kameraaktion fordert Berechtigung erst bei ihrer ersten Verwendung an.
- [ ] AC-5.2 — Bei verweigerter Berechtigung bleibt die App nutzbar und zeigt Erklärung sowie Schaltfläche zu den Systemeinstellungen.
- [ ] AC-5.3 — Ein Scan kann bis zu 20 Seiten enthalten und erlaubt vor dem Speichern Hinzufügen, Entfernen, Drehen und Neuordnen.
- [ ] AC-5.4 — Überschreitet der Scan 20 MB, wird das Speichern mit einer verständlichen Meldung verhindert.
- [ ] AC-5.5 — Bestätigen erzeugt genau ein verschlüsseltes lokales Dokument mit Status „Analyse ausstehend“.
- [ ] AC-5.6 — Abbruch entfernt sämtliche temporären Aufnahmen und erzeugt keinen Posteingangseintrag.
- [ ] AC-5.7 — Die Seitenreihenfolge in der Originalvorschau entspricht der bestätigten Reihenfolge im Editor.

## Non-goals

- NG-5.1 — Keine automatische Kantenerkennung oder Bildverbesserung über die Fähigkeiten der gewählten Scanbibliothek hinaus.
- NG-5.2 — Kein gleichzeitiges Erzeugen mehrerer Kameradokumente in einem Scanvorgang.
- NG-5.3 — Noch keine OCR oder KI-Analyse.

## Relevant files

- apps/mobile/lib/features/import/camera_scan — Aufnahme und Seiteneditor
- apps/mobile/lib/features/import/camera_permissions.dart — Berechtigungszustände
- apps/mobile/lib/data/document_import_service.dart — Übernahme in verschlüsselten Speicher
- apps/mobile/test/features/import/camera_scan — Kamera- und Editortests

## Test expectations

- Widget-/Integrationstests für Berechtigung, Mehrseitigkeit, Bearbeitungsaktionen, Grenzwerte, Abbruch und gespeicherte Reihenfolge.

## How to verify

1. Kamerazugriff ablehnen und Einstellungsaktion sowie weiterhin verfügbaren Dateiimport prüfen.
2. Zugriff erlauben, drei Seiten aufnehmen, eine drehen, Reihenfolge ändern und eine weitere Seite hinzufügen.
3. Scan speichern, Posteingangseintrag öffnen und die bestätigte Seitenfolge prüfen.
4. Einen zweiten Scan abbrechen und temporäre sowie dauerhafte Ablage kontrollieren.
