## Problem

Automatisch übernommene Ergebnisse müssen verständlich, belegbar und nach Abschluss vollständig korrigierbar sein.

## Acceptance Criteria

- [ ] AC-9.1 — Die Detailansicht zeigt Titel, Absender, Dokumentdatum, drei bis fünf Zusammenfassungspunkte, Fristen und nächste Schritte.
- [ ] AC-9.2 — Fehlende Titel-, Absender- oder Datumswerte erscheinen ausdrücklich als „Nicht erkannt“.
- [ ] AC-9.3 — Fristen und nächste Schritte zeigen ihren Originaltext und die zugehörige Seite; Antippen öffnet die passende Originalseite.
- [ ] AC-9.4 — Relative Fristen zeigen zusätzlich die gespeicherte Berechnungsgrundlage.
- [ ] AC-9.5 — Nächste Schritte sind separate Einträge und zeigen ihre optionale Verknüpfung zu einer Frist.
- [ ] AC-9.6 — Nach abgeschlossener Analyse lassen sich alle Ergebnisfelder bearbeiten sowie Fristen und nächste Schritte hinzufügen oder löschen.
- [ ] AC-9.7 — Manuelle Änderungen werden sofort lokal gespeichert, als „Manuell geändert“ markiert und aktualisieren die Werte im Posteingang.
- [ ] AC-9.8 — Ursprüngliche Quellenstellen bleiben nach manuellen Änderungen erhalten, werden aber visuell von manuell geänderten Werten unterschieden.
- [ ] AC-9.9 — Es gibt keine vorgeschaltete Prüf- oder Freigabeseite; erfolgreiche Ergebnisse werden automatisch übernommen und später editiert.

## Non-goals

- NG-9.1 — Keine erneute Analyse bereits erfolgreich abgeschlossener Dokumente.
- NG-9.2 — Keine gemeinsame Bearbeitung oder Versionshistorie.
- NG-9.3 — Noch keine Benachrichtigungsplanung.

## Relevant files

- apps/mobile/lib/features/document_detail/analysis_result — Ergebnisdarstellung
- apps/mobile/lib/features/document_detail/analysis_editor — Bearbeitungsoberfläche
- apps/mobile/lib/features/document_detail/source_reference.dart — Originalstellen-Navigation
- apps/mobile/lib/data/document_repository.dart — Atomare Bearbeitungen
- apps/mobile/test/features/document_detail — Darstellungs- und Bearbeitungstests

## Test expectations

- Widget-/Integrationstests für vollständige und teilweise Ergebnisse, Quellenstellen, relative Fristen, manuelle Markierungen, Hinzufügen/Löschen und sofortige Aktualisierung des Posteingangs.

## How to verify

1. Dokument mit vollständigem Ergebnis öffnen und jede Quellenstelle zur richtigen Seite verfolgen.
2. Dokument mit fehlenden Feldern öffnen und „Nicht erkannt“ prüfen.
3. Titel, Datum, Zusammenfassung, Frist und nächsten Schritt ändern sowie neue Einträge hinzufügen.
4. Detailansicht und App neu öffnen und persistierte Änderungen sowie Kennzeichnung kontrollieren.
