# Glossar auf Deutsch

Die deutschen Einträge zum Glossar in CONTEXT.md, einer je Begriff, mit dem englischen Begriff in Klammern; die Seite "Glossar" wird daraus gebaut, und der Bau schlägt fehl, wenn ein Begriff fehlt.

**Kolonie** [Clowder]:
Eine Gruppe von Katzen, die an einem Ort leben, mit Adresse und einer verantwortlichen Person. Pflegestellen und die Zuhause von Adoptierenden sind beide Kolonien. Im Haustiermodus heißt es auf dem Bildschirm Haushalt; die Sache ist dieselbe.
_Avoid_: Wurf, Zuhause, Vermittlung, Gruppe

**Katze** [Cat]:
Ein einzelnes Tier, das geführt wird, mit Name, Bildern und Feldwerten, die sich mit der Zeit ändern.

**Wurf** [Litter]:
Kitten, die derselben Mutter in einer Geburt geboren wurden. Nicht gespeichert, sondern abgeleitet: dieselbe Mutter und dasselbe Geburtsdatum. Nie eine Wohngruppe.

**Mutter / Vater** [Mother / Father]:
Starterfelder vom Typ Katzenverweis, die eine Katze mit ihren Eltern verbinden. Familienbeziehungen, Wurfgeschwister, Geschwister, Kitten, ergeben sich aus Mutter plus Geburtsdatum; Vater dient nur der Anzeige und dem Hinspringen.

**Streuner** [Stray]:
Eine Katze, die gerade in keiner Kolonie ist; verfolgt über Kartenpositionen statt über eine Adresse. Ein Zustand, keine Art: jede Katze wird Streuner, wenn sie ihre Kolonie verlässt (weggelaufen, Kolonie gelöscht), und hört mit einem Umzug in eine Kolonie auf, einer zu sein.

**Katalog** [Catalog]:
Alles, was eine Arbeit umfasst: ihre Katzen, Kolonien, Felder, Fotos, Abgleich-Partner und Kartenposition. Ein Gerät kann mehrere halten, und nichts wird zwischen ihnen geteilt; zwei Städte bleiben getrennt. Die Einstellungen der App selbst (Autorname, Sprache, gesehene Tipps) teilen sich alle. Ein Katalog ist jeweils offen; sein Name ist der Titel der Startseite.
_Avoid_: Datenbank, Profil, Arbeitsbereich, Konto

**Moment** [Moment]:
Ein Punkt, zu dem ein Katalog zurückkehren kann, festgehalten vor allem, was viel auf einmal ändert, einem Import, einem Abgleich, einem Zusammenführen, einem Archivieren, oder von Hand mit einem Namen markiert. Eine Marke im Protokoll, keine Kopie. Zurückgehen entfernt alles, was danach geschrieben wurde, nachdem es in eine Datei geschrieben wurde.
_Avoid_: Schnappschuss, Speicherpunkt, Wiederherstellungspunkt, Prüfpunkt

**Zuschneiden** [Crop]:
Eine Katze aus einem Foto ausschneiden. Geschieht beim Import (überspringbar; Streunerkamera-Fotos überspringen es, aus einem Video behaltene Bilder bekommen es eines nach dem anderen, aus dem Bild in voller Größe) oder später aus dem Fotomenü; später fügt der Schnitt ein neues Foto hinzu, das Original bleibt.

**Markieren** [Mark]:
Eine Hervorhebung (Ellipse/Pfeil), in eine Kopie eines Fotos gebrannt, um auf eine Katze zu zeigen, wenn Zuschneiden sie nicht trennen kann; ein gewöhnliches neues Foto, abgeglichen und gedruckt wie jedes andere.

**Aushang** [Flier]:
Ein Vermisst-Plakat, das in den Katalog aufgenommen wurde. Die Aufnahme legt eine vermisste Katze samt der Kolonie ihres Besitzers an, und der Ort, an dem es fotografiert wurde, wird eine Aushang-Position an dieser Katze.
_Avoid_: Plakat, Anzeige, Meldung

**Vermisste Katze** [Missing Cat]:
Ein Streuner, der nur von einem Aushang bekannt ist; noch keine Sichtung. Seine Historie hält fest, dass er die Kolonie des Besitzers am Vermisst-seit-Datum verließ; er hört auf dem gewöhnlichen Weg auf, vermisst zu sein, durch einen Umzug oder ein Zusammenführen mit einer gesichteten Katze.
_Avoid_: Vermisstendatensatz, Aushangkatze

**Aushang-Position** [Flier Position]:
Der Ort, an dem ein Aushang fotografiert wurde: wo das Plakat hängt, nicht wo die Katze gesehen wurde. Nie als Sichtungs-Pin gezeigt; sie verankert nur das mögliche Streunergebiet.

