# Änderungen

Die deutschen Änderungsnotizen zu cat(a)log, Abschnitt für Abschnitt wie `CHANGELOG.md`; die Versionsbump verschiebt beide nach `OLDER_CHANGES.de.md`. Die Seite "Was ist neu" der Dokumentation wird daraus gebaut.

## [2.4.0]

### Neu
- Die Dokumentation unter <https://paxel.github.io/cat-a-log/>: jeder Bildschirm des Telefons und jede Ansicht des Schreibtischs auf einer eigenen Seite, die Abläufe Schritt für Schritt mit einem Bild pro Schritt, das Glossar, die Dateiformate, jedes Feld, und was zu tun ist, wenn etwas nicht stimmt, auf Englisch und Deutsch. Die Seite beschreibt die veröffentlichte App und wird mit jeder Version aktualisiert.
- Ein Aushang kann abgenommen und ein weiterer aufgehängt werden (#85). "Aushang hängt hier" auf der Seite einer Katze trägt eine Aushang-Position dort ein, wo das Telefon ist, so wie "Hier gesehen" eine Sichtung einträgt; ein langer Druck auf die Karte fragt nach der Katze, ob sie hier gesehen wurde oder ihr Aushang hier hängt. Jeder noch hängende Aushang ist ein quadratischer Pin auf der Karte, nicht nur der neueste; ein langer Druck auf einen Pin bietet "Aushang abgenommen" an, das diese Position wie jede Verlaufszeile entfernt, so dass der Pin verschwindet und der Verlauf die Zeile mit ihrem Pfeil zurück behält. Auf dem Schreibtisch nimmt ein Rechtsklick auf einen Aushang-Pin den Aushang ab, der Rechtsklick auf die Karte bietet den Aushang neben der Sichtung an, und das Aktionsmenü der Katzenseite hat "Aushang hängt hier" mit der auf der Karte gewählten Position; der Schreibtisch zeigt jeden Aushang als Pin, ohne dass das Streunergebiet eingeschaltet ist.

### Behoben
- Der Schreibtisch öffnet dort, wo er verlassen wurde, nicht nur so groß wie er verlassen wurde; ein Fenster, das links oben vom Bildschirm gezogen wurde, wird dort nicht gemerkt.
- Der Schreibtisch hält vor einem Zusammenführen einen Moment fest, wie es das Telefon tut, so dass ein falsches Zusammenführen von der Momentseite aus rückgängig gemacht werden kann.

### Geändert
- Jede Seite auf dem Telefon hat dieselbe obere Leiste: die Knöpfe in einer eigenen Reihe, der Titel darunter. Die Aktionen einer Seite stehen auf der Leiste, solange sie Platz hat, und nur, was nicht passt, kommt ins ⋮-Menü, das verschwindet, wenn nichts darin ist: die Kolonieseite zeigt Verstecken, Zusammenführen und Löschen auf der Leiste, ein quer gehaltenes Telefon oder ein Tablet zeigt das ganze Menü der Katzenseite, und eine Aktion im Menü trägt ihr Symbol neben ihren Worten.

---

Ältere Änderungen stehen in [OLDER_CHANGES.de.md](OLDER_CHANGES.de.md).
