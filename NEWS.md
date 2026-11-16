Hit tab to unselect buttons and scroll through the text using UP/DOWN or
PGUP/PGDN. You can read these announcements again at any time in the main menu
under 01 | Show news.


## Intelligentere Batteriesteuerung ## November 2026
Das EMS plant Ihre Batterie jetzt Viertelstunde für Viertelstunde voraus. Grundlage sind deutlich
genauere Prognosen: Den Verbrauch schätzt das EMS aus den letzten sieben Tagen, die Wärmepumpe
wird dabei getrennt berücksichtigt. Die Solarprognose berücksichtigt die Verschattung Ihrer Module
durch Gebäude oder Bäume (Horizont, auf Wunsch automatisch ermittelt) und passt sich im
Tagesverlauf dem tatsächlichen Ertrag an.

Reicht die Batterie nicht bis zum nächsten Sonnenstrom, lädt das EMS sie in den günstigsten
Viertelstunden aus dem Netz nach, und nur, wenn sich das lohnt. Neu ist "Batterie halten": Ist der
Strom nachts billiger als am Morgen, hält das EMS die Ladung zurück und nutzt sie erst, wenn der
Strom teuer wird. Laufen große Verbraucher wie Wärmepumpe oder E-Auto, schont das EMS die
Batterie, wenn ihr Strom später mehr wert ist. Dass Ihr Speicher kurz vor dem Vollladen langsamer
lädt, berücksichtigt die Planung ebenfalls.

## Weitere Neuerungen ## November 2026
- Wallboxen und E-Autos: Die Auswahl umfasst jetzt über 200 Wallboxen und über 50 Fahrzeugtypen.
  Wallboxen mit Modbus/TCP werden richtig eingerichtet, für EEBus und OCPP zeigt die Einrichtung
  die nötigen Angaben direkt an.
- Home Connect: Spül- und Waschmaschine befüllen, Programm wählen und die Fernstart-Taste
  drücken. Das EMS startet das Gerät dann zur günstigsten Zeit.
- Waschmaschine: frühester Startzeitpunkt einstellbar, damit sie nicht mitten in der Nacht läuft.
- Wärmepumpe: Sperrzeiten werden an den Strompreisen ausgerichtet und nur genutzt, wenn sie
  sich lohnen.
- Negative Börsenpreise: Bekommen Sie für Einspeisung bei negativen Preisen keine Vergütung
  (Solarspitzengesetz), macht das EMS vorher Platz in der Batterie und speichert den Überschuss,
  statt ihn unvergütet einzuspeisen. Das funktioniert mit jedem Stromtarif.

Basis-System aktualisiert auf openHAB 5.2.3 und evcc 0.318.1.

## Systemanalyse mit Claude Code ## November 2026
Neue Installationen enthalten Claude Code (Anthropic) für den Standardbenutzer. Damit können Sie
sich in natürlicher Sprache mit Claude über Ihr System unterhalten: Lassen Sie sich erklären, wie
das EMS arbeitet, und analysieren, warum es sich gerade so verhält, zum Beispiel wenn die Heizungs-
oder Batteriesteuerung nicht tut, was Sie erwarten. Melden Sie sich dazu per SSH als
Standardbenutzer an und starten Sie `claude`. Sie brauchen ein eigenes Konto bei Anthropic, also
ein Claude-Abo (z. B. Pro) oder einen API-Zugang. Auch der storm.house-Support kann damit Ihre
Instanz direkt analysieren (Zugang über VPN/SSH wie bisher). Es werden keine Zugangsdaten
gespeichert; die Anmeldung erfolgt erst in der jeweiligen Sitzung. Abschalten vor der Installation
mit `claudecode=disable` in openhabian.conf, nachträglich installieren oder entfernen in
openhabian-config unter 20 | Optional Components → 2G.