**Aushang-Vorlage** [Flier Template]:
Wie ein Register seine Plakate aufbaut: welche gedruckten Beschriftungen für welches Feld stehen, wie die Namenszeile aussieht, welche Zeilen der eigene Kontakt des Registers sind. Als Daten mitgeliefert (`assets/fliers/templates.json`); die am besten passende Vorlage liest einen Aushang, ein unbekanntes Layout überlässt jede Zeile dem Benutzer.
_Avoid_: Parser, OCR-Regeln, fest verdrahtetes TASSO

**Termin** [Appointment]:
Ein Besuch mit Datum, optionaler Uhrzeit, Was und Notizen an einer Katze oder Kolonie; sein Abschluss kann einen Wert in ein Feld schreiben. Als gewöhnlicher Eintrag gespeichert, also abgeglichen und zusammengeführt wie jeder Wert.
_Avoid_: Ereignis, Buchung

**Tierarztfahrt** [Vet Run]:
Ein Termin, den mehrere Katzen teilen: jede Katze behält ihren eigenen Termineintrag, eine Gruppenkennung faltet sie in eine Agenda-Karte und einen Kalendereintrag, Bearbeiten bewegt alle, Abschließen fragt, welche Katzen behandelt wurden. Eine Katze verlässt eine Tierarztfahrt, indem ihr eigener Termin gelöscht wird.
_Avoid_: Gruppentermin, Sammelbesuch, Mehrkatzen-Ereignis

**Haustiermodus** [Pet Mode]:
Die Wahl eines Katalogs, Tiere statt Katzen zu halten: ein gewöhnlicher abgeglichener Eintrag, damit jedes Gerät ihn gleich zeigt. Er ändert Wörter (Tier, Haushalt), das Platzhalterbild (eine Pfote) und die vorgeschlagenen Namen; nie die Daten. Ältere Versionen ignorieren ihn.
_Avoid_: neutraler Modus, Tiermodus

**Messwert** [Unit Value]:
Ein Feldwert, der etwas misst: eine Zahl, in der Basiseinheit der App gespeichert (Gramm, Zentimeter, Milliliter, °C) und in der Einheit gezeigt und eingegeben, die das Gerät bevorzugt (metrisch oder imperial, aus der Region oder gewählt). Das Gewicht ist der Starter.
_Avoid_: Messung, Metrik

**Dimension** [Dimension]:
Was ein Messwert misst: Gewicht, Länge, Volumen oder Temperatur. Beim Anlegen des Feldes gewählt; sie legt die Basiseinheit fest.

**Mögliches Streunergebiet** [Possible Stray Area]:
Eine zuschaltbare Kartenebene für eine vermisste Katze: die Vereinigung der 500-m-Kreise um ihre Aushang-Positionen, die markiert, wo die Katze vermutlich umherstreift (drei Viertel der verlorenen Katzen werden innerhalb von 500 m gefunden).
_Avoid_: Suchradius, Revier

**Streunerkamera** [Stray Cam]:
Die Aufnahme eines neuen Streuners mit einem Tipp: legt die Katze an der aktuellen Position des Geräts mit einem Foto an (Systemkamera oder vom Gerät gewählt), ohne weitere Eingabe.

**Zusammenführen** [Merge]:
Zwei Datensätze desselben realen Dings vereinen: Katze, Kolonie oder Feld. Der Benutzer wählt den Überlebenden; die aktuellen Werte des Überlebenden gewinnen, außer wo die Katze lebt, was der neueste Umzug eines der beiden nach seinem eigenen Datum entscheidet, die Historie des anderen Datensatzes kommt in die Zeitleiste des Überlebenden, der andere Datensatz hört auf zu existieren. Unumkehrbar.

**Karte** [Card]:
Die Darstellung einer Katze: als Detailbildschirm in der App, und als teilbarer, druckbarer Export (Bild oder PDF) mit Foto und aktuellen Feldwerten.

**Profilbild** [Profile Image]:
Das eine Bild einer Katze, das in Listen und auf ihrer Karte gezeigt wird; wählbar, standardmäßig das erste Bild.

**Feld** [Field]:
Eine typisierte, benutzerdefinierte Eigenschaft (Text, Ja/Nein, Datum, Zahl, Auswahl, Ort, ID), die an Katzen und Kolonien hängt. Definitionen gelten im ganzen Katalog; Werte tragen ein Datum und einen Autor, und jede Änderung bleibt als Historie erhalten.
_Avoid_: Eigenschaft, Spalte, Tag

**ID-Feld** [ID Field]:
Ein Feldtyp für eine externe Kennung, von Hand eingegeben oder per Kamera gescannt und auf der Karte in einem beim Anlegen gewählten Format gezeigt (Text, QR oder Strichcode). ID-Werte passen zu anderen Datensätzen genau oder gar nicht; nie unscharf.
_Avoid_: Code, Referenznummer

**Chip-Nummer** [Chip ID]:
Ein Starter-ID-Feld an Katzen für die 15-stellige Transpondernummer. Der wichtigste exakte Schlüssel zwischen einer vermissten und einer gefundenen Katze.
_Avoid_: Mikrochipnummer, Transponder

