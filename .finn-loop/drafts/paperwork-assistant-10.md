## Problem

Erkannte und manuell gepflegte Fristen sollen zuverlässig lokale Erinnerungen erzeugen, ohne Dokumentfunktionen von der Benachrichtigungsberechtigung abhängig zu machen.

## Acceptance Criteria

- [ ] AC-10.1 — Für jede zukünftige Frist werden automatisch Erinnerungen sieben Tage und einen Tag vorher jeweils um 09:00 Uhr lokaler Zeit geplant.
- [ ] AC-10.2 — Nur tatsächlich zukünftige Erinnerungszeitpunkte werden geplant; Fristen ohne verbleibenden Zeitpunkt erscheinen als „Heute“ oder „Überfällig“, lösen aber keine sofortige Benachrichtigung aus.
- [ ] AC-10.3 — Die Benachrichtigungsberechtigung wird erstmals angefragt, wenn die erste zukünftige Erinnerung angelegt werden soll, nicht beim App-Start oder Import.
- [ ] AC-10.4 — Bei verweigerter Berechtigung bleiben Import und Analyse voll funktionsfähig; die Detailansicht zeigt deaktivierte Erinnerungen und einen Link zu den Systemeinstellungen.
- [ ] AC-10.5 — Mehrere Fristen eines Dokuments besitzen getrennte Erinnerungen mit Fristbezeichnung und Dokumenttitel.
- [ ] AC-10.6 — Änderungen am Fristdatum stornieren alte und planen neue Erinnerungen; Löschen einer Frist oder eines Dokuments entfernt alle zugehörigen Erinnerungen.
- [ ] AC-10.7 — Beim Wechsel der Gerätezeitzone werden geplante Erinnerungen beim nächsten App-Start auf 09:00 Uhr der neuen lokalen Zeitzone angepasst.
- [ ] AC-10.8 — Neustarts der App oder des Geräts erzeugen keine doppelten Erinnerungen.

## Non-goals

- NG-10.1 — Keine frei konfigurierbaren Erinnerungsabstände oder Uhrzeiten.
- NG-10.2 — Keine E-Mail-, SMS- oder Cloudbenachrichtigungen.
- NG-10.3 — Kein Kalenderexport.
- NG-10.4 — Keine biometrische oder PIN-basierte App-Sperre.

## Relevant files

- apps/mobile/lib/features/reminders/reminder_scheduler.dart — Idempotente Planung
- apps/mobile/lib/features/reminders/notification_permissions.dart — Berechtigungsablauf
- apps/mobile/lib/features/reminders/deadline_sync.dart — Änderungen und Kaskadenlöschung
- apps/mobile/lib/features/document_detail — Status und Systemeinstellungsaktion
- apps/mobile/test/features/reminders — Zeit-, Berechtigungs- und Synchronisierungstests

## Test expectations

- Tests mit kontrollierter Uhr und Zeitzone für 7-/1-Tages-Zeitpunkte, kurze/vergangene Fristen, mehrere Fristen, verweigerte Berechtigung, Bearbeitung, Löschung, Neustart und Zeitzonenwechsel.

## How to verify

1. Zukünftige Frist anlegen und beide geplanten lokalen Benachrichtigungen auf 09:00 Uhr prüfen.
2. Berechtigung verweigern und weiterhin funktionierenden Import sowie Einstellungsaktion kontrollieren.
3. Fristdatum ändern und prüfen, dass alte Planungen verschwinden und neue entstehen.
4. Frist und anschließend Dokument löschen und alle zugehörigen Planungen kontrollieren.
5. Zeitzone wechseln, App neu starten und idempotente Neuberechnung prüfen.
