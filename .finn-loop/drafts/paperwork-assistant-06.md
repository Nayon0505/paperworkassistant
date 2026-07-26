## Problem

Die App benötigt einen geschützten Backend-Vertrag, der Dokumente ohne dauerhafte Serverablage an austauschbare Analyseanbieter weitergibt.

## Acceptance Criteria

- [ ] AC-6.1 — `POST /v1/analyses` ist als synchroner, versionierter Multipart-Endpunkt in OpenAPI dokumentiert.
- [ ] AC-6.2 — Der Request enthält genau ein Dokument, gewünschte Ausgabesprache und Metadaten zur Seitenreihenfolge; die Antwort folgt dem gemeinsamen Analyseschema.
- [ ] AC-6.3 — Eine Anbieter-Schnittstelle kapselt Analyseaufrufe; der aktive Anbieter wird ausschließlich serverseitig per Umgebungsvariable gewählt.
- [ ] AC-6.4 — Ein Fake-Anbieter ermöglicht deterministische Vertrags- und Integrationstests ohne externe API.
- [ ] AC-6.5 — Eine anonyme Installationskennung erhält ein kurzlebiges Zugriffstoken; Analysezugriffe werden standardmäßig auf 30 pro Stunde und Installation sowie 60 pro Stunde und IP begrenzt.
- [ ] AC-6.6 — Fehlende oder ungültige Tokens, Ratenüberschreitungen, MIME-Typen, Größen und Seitenzahlen erzeugen dokumentierte 4xx-Antworten.
- [ ] AC-6.7 — Backend und Logs speichern keine Dokumentinhalte oder Analyseergebnisse dauerhaft; temporäre Daten werden auch bei Fehler und Verbindungsabbruch entfernt.
- [ ] AC-6.8 — Docker-Start, Healthcheck und API-Vertrag sind dokumentiert und getestet.

## Non-goals

- NG-6.1 — Keine Benutzerkonten oder Cloud-Dokumentbibliothek.
- NG-6.2 — Noch kein produktiver KI-Anbieter.
- NG-6.3 — Keine asynchronen Serverjobs, Warteschlangen oder WebSockets.
- NG-6.4 — Kein automatischer Anbieter-Fallback.

## Relevant files

- services/api/src/routes/analyses.ts — Synchroner Analyse-Endpunkt
- services/api/src/routes/installations.ts — Anonyme Tokenausgabe
- services/api/src/providers/analysis-provider.ts — Anbieter-Schnittstelle
- services/api/src/providers/fake-provider.ts — Deterministischer Testanbieter
- services/api/src/security — Tokenprüfung, Validierung und Rate-Limits
- packages/contracts/openapi.yaml — Versionierter HTTP-Vertrag
- packages/contracts/document-analysis.schema.json — Anbieterneutrales Ergebnisschema

## Test expectations

- API-Vertragstests für Erfolg, Authentifizierung, Rate-Limits, alle Eingabegrenzen, Anbieterfehler, Abbruch und garantiertes Aufräumen temporärer Daten.

## How to verify

1. API mit Fake-Anbieter starten, anonymes Token beziehen und ein Test-PDF erfolgreich analysieren.
2. Ungültiges Token, zu große Datei und überschrittenes Test-Rate-Limit senden und die definierten Fehler prüfen.
3. Request abbrechen und bestätigen, dass keine temporären Inhalte oder Inhaltslogs verbleiben.
