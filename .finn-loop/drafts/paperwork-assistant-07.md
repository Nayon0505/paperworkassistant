## Problem

Der erste produktive Analyseanbieter soll mehrseitige PDFs und Bilder zuverlässig in das gemeinsame, nachvollziehbare Ergebnisschema überführen.

## Acceptance Criteria

- [ ] AC-7.1 — Der OpenAI-Adapter verwendet die Responses API; Modellstandard ist `gpt-5.6` und kann per Umgebungsvariable geändert werden.
- [ ] AC-7.2 — PDFs werden als Dateiinput und Bildseiten in korrekter Reihenfolge als Bildinputs mit hoher Detailstufe gesendet.
- [ ] AC-7.3 — Requests deaktivieren anbieterseitige Speicherung, soweit die API dies unterstützt, und verwenden ein strikt validiertes Structured-Output-Schema.
- [ ] AC-7.4 — Das Ergebnis enthält nullable Titel, Absender und Dokumentdatum, drei bis fünf Zusammenfassungspunkte, Fristen und nächste Schritte.
- [ ] AC-7.5 — Jede Frist enthält Bezeichnung, ISO-Datum, Originaltext, Seite und gegebenenfalls die eindeutige Berechnungsgrundlage einer relativen Frist.
- [ ] AC-7.6 — Jeder nächste Schritt enthält Beschreibung, Originaltext, Seite und optional eine Referenz auf eine erkannte Frist.
- [ ] AC-7.7 — Nicht belegte Werte bleiben leer; relative Fristen werden nur bei eindeutigem Bezugsdatum und eindeutiger Zeitspanne berechnet.
- [ ] AC-7.8 — Zusammenfassung und nächste Schritte folgen der angeforderten App-Sprache; Eigennamen und notwendige Originalbegriffe bleiben unverändert.
- [ ] AC-7.9 — Unlesbare oder sachfremde Eingaben liefern den gültigen Ergebniszustand „Kein verwertbarer Inhalt“ statt erfundener Angaben.
- [ ] AC-7.10 — Refusal, ungültige Ausgabe, Timeout und Anbieterfehler werden in stabile providerneutrale Fehler übersetzt.

## Non-goals

- NG-7.1 — Kein zweiter produktiver Anbieter.
- NG-7.2 — Keine separate lokale oder serverseitige OCR-Pipeline.
- NG-7.3 — Keine automatische Modellwahl oder Anbieter-Fallbacks.
- NG-7.4 — Keine echten OpenAI-Aufrufe in der normalen CI.

## Relevant files

- services/api/src/providers/openai-provider.ts — Responses-API-Integration
- services/api/src/providers/openai-prompt.ts — Ergebnis-, Evidenz- und Sprachvertrag
- packages/contracts/document-analysis.schema.json — Striktes Ergebnisschema
- services/api/test/providers/openai-provider.test.ts — Gemockte Adaptertests
- services/api/test/fixtures — Repräsentative Dokumentfälle und erwartete Ergebnisse
- .env.example — Provider-, Modell- und API-Schlüsselkonfiguration

## Test expectations

- Gemockte Tests für PDF/Bilder, Schema, fehlende Angaben, mehrere und relative Fristen, Sprachwahl, keinen verwertbaren Inhalt sowie alle Fehlerabbildungen; optionaler manueller Smoke-Test mit echtem Schlüssel.

## How to verify

1. Gemockte Testsuite mit deutschem PDF, englischen Bildern, relativer Frist und unlesbarer Eingabe ausführen.
2. Optional mit lokal gesetztem OpenAI-Schlüssel ein freigegebenes Testdokument senden.
3. Antwort gegen das gemeinsame Schema validieren und prüfen, dass keine Dokumentinhalte serverseitig verbleiben.
