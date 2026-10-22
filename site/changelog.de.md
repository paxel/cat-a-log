# Änderungen auf Deutsch

Die deutschen Änderungsnotizen zu cat(a)log, Abschnitt für Abschnitt wie `CHANGELOG.md` und `OLDER_CHANGES.md` im Wurzelverzeichnis, in einer Datei: die aktuelle Version oben ohne Datum, die veröffentlichten darunter mit dem Datum ihres Tags, ab 2.0.0. Die Seite "Was ist neu" der Dokumentation wird daraus gebaut; eine englische Version ohne deutschen Abschnitt lässt den Bau fehlschlagen. Versionen vor 2.0.0 gibt es nur auf Englisch.

## [2.5.0]

### Neu
- Spielen, in den Aktionen von Home vor den Einstellungen, hat zwei Spielzeuge für die Katze: einen Laserpunkt, der losschießt und wartet, und eine Maus, die an den Rändern entlangflitzt und wieder hereinschaut (#172). Sie laufen im Vollbild, der Bildschirm bleibt an und es gibt kein Zeitlimit; sie werden schneller, wenn sie gefangen werden, und langsamer, wenn niemand sie jagt, und quieken, zirpen und trippeln, solange "Spielzeug-Geräusche" an ist. Zurück tut nichts, solange ein Spielzeug läuft; das Gerät hochzuheben beendet es, ebenso drei Sekunden auf dem Schloss in der Ecke, und Spielen zeigt danach, wie viele Fänge das Spiel hatte und wie lange es lief.
- Über auf dem Telefon und auf dem Schreibtisch verlinkt die Dokumentation, auf Deutsch, wenn die App auf Deutsch ist, sonst auf Englisch.

### Behoben
- Die Installation des Schreibtischs über Homebrew unter Linux warnt nicht mehr, dass `post_install` veraltet ist.

## [2.4.1] - 2026-10-20

### Neu
- Die Dokumentation unter <https://paxel.github.io/cat-a-log/>: jeder Bildschirm des Telefons und jede Ansicht des Schreibtischs auf einer eigenen Seite, die Abläufe Schritt für Schritt mit einem Bild pro Schritt, das Glossar, die Dateiformate, jedes Feld, und was zu tun ist, wenn etwas nicht stimmt, auf Englisch und Deutsch. Die Seite beschreibt die veröffentlichte App, wird mit jeder Version aktualisiert und behält jede frühere Version unter dem Versionsmenü in ihrer Kopfzeile.

## [2.4.0] - 2026-10-20

### Neu
- Ein Aushang kann abgenommen und ein weiterer aufgehängt werden (#85). "Aushang hängt hier" auf der Seite einer Katze trägt eine Aushang-Position dort ein, wo das Telefon ist, so wie "Hier gesehen" eine Sichtung einträgt; ein langer Druck auf die Karte fragt nach der Katze, ob sie hier gesehen wurde oder ihr Aushang hier hängt. Jeder noch hängende Aushang ist ein quadratischer Pin auf der Karte, nicht nur der neueste; ein langer Druck auf einen Pin bietet "Aushang abgenommen" an, das diese Position wie jede Verlaufszeile entfernt, so dass der Pin verschwindet und der Verlauf die Zeile mit ihrem Pfeil zurück behält. Auf dem Schreibtisch nimmt ein Rechtsklick auf einen Aushang-Pin den Aushang ab, der Rechtsklick auf die Karte bietet den Aushang neben der Sichtung an, und das Aktionsmenü der Katzenseite hat "Aushang hängt hier" mit der auf der Karte gewählten Position; der Schreibtisch zeigt jeden Aushang als Pin, ohne dass das Streunergebiet eingeschaltet ist.

### Behoben
- Der Schreibtisch öffnet dort, wo er verlassen wurde, nicht nur so groß wie er verlassen wurde; ein Fenster, das links oben vom Bildschirm gezogen wurde, wird dort nicht gemerkt.
- Der Schreibtisch hält vor einem Zusammenführen einen Moment fest, wie es das Telefon tut, so dass ein falsches Zusammenführen von der Momentseite aus rückgängig gemacht werden kann.

### Geändert
- Jede Seite auf dem Telefon hat dieselbe obere Leiste: die Knöpfe in einer eigenen Reihe, der Titel darunter. Die Aktionen einer Seite stehen auf der Leiste, solange sie Platz hat, und nur, was nicht passt, kommt ins ⋮-Menü, das verschwindet, wenn nichts darin ist: die Kolonieseite zeigt Verstecken, Zusammenführen und Löschen auf der Leiste, ein quer gehaltenes Telefon oder ein Tablet zeigt das ganze Menü der Katzenseite, und eine Aktion im Menü trägt ihr Symbol neben ihren Worten.

## [2.3.0] - 2026-10-05

### Neu
- Eine Aufgabe kann einmalig sein: "Einmalig" ist eine vierte Wahl neben täglich, alle… und Wochentage, mit optionaler Fälligkeit. Sie bietet Duplizieren und Beenden, kein Pausieren. Eine ältere App zeigt eine einmalige Aufgabe nur an ihrem Fälligkeitstag und lässt sie, wie sie ist.
- Eine einmalige Aufgabe steht vom Tag ihres Anlegens an unter den Aufgaben von heute, bis sie erledigt ist, nie unter Demnächst. Fällig oder überfällig rückt sie nach oben, rot, wenn überfällig; bis dahin wartet sie unten nach ihrer Fälligkeit und sagt ab drei Tagen davor in Orange "Fällig in 2 Tagen". Erledigt bleibt sie den Tag über durchgestrichen stehen und ist am nächsten weg. Sie hat keine Serie und keine Wochenpunkte, und eine, die noch wartet, hindert den Tag nicht daran, ganz erledigt zu sein.
- Eine einmalige Aufgabe mit eingeschalteter Erinnerung erinnert einmal, an ihrem Fälligkeitstag zu ihrer Zeit; ohne Fälligkeit erinnert sie nicht.
- Der Schreibtisch hat auch einmalige Aufgaben: eine vierte Option in seinem Aufgaben-Editor mit optionaler Fälligkeit, die Reihenfolge von heute auf der Agenda, dem Home und der Katzenseite, rot bei Überfälligkeit und orange bei Fälligkeit binnen drei Tagen, kein Pausieren und keine Wochenpunkte, und die Fälligkeit in seinem Kalender.

### Geändert
- Aus einem Video behaltene Bilder, für eine Katze oder einen neuen Streuner, bieten eines nach dem anderen den Zuschneide-Schritt an, bevor sie gespeichert werden, aus dem Bild in der vollen Größe des Videos geschnitten. Eine aus einem 4K-Video ausgeschnittene Katze behält weit mehr Details, als wenn sie später aus dem gespeicherten Foto geschnitten wird. "Ganzes Foto behalten" behält ein Bild ganz; Abbrechen lässt nur dieses Bild fallen.
- Nennt ein Aushang kein Weglauf-Datum, sagt seine Kachel "Vermisst seit" mit einem Warnzeichen "Nicht auf dem Aushang gefunden — heute", damit ein geratener Tag nicht mehr wie ein gelesener aussieht. Auf Telefon und Schreibtisch.
- Ein Umzug im Verlauf einer Katze, umgezogen, weggelaufen, vermittelt, öffnet mit einem Tipp den Umzugsdialog, auf das Zuhause und den Tag dieses Umzugs eingestellt, und korrigiert wohin und wann. Der Verlauf eines Zuhauses tut dasselbe für Ankunft oder Abgang einer Katze. Zuvor ließ sich ein Umzug nur entfernen.
- Ein Termin oder eine Aufgabe in einem Verlauf öffnet mit einem Tipp seinen eigenen Editor, und der Erledigt-Tag einer Aufgabe öffnet das Protokoll dieser Aufgabe. Zuvor ließen sich diese Zeilen dort nur entfernen.
- Auf dem Schreibtisch öffnet die Zeitleiste einer Katze mit einem Klick auf einen Umzug den Umzugsdialog und korrigiert wohin und wann; die Zeitleiste eines Zuhauses listet jetzt Ankünfte und Abgänge seiner Katzen, die sich genauso korrigieren lassen. Termine und Aufgaben öffnen von dort ihre Editoren, der Erledigt-Tag einer Aufgabe sein Protokoll.
- Eine Wahl unter mehreren Optionen ist eine Liste von Optionsknöpfen, einer pro Zeile, statt einer Reihe von Pillen: wie oft eine Aufgabe wiederkommt, wie lange das Archiv wartet, und der Bereich des Diagramms auf Telefon und Schreibtisch; Geglättet und Trend des Telefondiagramms sind Kästchen.

### Behoben
- Ein handgemachter Aushang findet sein Weglauf-Datum: eine Zeile mit "weggelaufen am", "entlaufen", "vermisst seit", "verschwunden seit", "missing since" oder "lost on" liefert das Datum auf ihr oder auf der Zeile direkt danach. Zuvor wurde nur das TASSO-Plakatlayout gelesen, und die Katze eines handgemachten Aushangs ging heute verloren. Auf Telefon und Schreibtisch.
- Ein Aushang, der zu einer Katze hinzugefügt wird, die du schon hast, mit gewähltem Zuhause, datiert den Umzug der Katze nach Hause und ihr Weglaufen auf den Tag des Aushangs und zeigt die Kachel "Vermisst seit" zur Kontrolle. Zuvor wurden beide Umzüge auf den Tag datiert, an dem der Aushang hinzugefügt wurde.
- Zwei Katzen zusammenzuführen bringt die zusammengeführte Katze nicht mehr nach Hause zurück. Der neueste Umzug einer der beiden Katzen, nach seinem eigenen Datum, entscheidet, wo sie ist, so dass der Streuner eines Aushangs seinen Weglauf-Tag behält, wenn er in die Katze im Katalog zusammengeführt wird. Auf Telefon und Schreibtisch.
- Eine geplante Erinnerung in einem Verlauf zu korrigieren lässt sie eine Erinnerung bleiben; zuvor wurde der korrigierte Plan ein gewöhnlicher Wert. Auf Telefon und Schreibtisch.
- Ein Aushang liest mehr von den Arten, wie Menschen ein Datum von Hand schreiben: 03-10-2025, 03.10.25, "3. Oktober 2025", "Oct 3, 2025", und 3.10. ohne Jahr, das als der letzte solche Tag zählt, der schon vorbei ist. Auf Telefon und Schreibtisch.

## [2.2.0] - 2026-10-01

### Geändert
- Das F-Droid-Repository heißt jetzt "paxel's apps" und trägt auch chaos-alert; die Adresse bleibt dieselbe.

### Behoben
- Das Aussehen bietet jeder Tierart nur, was sie hat, auf Telefon und Schreibtisch. Die Merkmale eines Vogels sind ein fehlendes Bein oder fehlende Zehen, ein verletzter oder gestutzter Flügel und seine Augen; keine Ohren, Vorderbeine oder Zähne. Eine Schildkröte bekommt Panzerfarben und einen beschädigten Panzer statt Fellfarben, Zeichnungen und Zähne. Pferde und Frettchen bekommen Fell, Schwanz und Ohren wie die anderen Felltiere. Ein Tier unbekannter Art kann aus jedem Merkmal wählen.
- Einen Streuner aus einem Video anzulegen wählt eine Videodatei, genau wie Fotos aus einem Video zu einer Katze, statt die Kamera zu öffnen.
- Die Streuner-Hilfe sagt nicht mehr, die Streunerkamera gedrückt zu halten, um ein Video zu filmen; sie zeigt stattdessen auf "Aus Video…".

## [2.1.0] - 2026-09-30

### Neu
- Alles auf einem Fleck der Karte teilt sich einen Pin, auf dem Telefon und auf dem Schreibtisch: zwei Zuhause an einer Adresse, eine Katze an der Tür eines Zuhauses gesehen, der Ort eines Plakats. Der Pin trägt das Titelbild des Zuhauses, oder das frischeste Gesicht, mit "+2" für den Rest, und öffnet die Liste dessen, was dort ist; ein Tipp auf eine Zeile öffnet sie, das Kartensymbol an der Zeile legt ihre Spur auf die Karte. Katzen teilten sich schon einen Pin; Zuhause, Aushänge und eigene Ortsfelder kommen jetzt dazu.

### Behoben
- Das Einheitensystem in den Einstellungen ist drei Zeilen mit je einer Option; die einzeilige Pille quetschte ihre Beschriftungen auf einem Telefon zu einem hohen Klumpen.

## [2.0.7] - 2026-09-28

### Geändert
- Die Karte, die ein Betreuer teilt, sagt neben dem Geburtsdatum, wie alt die Katze ist, und bei einer verstorbenen Katze das erreichte Alter, mit dem Kreuz markiert; dasselbe wie auf der eigenen Seite der Katze, auf Telefon und Schreibtisch.
- Das Alter des Tierarztberichts zählt bis zum Todestag einer Katze statt bis heute und trägt das Kreuz. Ebenso die Altersspalte der Katzentabelle des Schreibtischs.

### Behoben
- "In einen anderen Katalog verschieben" auf markierten Zeilen verschiebt die markierten Zeilen. Zuvor bot es stattdessen ganze Zuhause und Streuner an, so dass fünf Katzen aus einem Zuhause zu verschieben hieß, das Zuhause zu verschieben. Eine Katze, deren Zuhause zurückbleibt, kommt als Streuner an statt in einem Zuhause, das nicht da ist.
- Ein Telefon, das abgleicht, aber eine Woche lang nichts aufzeichnet, gilt nicht mehr als verschwundene Installation: seine Warnung bleibt, und die Gesamthistorie-Datei, die es liest, wird behalten statt endgültig abgeschnitten. Nur eine Datei, in die eine Woche lang niemand geschrieben hat, zählt als verschwunden, und ein Ordner, der nicht sagen kann, wann eine Datei geschrieben wurde, ein gemeinsamer Android-Ordner, behält alle.
- Die schon eingetragene Mutter oder der Vater bleibt auf der Liste der Auswahl, auch nachdem das Geschlecht dieser Katze korrigiert wurde, so dass die Beziehung geändert statt nur aufgehoben werden kann.
- Eine Katze zu öffnen, während der Schreibtisch nur Zuhause zeigt, legt die Karte auf den Schreibtisch und lässt den Filter los, statt den Klick zu schlucken, bis der Filter gefunden und ausgeschaltet ist. Ein Gesicht im Dock holt seine Karte genauso zurück, und Nebeneinander ordnet die sichtbaren Karten und lässt die versteckten liegen, wo sie sind.
- Eine pausierte Aufgabe ist vom Kalender der Agenda verschwunden; das Monatsraster druckte sie an jedem Tag, während die Liste sie unter Pausiert führte.
- Eine Notiz, die auf einen Fehler folgt, wird wieder als Neuigkeit gezeichnet und verblasst von selbst; spätere Notizen erbten den roten Grund und den Schließen-Knopf des Fehlers davor. Ein eigener Fehler, ein Foto, das nicht gelesen werden konnte, ein Katalog, dessen Andenken-Datei nicht geschrieben werden konnte, ein Archiv oder eine Kalenderdatei, die scheiterten, wartet jetzt auf das × statt nach sechs Sekunden zu verblassen.
- Der Ton eines Moments, der Konfetti-Schalter und die Stimme der Erinnerung gehören dem Gerät: sie sind in jedem Katalog auf Telefon und Schreibtisch dieselben, und ein in einem Katalog gewählter eigener Ton ersetzt nicht mehr hinter dem Rücken die Datei eines anderen. Eine vor dieser Version getroffene Wahl wird dort gelesen, wo sie getroffen wurde.
- Den Katzenton der Aufgaben-Erinnerung auszuschalten wird nicht mehr dadurch aufgehoben, dass eine Aufgabe in einem anderen Katalog abgehakt wird.
- Die Vorschau des Tierarztberichts auf dem Schreibtisch spricht die Einheiten der App und zählt vom Tag der App, so dass sie sagt, was der geschriebene Bericht sagt.
- "Diagramm als Bild kopieren" wird nur angeboten, wenn der gewählte Bereich tatsächlich ein Diagramm zeichnet; zuvor ließ es sich anklicken und tat nichts.
- Die Jahrespfeile in der Monatswahl der Agenda führen dorthin zurück, wo sie herkamen: ein Jahr zurück vom 31. März ist der 31. März, nicht der 28. Februar.
- Ein Ort nahe dem Rand einer Kartenkachel wird auf der Karte unverzerrt gezeichnet, mit dem Pin auf dem Ort selbst statt immer in der Mitte.
- Einen Erfolg zu löschen nimmt ihn von der Liste: er wird auf der gezeigten Stufe abgewinkt, so dass eine Leiter, die durch einen Abgleich stieg, nicht gleich zurückkommt, und eine, die nie festgehalten wurde, geht auch.
- Einen leeren Katalog zu löschen sagt, dass es nichts zu sichern gab, statt eine Andenken-Datei zu nennen, die nie geschrieben wurde.
- Gewählte Videobilder zu speichern hängt nicht mehr an einem Drehkreis, wenn ein Bild in voller Größe nicht gelesen werden kann; das gewählte Bild wird stattdessen behalten. Ein Bild, das sich nicht greifen lässt, lässt "Dieses Bild behalten" funktionieren, statt für den Rest der Auswahl tot zu sein.
- Die Unterkante einer nebeneinander gelegten Karte zu ziehen ändert die Höhe dieser Karte, statt sie in die Reihe des Rasters zurückschnappen zu lassen, so dass eine Karte nicht mehr mit jedem Zug schrumpft und die Karten daneben ihre Höhe behalten.
- Die Vorschau des Tierarztberichts folgt wieder jeder Änderung: ein neuer Zeitraum, der Schalter für die Patientenübersicht und eine herausgenommene Zeile zeichnen sie alle neu, nicht nur die Feldchips. Das Zeichnen graut Teilen und Drucken nicht mehr aus.
- Ein Termin lässt sich nicht mehr ohne jemanden zum Besuchen speichern; Speichern bleibt grau, bis eine Katze oder ein Zuhause gewählt ist.
- Das Adoptionskonfetti auszuschalten verstummt nicht mehr auch den Haken, die Tagesaufgaben, die Leiter und die Adoptionstöne. Ein Gerät, das den Schalter aus hatte, bevor die Momente eigene Töne bekamen, behält seine Stille: sie wird einmal als Wahl für jeden Moment gelesen.
- Ein markiertes Zuhause wird in der Kolonientabelle wieder hervorgehoben; die Zeile war markiert, sah aber aus wie jede andere.
- Markierte Katzen zu verschieben, die nicht alle im selben Zuhause sind, beginnt jetzt ohne Haken, und jede Wahl, die Straße eingeschlossen, lässt sich speichern. Die Straße sah angehakt aus, und Speichern blieb grau.
- Markierte Zeilen bleiben in dem Katalog, in dem sie markiert wurden. Sie überlebten einen Wechsel, und eine Sammelaktion, vor allem ein Löschen, zielte dann auf Katzen, von denen der neue Katalog nie gehört hat.
- Das Plus auf einem breiten Bildschirm fächert seine Wege wieder unter sich auf: im zweispaltigen Layout wurden sie eine Spaltenbreite weiter links gezeichnet, über der Liste.
- Einen Katalog zu löschen nimmt den, den die Frage nennt. Einen anderen Katalog auf der Katalogseite anzusehen konnte diesen markiert lassen, und das Löschen aus den Einstellungen nahm dann ihn statt den, nach dem es gefragt hatte.
- "Aus einem anderen Katalog hereinholen" funktioniert mit drei Katalogen oder mehr; es tat zuvor gar nichts und warf einen Fehler, wo niemand ihn sah.
- Einen Konflikt in dem Fenster zu entscheiden, das das Angekommene auflistet, lässt das Fenster offen, mit den noch zu entscheidenden Konflikten darin. Es schloss zuvor bei der ersten Wahl.
- Was von einem Telefon oder einem Ordner ankommt, zeigt sich sofort: ein Abgleich schrieb die Einträge, sagte es aber nie den Ansichten, so dass die Katzen, das Home, die Agenda und der Stammbaum den Katalog weiter zeigten, wie er davor war.

## [2.0.6] - 2026-09-27

### Neu
- Eine Familienansicht auf dem Schreibtisch, neben den anderen Ansichten: jede Katze mit Verwandten als ihr Gesicht und ihr Name, nach dem Geburtsmonat gruppiert, die älteste oben, eine Linie zwischen einem Kitten und seiner Mutter oder seinem Vater, und die Katzen, deren Geburtstag niemand aufgeschrieben hat, zuletzt unter einem Fragezeichen. Ein Gesicht öffnet diese Katze.
- Die Agenda ist jetzt eine Liste neben einem Kalender, keine drei Reiter: die Pläne links, ein Monat oder eine Woche rechts. Die Woche legt den Tag Stunde für Stunde aus, mit einem Ganztagsband darüber und einer Linie über der aktuellen Zeit; der Monat gibt jedem Tag eine Zelle mit seinen Ganztagsdingen zuerst und den zeitlichen darunter, wiederkehrende Aufgaben an jedem Tag, an dem sie fällig sind. Zurück, vor, Heute und eine Monatswahl steuern ihn, und ein Eintrag öffnet die Katze oder das Zuhause, zu dem er gehört.
- Eine Vorschau auf den Dokumentseiten des Schreibtischs: die Karte als das Bild, das sie wird, aktualisiert, während Werte an- und abgehakt werden, und das, was auf dem Vermisst-Plakat und dem Tierarztbericht gedruckt wird.
- Der Tierarztbericht auf dem Telefon wird so gezeigt, wie er gedruckt wird, wie es das Vermisst-Plakat schon war.
- Mehrere Zeilen markieren und sie in einem Zug in ein anderes Zuhause verschieben, aus beiden Tabellen.
- Eine Karte auf dem Schreibtisch wird durch Ziehen ihrer Unterkante höher oder niedriger und behält diese Höhe.
- Die Karte eines Zuhauses kann jedes Tier, das darin lebt, auf einmal auf den Schreibtisch legen und nebeneinander ordnen.

### Behoben
- Die als Bild kopierte Karte bricht ihre Werte um, statt sie in einer Zeile über den rechten Rand laufen zu lassen, und das Blatt ist so hoch wie sein Inhalt statt eine halbe Seite weiß.
- Die rote Textzeile oben in einer Ansicht ist weg: was die App zu sagen hat, ist eine Notiz oben im Fenster, die von selbst geht, wenn sie nur sagt, dass ein Vorgang fertig ist, und mit einem × bleibt, wenn etwas fehlschlug.
- Eine Karte, ein Foto oder ein Diagramm zu kopieren antwortet mit einer grünen Pfote am Zeiger statt mit einem Wort in der Ecke; und die Pfote des Telefons erscheint endlich: sie ging in die nächstbeste Überlagerung, so dass eine in einem Dialog angeforderte Pfote mit dem Dialog verschwand.
- Die Zeitleiste öffnet sofort: sie lief zuvor bei jedem Bild das ganze Protokoll erneut durch, was sie auf einem echten Katalog unbenutzbar machte.
- Das Diagramm des Schreibtischs bietet die Bereiche des Telefons, Woche, Monat, Jahr, alles und einen eigenen Von/Bis, und schreibt sie unter die eigene Einstellung des Telefons, so dass ein auf beiden geöffneter Katalog zeigt, was auf dem anderen gewählt wurde.
- Das Zuhause, in dem eine Katze jetzt ist, wird im Umzugsdialog schlicht genannt; es trug zuvor einen Haken, den diese Schrift nicht hat und der als leerer Kasten gezeichnet wurde.

### Geändert
- Die Seite hinter Bearbeiten ist in Reiter geschnitten, Felder, Fotos, Pläne und Familie, und Felder, Katzen und Pläne für ein Zuhause, statt einer langen Rolle. Der zuletzt benutzte Reiter kommt mit der nächsten Seite wieder.
- Jeder Dialog auf dem Schreibtisch bestätigt rechts, mit Abbrechen daneben.
- Der Werteditor liest sich jetzt wie ein Dialog: Luft um seinen Inhalt, der Wert, das Datum, ab dem er zählt, und die Privat-Markierung getrennt gehalten.
- Kästchen auf dem Schreibtisch sind Quadrate, die sich selbst abstreichen, statt eines zu kleinen Hakens.
- Zeilen in der Katzen- oder Kolonientabelle zu markieren lohnt sich jetzt: die markierten Zeilen tragen ein Menü, alle auf dem Schreibtisch öffnen, in ein anderes Zuhause oder einen anderen Katalog verschieben, verstecken oder zeigen, in eine Datei exportieren, nach einer Frage löschen, und ein Haken auf einer markierten Zeile spricht für jede markierte Zeile.
- Die Zeilen einer Karte sind durch eine Haarlinie getrennt statt durch wechselnde Farben, und der Rollbalken des Körpers schwebt über ihnen, so dass die Karte von der Titelleiste abwärts eine Form ist.
- Stapeln legt den Stapel in der Reihenfolge der Kaskade: die oberste Karte liegt am weitesten hinten.
- Das Menü der Karte sagt "In ein anderes Zuhause verschieben" statt "Verschieben nach" und bietet "Hier gesehen" nicht mehr an; ein Schreibtisch hat kein Hier.

## [2.0.5] - 2026-09-26

### Neu
- Wochen- und Monatsansichten auf der Agenda des Schreibtischs, neben der Liste, die sie schon hatte: die Termine, Erinnerungen und fälligen Aufgaben auf ihren Tagen ausgelegt, ein Schritt vor und zurück und ein Weg heim zu heute, und ein Eintrag, der die Katze oder das Zuhause öffnet, zu dem er gehört.
- Eine Katalogseite auf dem Schreibtisch: jeder Katalog auf diesem Gerät links, was mit dem gewählten geht rechts, anlegen, öffnen, umbenennen, löschen, und der gemeinsame Ordner mit einem Weg, das Teilen zu beenden. Die Katalogeinträge im Menü sind weg; das Menü öffnet die Seite.
- Zwei weitere Töne zur Wahl für jeden Moment, auf Telefon und Schreibtisch: Sonne miau und Sonne purr, die Stimme einer zweiten Katze.
- Eine Katze oder ein Zuhause lässt sich auf dem Schreibtisch von seiner Karte aus umbenennen: der Stift neben dem Namen auf der Titelleiste.
- Die Karte eines Zuhauses wählt, welche Felder sie zeigt, wie es die Karte einer Katze schon tat.
- Eine mehr als einmal gemessene Zahl zeichnet ihren Verlauf unter den Wert auf der Karte; das Gewicht auf einen Blick, ohne den Verlauf zu öffnen.
- Eine Adresse lässt sich suchen, wenn auf dem Schreibtisch ein Ort gesetzt wird: eintippen, Suchen drücken, den Treffer wählen. Die Suche läuft nur auf Anfrage, nie beim Tippen.
- Jedes Freitextfeld auf dem Schreibtisch nimmt so viele Zeilen, wie der Betreuer schreibt, nicht nur Bemerkungen.
- Knöpfe für näher, weiter und Pin für Pin auf der Karte des Schreibtischs, neben der Suche und den Streunergebieten, die sie schon hatte; die Ortswahl bekommt die Zoomknöpfe auch.
- Umschalt und Ziehen auf der Karte des Schreibtischs zieht einen Kasten und zoomt hinein; schlichtes Ziehen verschiebt weiter.
- Ein Kalender im Feldeditor des Schreibtischs: ein Datum wird aus dem Monat gewählt statt ausbuchstabiert, und lässt sich weiter tippen.
- Ein Ort auf einer Karte zeigt, wo er ist: die Koordinaten mit ihrem Plus Code, ein Bild der Stelle auf der Karte und der Code, den ein Telefon liest, um hinzukommen, statt der Worte "Auf der Karte".

### Geändert
- Das Verlaufsdiagramm auf dem Schreibtisch nimmt einen Zeitraum, ein Monat, sechs Monate, ein Jahr oder alles, und die geglättete Kurve ersetzt die gemessene Linie, statt darüber gezeichnet zu werden.
- Das Menü der Karte sagt Bearbeiten, weil die Seite dahinter der Ort ist, an dem eine Katze oder ein Zuhause bearbeitet wird, und bietet daneben Zeitleiste an: alles, was dem je geschah, in einem eigenen Fenster statt einer Falte am Fuß der Seite.
- Die Mutter- und Vater-Auswahl auf dem Schreibtisch bietet nur Katzen an, die es sein könnten; ein Kater wird nicht mehr als Mutter angeboten und dann abgelehnt. Eine Katze unbekannten Geschlechts wird weiter angeboten.
- Eine Karte auf dem Schreibtisch listet nur die Felder, für die die Katze oder das Zuhause tatsächlich einen Wert hat, und jeder Wert wird mit dem Stift an seiner Zeile geändert, der den gewöhnlichen Feldeditor öffnet, so dass eine Privat-Markierung und eine Datumswahl überall da sind, wo der Wert bearbeitet wird. Ein Knopf unter den Zeilen füllt ein noch leeres Feld. Ein langer Wert bricht über so viele Zeilen um, wie er braucht, und eine Karte, deren Körper über den Schreibtisch hinauswächst, rollt in sich selbst, statt über den Rand zu wachsen. Jede Zeile ist so breit wie die Karte, so dass die Streifen nicht mehr auf halbem Weg enden, und der Umriss der Karte ist gegen die eigene Titelleiste sichtbar.

### Behoben
- Die Karte des Schreibtischs zoomt so tief, wie die Kacheln reichen, hält den Ort unter dem Zeiger beim Zoomen fest, und das Rad sammelt, bevor es eine Stufe springt, so dass ein Streifen des Rads die Ansicht nicht mehr auf die ganze Welt hinauswirft.
- Eine abgehakte Aufgabe im Verlauf des Schreibtischs nennt die Aufgabe, "Füttern erledigt" statt "Aufgabe erledigt", und wiederholt nicht mehr das Datum, das die Zeile daneben schon trägt.
- Der Verlauf eines Feldes auf dem Schreibtisch liest sich wie ein Tagebuch: der Tag steht über dem, was an ihm geschrieben wurde, und ein langer Wert bricht um, statt das Fenster über beide Bildschirmränder zu dehnen.
- Nebeneinander auf dem Schreibtisch passt jede Karte in ihre Zelle; eine Karte mit mehr Inhalt, als die Zelle fasst, rollt in sich, statt außer Reichweite gelegt zu werden. Nebeneinander legt ein echtes Raster: Spalten aus der Breite des Schreibtischs, Zeilen, die sich teilen, was über dem Dock bleibt. Es begann zuvor die zweite Zeile unter der höchsten Karte, was diese Karten vom Schreibtisch schob, wo egui sie festnagelte und keine Hand sie zurückziehen konnte. Keine Karte wird jetzt mehr über den Rand des Schreibtischs gelegt, wie auch immer sie angeordnet wurde.

## [2.0.4] - 2026-09-25

### Neu
- Die Erinnerung einer Aufgabe sagt Mrrr: die Benachrichtigung trägt Sockes Ruf statt des eigenen Tons des Telefons, und der Schreibtisch spricht ihn mit seinem Hinweis. Ein Schalter unter Töne auf beiden Einstellungsseiten stellt ihn auf den Systemton zurück.
- Drei weitere Töne zur Wahl für jeden Moment, auf Telefon und Schreibtisch: Meep, Mrrp und Mrrr, die Rufe einer Katze namens Socke.

### Entfernt
- Der Miau-Ton. Meep tritt an seine Stelle als Ton einer abgehakten Aufgabe, und der Chor für eine erklommene Leiter besteht jetzt aus Sockes drei Rufen statt aus drei geborgten Miaus. Ein Gerät, das Miau für einen Moment gewählt hatte, hört wieder den eigenen Ton dieses Moments.
- Die Karten des Schreibtischs tragen eine Titelleiste wie ein Fenster: der Name, × zum Schließen, ⋮ mit dem Menü. Ein Dock schwebt unten am Schreibtisch, solange Karten darauf liegen: Nebeneinander legt sie in Reihen aus, Stapeln kaskadiert sie, Alle schließen räumt den Schreibtisch, und ein Gesicht je offener Karte holt diese Karte nach vorn, die oberste mit einem Punkt markiert.

## [2.0.3] - 2026-09-24

### Neu
- Ein Erfolg lässt sich löschen: auf dem Telefon halten, auf dem Schreibtisch Rechtsklick oder das ⋮. Für den Tippfehler einer Aufgabe oder eine Leiter, die niemand will. Er bleibt weg, bis die Leiter über die Stufe hinaus steigt, auf der er abgewinkt wurde, was als neu zählt.

### Entfernt
- Der CSV-Export im Startmenü des Telefons. Eine flache Zeile pro Katze war kein Export eines Katalogs; was ein Export enthalten sollte, ist eine offene Frage, und nichts tritt an seine Stelle, bis sie beantwortet ist.

### Geändert
- Der Abgleichordner löscht nichts mehr im Namen eines anderen Geräts. 2.0.2 entfernte die Gesamthistorie-Datei einer Installation, die eine Woche still war; jetzt bleibt eine solche Datei, wo sie ist, niemand wird für sie genannt, und die lebenden Geräte lassen die eingefrorenen Dateien fallen, die sie für sie hielten. Ein Leser, der später kommt, liest sie und geht weiter.
- Bilder aus einem Video zu wählen ist eine eigene Seite mit dem laufenden Video darin: der Schieber sucht das Bild, während der Finger sich bewegt, Abspielen und Pause, Schritte von einem Bild, einer Sekunde und zehn Sekunden in beide Richtungen, gehalten zum Wiederholen, und "Dieses Bild behalten" nimmt genau das Bild an der Position des Players. Die behaltenen Bilder reihen sich unten auf, ein Tipp lässt eines los. Die geratenen "vorgeschlagenen Bilder" sind weg; der Scrubber, der ein Bild erst eine halbe Sekunde nach dem Innehalten des Fingers zeigte, ist mit ihnen weg.

### Behoben
- Die Seite einer frischen Katze öffnet nicht mehr mit aufgefächertem Plus; es fächerte von dort, wo der "Anlegen"-Knopf gewesen war, seine Einträge über der Leiste. Das Plus bleibt ein Plus, bis es angetippt wird, und während der Fächer offen ist, steht das Minus beleuchtet über dem Schleier statt verdunkelt darunter.

## [2.0.2] - 2026-09-23

### Neu
- Das Porträt einer verstorbenen Katze trägt den Trauerflor, ein schwarzes Band über ihrer unteren rechten Ecke: auf dem Bild in jeder Liste, dem Kartenpin, der Karte, und auf den Gesichtern, Zeilen und Kacheln des Schreibtischs. Auch auf dem Platzhalter, damit eine Katze ohne Foto als verstorben zu lesen ist. Die anderen Fotos bleiben, wie sie sind.
- Eine Verlaufszeile mit Position trägt ein Kartensymbol: die Karte öffnet auf diesem Ort mit gezeichneter Spur und dem Punkt dieses Werts markiert.
- Getippte Felder im Werteditor (Bemerkungen, Zahlen, Messwerte, IDs) tragen ein X, das sie leert, so dass eine frische Notiz leer beginnt, ohne erst die alte zu markieren und zu löschen.
- Einen Spurpunkt auf der Karte zu halten öffnet dort sein Menü: der Verlauf des Werts, eine Korrektur, wo das Feld einen Editor hat, und das Entfernen. Die Karte selbst zu halten bietet die Streuner für eine Sichtung in einem Menü am Finger an.

### Geändert
- Home und Agenda des Schreibtischs sind in Karten gelegt: jeder Abschnitt ist eine abgerundete Karte mit Überschrift, und eine Aufgabe, ein Termin oder eine Erinnerung ist eine zweizeilige Zeile darin, das Kästchen oder Abschließen an seiner Seite, wessen es ist mit dem Gesicht in der zweiten Zeile. Letzte Änderungen sind nach Tag gruppiert, Heute und Gestern mit Namen, ältere Tage mit Wochentag und Datum, jede Zeile mit ihrer Zeit und dem Gesicht der Katze oder dem Titelbild der Kolonie. Die "Zuletzt angesehene" Kolonie zeigt ihr eigenes Titelbild, nicht das Gesicht einer Katze. Wochentagsnamen sind übersetzt.
- Eine heute abgehakte Erinnerung oder ein Termin bleibt für den Tag auf der Agenda, Kästchen angehakt, wie eine Aufgabe. Der Haken fragt nichts; ein Tipp auf die erledigte Erinnerung plant den nächsten Zyklus, ein Tipp auf den erledigten Termin öffnet seine Ergebnisnotizen wieder, das Kästchen hakt ab, der Papierkorb nimmt es von der Liste.
- Eine Katze umzuziehen ist ein Dialog: die Zuhause und "Streuner" als Zeilen, der Tag am Fuß für einen zurückliegenden Umzug.
- Einen Katalog anzulegen fragt nichts über das Hereinholen; "Aus einem anderen Katalog hereinholen…" ist eine Zeile auf der Einstellungsseite des Katalogs.
- Das Einheitensystem wird auf der Einstellungszeile selbst gewählt, ohne Dialog.
- Nichts schiebt sich mehr von unten herein. Jedes Menü öffnet dort, wo der Finger ist: das Fotomenü, das Menü des Titelbilds, der Katalogwechsler unter dem Titel, die Menüs der Karte. Hilfe ist eine eigene Seite, und geteilte Fotos werden auf einer Seite abgelegt, die Katzen, Zuhause mit "Neue Katze hier", einen neuen Streuner und ein gleich dort getipptes neues Zuhause auflistet.
- Verlaufszeilen auf der Zeitleiste, im Feldverlauf und im Aufgabenprotokoll haben die Form der Agenda: ein Tipp korrigiert, der Papierkorb entfernt, eine entfernte Zeile zeigt den Pfeil, der sie zurückholt. Tag und Zeit eines Aufgaben-Hakens werden in einem Dialog korrigiert.
- Ein Aufgaben-Haken im Verlauf nennt seine Aufgabe und den Tag, für den er zählt, wenn das nicht der Tag ist, an dem er abgehakt wurde.
- Ein Knopf, der "Foto aufnehmen" oder "aus der Galerie" sagt, fragt nicht mehr, was er meinte.

### Behoben
- Der Abgleichordner nennt eine verschwundene Installation nicht mehr bei jedem Start als "braucht noch die neue Version". Eine Gesamthistorie-Datei, in die eine Woche lang niemand geschrieben hat und deren Einträge jedes Gerät schon hält, ist eine alte Installation; Telefon und Schreibtisch löschen sie und ihre Schlüsseldatei, und die lebenden Geräte lassen die eingefrorenen Dateien fallen, die sie für sie hielten. Ein Manifest, das noch vom Cloud-Client unterwegs ist, zählt auch nicht mehr als Gerät im alten Layout.
- Der Schreibtisch ist mit einem echten Katalog benutzbar. Er fragte zuvor bei jedem Bild die Datenbank nach jedem Wert, und jede solche Abfrage durchsuchte das ganze Protokoll zweimal, so dass ein Katalog mit tausend Katzen in der Katzenansicht zehn Sekunden pro Bild brauchte und eine halbe Minute auf der Agenda. Der Speicher hält jetzt zwischen zwei Schreibvorgängen, was jede Abfrage braucht, die Ansichten behalten ihre Zeilen, bis sich etwas ändert, und die Erinnerungsprüfung läuft zweimal pro Minute statt einmal pro Bild.
- Die Ergebnisnotizen eines abgeschlossenen Termins stehen im Verlauf unter dem Besuch; sie wurden gespeichert, aber nirgends gezeigt.
- Auf Linux zeigt der Menüeintrag des Schreibtischs das Katzensymbol, auf KDE wie auf GNOME. Der Eintrag nennt das Symbol bei seinem Themennamen, und ein PNG mit 256 Pixeln liegt dort, wo jeder Desktop nachsieht; 2.0.1 zeigte den Eintrag auf eine SVG-Datei im Homebrew-Verzeichnis, die nichts zeichnete. Der Schreibtisch hält auch bei jedem Start seinen eigenen Starter, sein Symbol und den Dateityp `.catsync` im Anwendungsmenü aktuell, so dass eine Homebrew-, Tarball- oder AppImage-Installation nach einem Start mit Symbol im Menü steht, und eine verschobene Binärdatei heilt ihren Eintrag selbst.

## [2.0.1] - 2026-09-21

### Geändert
- Jeder Ton hat seine eigene Einstellung, auf Telefon und Schreibtisch: eine abgehakte Aufgabe, die erledigten Tagesaufgaben, eine erklommene Leiter, eine Vermittlung, jede mit einer Liste zur Wahl unter Einstellungen, Töne. Die Wahl ist beim Wählen zu hören; Keiner ist eine Wahl, und eine eigene Tondatei auch. Der eine Jubel-Schalter ist weg; ein Gerät, das ihn aus hatte, bleibt still, bis ein Moment seinen eigenen Ton bekommt.
- Das Titelbild einer Kolonie ist eine Zeile mit der Kamera und der Galerie als Knöpfen, auf dem Telefon; die Zeile des Schreibtischs sagt neben ihrem Knopf, was sie ist. Die Erklärung und das Blatt dazwischen sind weg. Die Streunerliste beginnt mit derselben Zeile für ihr eigenes Bild statt mit einem Symbol in der Leiste.
- Ein Plus auf jeder Seite, die auf mehr als eine Art hinzufügt, fächert die Arten mit ihren Worten auf: auf der Streunerliste Neuer Streuner, Foto aufnehmen, Aus der Galerie, Aus Video, Aushang von der Kamera und Aushang aus der Galerie; auf der Seite einer Katze Foto aufnehmen, Aus der Galerie, Aus Video, Termin, Erinnerung und Aufgabe, schon aufgefächert, wenn die Seite einer frischen Katze öffnet; auf der Seite einer Kolonie Katze hinzufügen, Termin, Erinnerung und Aufgabe; auf der Agenda die drei Arten von Plänen. Die Symbole für Streunerkamera, Aushang und Erinnerung hinzufügen in den Leisten sind weg, ebenso der Dialog "Termin oder Erinnerung?". Ein Streunerkamera-Bild öffnet die Seite gleich im Bearbeitungsmodus, die Tierart als Feld darauf; die Aussehen-Frage vor der Seite ist weg.
- Jeder Planeditor beginnt damit, wessen er ist, ein Für-Feld, voreingestellt von der Seite, von der er geöffnet wurde, und änderbar; von der Agenda beginnt er mit der zuletzt angesehenen Katze oder Kolonie. Der Dialog, der zuerst nach dem Wessen fragte, ist weg, auch vor einer duplizierten Aufgabe.
- Der Streunerkamera-Knopf der Karte ist weg; ein Streuner wird von der Streunerliste aus angelegt.
- Ein Konflikt wird auf seiner Zeile entschieden: die zwei Werte sind Knöpfe mit wer und wann, ein Tipp behält einen. Auf der Konfliktseite, auf der Ankunftsseite, und ebenso in den Konflikt- und Ankunftsansichten des Schreibtischs; das Konfliktabzeichen eines Feldes führt zur Konfliktseite. Der Dialog, der noch einmal fragte, ist weg, und seine Erklärung auch.
- Die drei Zeilen der Agenda teilen eine Form: das Kästchen links hakt eine Aufgabe ab, markiert eine Erinnerung als erledigt oder schließt einen Termin ab, ein Tipp öffnet, wessen er ist, ein langer Druck bearbeitet ihn, und ein Papierkorb rechts entfernt eine Erinnerung oder löscht einen Termin. Die Halte-Menüs auf den Erinnerungs- und Terminkarten sind weg.
- Auf der Seite einer Kolonie öffnet ein langer Druck auf eine Katze gleich ihre Karte; das Zwei-Punkte-Menü ist weg. Export und Kalender-Neuabgleich der Agenda sind Symbole in der Leiste statt eines Ein-Punkt-Menüs.
- Schreibtisch: ein Menü unter cat(a)log hält Einstellungen und Beenden anstelle von Datei und Bearbeiten; die Sprache wird nur in den Einstellungen gewählt. Zusammenführen ist ein Knopf neben Neue Katze auf der Seite einer Kolonie. Das Menü einer Zeile hält nur, was ein Klick nicht schon tut, und jede Zeile mit Menü zeigt an ihrem Ende ein ⋮, die Aufgabenzeile eingeschlossen, damit der Rechtsklick nicht der einzige Weg hinein ist.
- Einen persönlichen Abgleich anzubieten fragt nicht mehr, ob das Telefon, das gerade den Code gescannt hat, beitreten darf: der Code und die PIN vom Bildschirm sind die Antwort. Immer erlaubte Geräte, ihre Liste unter Autoren und die Frage auf dem Schreibtisch sind damit weg; der Schalter Private einschließen bleibt die eine Einstellung, die ein Beitritt liest.
- Ein Knopf, der schon Kamera sagt, öffnet die Kamera: die Aushang-Erfassung, und die Bildkacheln des Vermisst-Plakats, die jetzt als Galeriekachel und Kamerakachel kommen. Die Aushang-Erfassung von der Seite einer Katze bietet die beiden als Knöpfe auf ihrer Seite.
- Jede Ansicht auf dem Schreibtisch öffnet mit ihrem Namen als Überschrift unter der Leiste; Agenda, Karte und Tierarzt quetschen ihren nicht mehr in die Werkzeugleiste.
- Die Tipps des Schreibtischs sehen aus und funktionieren wie die des Telefons: eine Blase mit Überspringen und Weiter, Verstanden auf dem letzten einer Seite, Überspringen beendet die Tipps dieser Seite. Ein Tipp, dessen Element nicht auf dem Bildschirm ist, zeigt dieselbe Blase unter der Leiste statt einer Zeile unter dem Menü. Die Einführung fragt, ob die Tipps gewünscht sind, mit Mit den Tipps starten und Ohne Tipps starten unter dem Namen, statt eines Kästchens.

### Behoben
- Auf Linux steht der über Homebrew installierte Schreibtisch gleich nach `brew install` im Anwendungsmenü, und sein Fenster zeigt das Katzensymbol auf Wayland; zuvor musste der Menüeintrag von Hand eingetragen werden, und das Fenster trug ein allgemeines Symbol. Das `.deb` zeigt das Symbol auf Wayland auch. `catlog-install-icon --uninstall` nimmt den Menüeintrag wieder heraus.

## [2.0.0] - 2026-09-20

### Neu
- Die Desktop-App ist neu, in Rust geschrieben, und sieht aus wie das Telefon: das Creme aus dem Symbol, das Katzenorange für das Gewählte, Noto Sans und die Material-Symbole neben jeder Beschriftung. Eine Leiste unter dem Menü führt zu sechs Ansichten über dieselben Kataloge, gemeinsamen Ordner und `.catsync`-Bündel, die die Telefone benutzen: Home, ein Überblick mit den Zahlen, dem heute Fälligen mit Haken und Abschließen, den letzten Änderungen und der zuletzt angesehenen Katze und Kolonie; Katzen, eine Tabelle mit je Katalog gewählten Spalten, Sortierung, Suche, den Filtern Streuner und Vermisst und Mehrfachauswahl; Kolonien, eine Tabelle mit Gesichtern, Zahlen und Status; Karte; Agenda; und Tierarzt, die Fahrten und Termine über alle Katzen mit dem Patientenblatt und dem Bericht einen Klick entfernt. Eine Katze oder Kolonie öffnet sich als Karteikarte auf dem Schreibtisch, mehrere nebeneinander, an ihren Platz gezogen und dort wiedergefunden; einfache Werte werden auf der Karte bearbeitet, komplexe im Editor; jede andere Seite öffnet als Dialog, den Escape schließt. Bewegung ist bescheiden, und der Augenschmaus-Schalter stillt sie. Eine Aufgabe wird aus ihrem Dialog auf eine andere Katze oder ein anderes Zuhause dupliziert, eine Kolonie bekommt ihr Titelbild, die Karte sucht Katzen, Kolonien, Personen und Orte, eine neue Katze kommt mit einem vorgeschlagenen Namen und dem Würfel für einen anderen, und das Unmögliche wird mit den Worten des Telefons verweigert, wie auf dem Telefon. Ein Tipp umringt das Element, um das es geht, und spricht daneben. Der Rest ist der des Telefons: Kolonien, Katzen und Streuner mit ihren Feldern, Fotos mit Zuschneiden und Markieren, Aufgaben mit der Agenda und Desktop-Erinnerungen, Termine und Tierarztfahrten, die Karte mit Sichtungen und Streunergebieten, die Abgleichseiten mit der Wartezeile und die Konfliktseite, Dubletten mit Zusammenführen und Verschieben, Momente mit Zurückgehen, automatische Sicherungen mit Wiederherstellen, Archivieren, die Autorenseite mit Sperren, die Karte, das Vermisst-Plakat mit seinem QR-Code und der Bericht für den Tierarzt als PDFs, Aushang-Erfassung aus einer Bilddatei, Erfolge mit dem Jubel, Tipps, Hilfe und Einstellungen. Linux kommt als tar.gz, .deb und AppImage, Windows als Zip über Scoop, macOS als dmg über das Homebrew-Cask.
- Der Schreibtisch bietet einen persönlichen Abgleich an (#138): Gastgeber werden auf der Abgleichseite zeigt den Paarcode als QR und als Text mit der PIN, ein Telefon tritt bei, wie es einem anderen Telefon beitritt, jedes unbekannte Telefon wird einmal, immer oder nicht erlaubt, und was ankam, öffnet sich wie nach einer Ordnerrunde. Der Schreibtisch bedient über sein eigenes Zertifikat nur, solange der Dialog offen ist.
- Als Bild kopieren auf dem Schreibtisch (#138): die gedruckte Karte aus dem Menü einer Karte und von ihrer Dokumentseite, ein Foto in voller Größe aus dem Betrachter, und das Verlaufsdiagramm auf weißem Grund mit Titel, Bereich, Tagen und Trend, jedes direkt in die Zwischenablage für einen Messenger oder eine Mail.
- Duplizieren im Editor einer Aufgabe: wähle die Katze oder das Zuhause, für das die Kopie ist, und ein neuer Editor öffnet mit demselben Titel, Rhythmus, derselben Zeit und Erinnerung über dem Original, so dass jedes Kitten seine Fütterung mit einer Wahl und einem Speichern bekommt.

### Geändert
- Ein gemeinsamer Ordner trägt eine Änderung binnen einer Minute, solange beide Apps auf dem Bildschirm sind: jeder auf diesem Telefon geschriebene Eintrag geht ein paar Sekunden später in den Ordner, gesammelt mit allem, was in diesen Sekunden dazukommt, und der Ordner wird alle dreißig Sekunden angesehen statt alle fünf Minuten. Die Historie eines Telefons im Ordner ist eine Folge kleiner Segmente neben einem Manifest: nur das offene Segment reist, volle nie wieder, und ein Leser nimmt nur die Zeilen, die er noch nicht gesehen hat. Ein Zusammenführen, das das Telefon von selbst lief, sagt nichts außer den Neuigkeitsnotizen; ein eine Weile unerreichbarer Ordner erzeugt eine Notiz, die bleibt, bis sie weggewischt wird. Telefone und der Schreibtisch schreiben und lesen das neue Layout in dieser Version; ein Gerät, das noch das alte hat, behält, was es hatte, und wird genannt, bis es aktualisiert.
- Alles, was die App zu sagen hat, kommt jetzt oben auf den Bildschirm, unter die Statusleiste: eine Notiz nach der anderen, die Seite rutscht darunter nach unten, nichts unten, wo die Navigationsgesten und die Tastatur sind. Eine dünne Linie pulsiert mit einem Symbol pro laufendem Vorgang, solange ein Ordner-Abgleich, ein persönlicher Abgleich, eine Sicherung oder ein Archivieren läuft. Eine Notiz sagt nur, dass ein Vorgang fertig ist, dass er fehlschlug oder dass Änderungen warten: tippe einen fertigen Abgleich an für das, was ankam, einen Fehler für die Ursache, den vollen Text und einen Melden-Knopf, wische nach links für die nächste Notiz, nach rechts, um die Neuigkeiten wegzuräumen; ein Fehler bleibt, bis er nach links gewischt oder angetippt wird, ein fertiger Vorgang geht nach drei Sekunden. Kopiert, eingetragen und geleert melden sich nicht mehr; eine grüne Pfote am angetippten Knopf sagt, dass es geklappt hat. Die Abgleichseiten drucken keine Eintrags- und Fotozahlen mehr, und ein schon vergebener Katalogname wird unter dem Namensfeld beantwortet. Auf der Ankunftsseite sind die Haken einer Aufgabe eine Zeile mit Titel und Zahl der Aufgabe, und die Zeile einer Katze nennt, was sich änderte, statt Änderungen zu zählen.
- Der Jubel sind jetzt Katzen, auf Telefon und Schreibtisch: ein kurzes Miau, wenn eine Aufgabe abgehakt wird, ein Schnurren, wenn die Aufgaben des Tages erledigt sind, ein Chor von Miaus für eine erklommene Leiter, ein Miau über einem Schnurren für eine Vermittlung. Die Aufnahmen stammen von Wikimedia Commons, CC0 und gemeinfrei; der Menschenjubel und sein Hinweis sind weg.
- Die Aushang-Textseite zeigt eine Karte pro Zeile, den Text so breit wie die Seite, das Ziel darunter; das X oder ein Wisch legt eine Zeile beiseite, Rückgängig holt sie zurück. Links auf den Text- und Registerseiten und im Dienst-merken-Dialog werden ganz gezeigt.
- Der Abgleich über den gemeinsamen Ordner ist mehrfach schneller: eine Runde überspringt die Einträge, die sie schon hält, bevor sie sie prüft, und die Abfragen hinter privaten und zusammengeführten Werten werden einmal gestellt statt einmal pro Eintrag. Eine Runde ohne Neues braucht ein Sechstel der Zeit, ein erster Import etwas mehr als die Hälfte.

### Entfernt
- Die Flutter-Desktop-Ziele. Ihre Daten bleiben, wo sie waren; die neue App hält ihre eigenen Daten unter derselben App-Kennung in einem Ordner `v2`.

### Behoben
- Ein Energiesparmodus, der die App im Hintergrund schließt, bringt beim nächsten Start nicht mehr den Absturzbericht. Auf Android 11 und neuer fragt die App das System, warum sie beendet wurde, und bietet den Bericht nur nach einem Absturz, einem Einfrieren oder einem Beenden wegen Speichermangel an, während sie auf dem Bildschirm war; der Bericht nennt den Grund des Systems.
