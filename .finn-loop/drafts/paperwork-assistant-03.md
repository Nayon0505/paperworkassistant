## Problem

Nutzer benötigen eine übersichtliche lokale Bibliothek, in der gespeicherte Dokumente und ihr Bearbeitungsstatus nachvollziehbar sind.

## Acceptance Criteria

- [ ] AC-3.1 — Der Posteingang sortiert Dokumente absteigend nach Importzeit.
- [ ] AC-3.2 — Jeder Eintrag zeigt Titel, Absender, Dokumentdatum und Analysestatus; fehlende Werte erscheinen als „Nicht erkannt“.
- [ ] AC-3.3 — Bis eine Analyse vorliegt, dient der ursprüngliche Dateiname beziehungsweise „Gescanntes Dokument“ als Titel.
- [ ] AC-3.4 — Tippen auf einen Eintrag öffnet eine Detailansicht mit Originalseiten und vorhandenen Metadaten.
- [ ] AC-3.5 — Löschen verlangt eine Bestätigung und entfernt danach Dokument, Seiten, Metadaten, Fristen und nächste Schritte vollständig.
- [ ] AC-3.6 — Leerer Zustand, Liste, Detailansicht und Löschdialog sind auf Deutsch und Englisch verfügbar.
- [ ] AC-3.7 — Die Oberfläche bildet die Statuswerte „Analyse ausstehend“, „Wird analysiert“, „Abgeschlossen“, „Kein verwertbarer Inhalt“ und „Fehlgeschlagen“ eindeutig ab.

## Non-goals

- NG-3.1 — Noch kein Kamera- oder Dateiimport.
- NG-3.2 — Noch keine Analyse oder Bearbeitung erkannter Felder.
- NG-3.3 — Noch keine Erinnerungsplanung.

## Relevant files

- apps/mobile/lib/features/inbox — Posteingang und leerer Zustand
- apps/mobile/lib/features/document_detail — Dokumentdetail und Originalvorschau
- apps/mobile/lib/data/document_repository.dart — Abfragen und Kaskadenlöschung
- apps/mobile/test/features — Widget- und Repositorytests

## Test expectations

- Widgettests für leeren und befüllten Posteingang, Sortierung, Fallbackwerte, Statusdarstellung, Navigation und bestätigtes beziehungsweise abgebrochenes Löschen.

## How to verify

1. Testdaten mit unterschiedlichen Importzeiten und Statuswerten laden und Sortierung sowie Texte prüfen.
2. Ein Dokument öffnen und die Originalvorschau kontrollieren.
3. Löschen zunächst abbrechen und anschließend bestätigen; danach App neu starten und das vollständige Entfernen prüfen.
