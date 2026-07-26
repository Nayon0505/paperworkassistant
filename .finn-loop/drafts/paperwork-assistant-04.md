## Problem

Nutzer sollen vorhandene PDFs und Bilder als ein oder mehrere lokale Dokumente importieren und ihre Gruppierung vor dem Speichern kontrollieren können.

## Acceptance Criteria

- [ ] AC-4.1 — Der Dateiimport akzeptiert PDF, JPEG und PNG.
- [ ] AC-4.2 — Jede ausgewählte PDF bildet ein eigenes Dokument; ausgewählte Bilder können in der Vorschau auf mehrere Dokumentgruppen verteilt und innerhalb einer Gruppe sortiert werden.
- [ ] AC-4.3 — Ein Importvorgang akzeptiert höchstens zehn Dokumente; jedes Dokument höchstens 20 Seiten und 20 MB.
- [ ] AC-4.4 — Beschädigte, nicht unterstützte oder zu große Eingaben werden vor dauerhafter Ablage mit einer konkreten lokalisierten Meldung abgelehnt.
- [ ] AC-4.5 — Gültige Dokumente eines teilweise ungültigen Batches können gespeichert werden; abgelehnte Elemente werden abschließend einzeln aufgelistet.
- [ ] AC-4.6 — Jedes gespeicherte Dokument erhält sofort den Status „Analyse ausstehend“ und erscheint unabhängig von anderen Batch-Dokumenten im Posteingang.
- [ ] AC-4.7 — Identische Dateien dürfen mehrfach als eigenständige Dokumente importiert werden.
- [ ] AC-4.8 — Abbruch vor der Bestätigung erzeugt keine Dokumente und hinterlässt keine temporären Dateien.

## Non-goals

- NG-4.1 — Keine Kameraufnahme.
- NG-4.2 — Noch kein automatischer Start der KI-Analyse.
- NG-4.3 — Keine automatische Duplikaterkennung oder Zusammenführung.

## Relevant files

- apps/mobile/lib/features/import/file_import — Dateiauswahl und Validierung
- apps/mobile/lib/features/import/grouping — Bildgruppierung und Sortierung
- apps/mobile/lib/data/document_import_service.dart — Sichere dauerhafte Ablage
- apps/mobile/test/features/import — Import- und Grenzfalltests

## Test expectations

- Tests mit gültigen und ungültigen Formaten, Seiten-/Größengrenzen, zehn Dokumenten, gemischten Batches, mehreren Bildgruppen, Duplikaten und Abbruch.

## How to verify

1. Zwei PDFs und mehrere Bilder auswählen, Bilder auf zwei Gruppen verteilen und den Batch speichern.
2. Prüfen, dass vier getrennte Dokumente mit Status „Analyse ausstehend“ erscheinen.
3. Einen gemischten Batch mit einer beschädigten und einer zu großen Datei importieren und die Teilfehler prüfen.
4. Einen Import abbrechen und bestätigen, dass kein neuer Eintrag entstanden ist.