**Bemerkungen** [Remarks]:
Ein mehrzeiliges Starter-Textfeld an Katzen und Kolonien für freie Notizen; auch für Text, der von einem Aushang gelesen wurde.
_Avoid_: Notizen, Kommentare, Beschreibung

**Umzug** [Move]:
Eine Änderung der Kolonie-Zugehörigkeit einer Katze, festgehalten als datierte Feldänderung wie jede andere. Die Umzugshistorie einer Katze ist die Historie dieses Feldes. Immer innerhalb eines Katalogs.

**Verschieben** [Transfer]:
Eine Katze, oder eine Kolonie mit den Katzen, die in ihr leben, aus einem Katalog in einen anderen bringen. Kein Umzug: es überschreitet Kataloge und stempelt die Einträge unter dem Gerät des Ziels neu, damit sich die zwei Kataloge über einen gemeinsamen Partner nie wieder zusammenführen. Die Oberfläche sagt "in einen anderen Katalog verschieben", weil ein Betreuer das sieht; das Modell nennt es Transfer.

**Adoption** [Adoption]:
Ein Umzug in eine Kolonie, deren Status Für-immer-Zuhause ist. Kein gespeicherter Status an der Katze; es gibt keine "adoptiert"-Markierung.
_Avoid_: Adoptionszustand, Adoptionsdatensatz

**Autor** [Author]:
Der selbstgewählte Name, den ein Gerät trägt; jede Änderung wird einem Autor zugeschrieben. Es gibt keine Konten und keine Anmeldung.

**Status** [Status]:
Ein Kolonie-Feld mit vorgeschlagenen Werten (Pflegestelle, Für-immer-Zuhause, Praxis/Tierarzt, Tierheim, Hof, Besitzer), die die App für Anzeige und Verhalten erkennt (z. B. Adoption). Freier Text darüber hinaus ist erlaubt und bleibt ein gewöhnlicher Wert.
_Avoid_: Kolonie-Art, Kategorie

**Privat** [Private]:
Ein Häkchen an einem Wert, gesetzt im Feldeditor: dieser Wert bleibt im lokalen Katalog, es sei denn, ein Teilen schickt ihn mit dem Schalter "Private Daten teilen"; der Schalter bedeutet in jedem Transport dasselbe. Privat geht es um Doxing, nicht darum, zu verbergen, dass eine Katze oder Kolonie existiert: Kennung, Art, Name und Kolonie-Zugehörigkeit reisen immer, damit nichts, was ein Partner bekommt, auf etwas zeigt, von dem er nie gehört hat. Ein zurückgehaltener Wert hinterlässt eine Spur (als Schloss auf einer leeren Zeile gezeigt), und der Wert selbst kommt später, wenn je ein Teilen mit privaten Werten ihn trägt. Es gibt kein Privat an ganzen Katzen oder Kolonien; eine Felddefinition privat zu markieren markiert das Feld an jedem Ding. Keine Hinweisfenster erklären das; das Schloss und der Schalter sind die ganze Oberfläche. Vertrauen entscheidet der Mensch je Begegnung, nicht das System.
_Avoid_: versteckt (das ist nur Anzeige), geheim

**Versteckt** [Hidden]:
Ein Anzeigefilter je Gerät an einem Ding oder einer Felddefinition. Verstecktes wird unverändert empfangen, gespeichert und weitergegeben; es wird nur nicht gezeigt. Ein Schalter "Verstecktes zeigen" holt es hervor. Verlässt nie das Gerät.
_Avoid_: blockiert, privat (das ist die Übertragung)

**Verstorben** [Deceased]:
Eine Katze, deren Verstorben-Datum gesetzt ist. Gedämpft dargestellt (abgedunkeltes Foto, übersetzter Chip "Verstorben", keine religiösen Symbole) und in der Importzusammenfassung aufgeführt.

**Tierart** [Species]:
Ein Starterfeld an Katzen, Vorgabe "Katze": eine Auswahl mit Vorgaben (Katze, Hund, Kaninchen, Meerschweinchen, Hamster, Vogel, Pferd, Schildkröte, Frettchen) plus ein eigenes Wort. Kanonisch gespeichert, übersetzt gezeigt. Die Rassen folgen der Tierart; das Ding bleibt in den Daten eine Katze, welche Tierart auch immer. Welche Wörter die App dafür benutzt, entscheidet der Haustiermodus, nicht die Tierart.

**Sperre** [Ban]:
Eine lokale Liste je Gerät von Autoren/Geräten und Foto-Prüfsummen, deren Material beim Empfang verworfen wird (empfangen und weggeworfen; die Abgleich-Buchführung läuft weiter). Verbreitet sich nie auf andere Geräte. Je Eintrag umkehrbar.
_Avoid_: blockieren (im Sinn eines Importfilters), melden

**Endgültiges Löschen** [Hard Delete]:
Das physische Entfernen aller Einträge und Fotos eines Autors/Geräts aus dem lokalen Speicher; die einzige Ausnahme von der Historie, die sonst nur wächst, für böswillige oder illegale Inhalte. Meist mit einer Sperre verbunden, damit das Material nicht zurückkommt.
