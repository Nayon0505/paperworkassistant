## Problem

Importierte Dokumente müssen nach Einwilligung automatisch analysiert werden, ohne dass Batch-Fehler, Offlinezustände oder App-Abbrüche zu Datenverlust führen.

## Acceptance Criteria

- [ ] AC-8.1 — Vor der ersten externen Analyse erklärt ein lokalisierter Dialog die externe Verarbeitung; nur aktive Zustimmung startet den Upload.
- [ ] AC-8.2 — Ablehnung erhält Dokumente als „Analyse ausstehend“; erneuter manueller Start fragt erneut nach Zustimmung.
- [ ] AC-8.3 — Nach erteilter Zustimmung startet jeder neue Online-Import automatisch und verarbeitet Batch-Dokumente streng nacheinander.
- [ ] AC-8.4 — Jedes Dokument besitzt einen unabhängigen Status; ein Fehler stoppt nicht die folgenden Dokumente.
- [ ] AC-8.5 — Offline importierte, fehlgeschlagene oder unterbrochene Dokumente bleiben gespeichert und können einzeln manuell erneut gestartet werden.
- [ ] AC-8.6 — Beim App-Start wird ein zuvor „Wird analysiert“-Dokument auf „Analyse ausstehend“ zurückgesetzt und nicht automatisch erneut gesendet.
- [ ] AC-8.7 — Löschen eines wartenden oder aktiven Dokuments bricht den Auftrag ab; verspätete Antworten werden anhand der Dokument-/Request-ID ignoriert.
- [ ] AC-8.8 — Erfolgreiche Ergebnisse werden atomar lokal gespeichert; „Kein verwertbarer Inhalt“ bleibt ein eigener abgeschlossener Status mit Neuversuchsaktion.
- [ ] AC-8.9 — Der Client erneuert kurzlebige Installationstokens transparent und zeigt stabile lokalisierte Netzwerk-, Rate-Limit- und Anbieterfehler.

## Non-goals

- NG-8.1 — Keine Hintergrundanalyse nach Schließen der App.
- NG-8.2 — Keine automatische Wiederholung bei wiederhergestellter Verbindung.
- NG-8.3 — Keine parallelen Analysen.
- NG-8.4 — Keine Cloudspeicherung von Dokumenten oder Ergebnissen.

## Relevant files

- apps/mobile/lib/features/analysis/consent — Einwilligungsdialog und lokaler Zustand
- apps/mobile/lib/features/analysis/analysis_queue.dart — Sequenzielle Warteschlange
- apps/mobile/lib/features/analysis/analysis_client.dart — API- und Tokenclient
- apps/mobile/lib/features/analysis/analysis_recovery.dart — Neustart- und Abbruchlogik
- apps/mobile/test/features/analysis — Queue-, Fehler- und Wiederherstellungstests

## Test expectations

- Tests für Zustimmung/Ablehnung, automatischen Start, Batch-Reihenfolge, Teilfehler, Offlinezustand, manuellen Retry, Neustart, Löschen während Analyse und verspätete Antworten.

## How to verify

1. Ersten Import durchführen, Zustimmung ablehnen und unverändertes Dokument prüfen.
2. Analyse manuell starten, zustimmen und einen Batch aus drei Dokumenten sequenziell verarbeiten.
3. Beim zweiten Dokument einen Fehler simulieren und prüfen, dass das dritte fortgesetzt wird.
4. App während einer Analyse schließen, neu starten und den manuellen Neuversuch prüfen.
5. Aktives Dokument löschen und eine simulierte verspätete Antwort zustellen; das Dokument darf nicht wieder erscheinen.
