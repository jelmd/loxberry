Dies ist ein LoxBerry fork von https://github.com/mschlenstedt/Loxberry/.
Das Repo wird hauptsächlich dazu benutzt, Änderungen bzgl. dem Original alias
upstream festzuhalten und für den upstream relevante Fixes, Features, etc.
effizient zur Verfügung stellen zu können.

Dieser branch basiert auf Version 1.2.5.4 und beinhaltet die Zweige
- local_env_fix
- fix_htaccess
- drop-installfolder
- canonical-path

Branches beginnend mit dem Prefix `local_` sind i.d.R. nicht für den upstream
interessant, alle mit `jel-`-Prefix sind sogenannte orphaned branches mit den
Änderungen bzgl. der jeweiligen releases. Orphaned deshalb, weil die nie in den
master gemerged werden. Ist sozusagen nur ein "empfangender" Zweig zur
Release-Pflege und einfacherem diff bzgl. lokaler Instanzen ;-).


Was ist "der LoxBerry"?
-----------------------

LoxBerry ist ein von Michael Schlenstedt initiiertes Projekt auf Open Source
Basis. LoxBerry ist eine Toolbox, die ein Loxone Smarthome um viele smarte
Features erweitert, die der Loxone Miniserver so nicht bietet. Zum Beispiel:
Kostenloser Wetterserver mit Wunderground® Wetterdaten, Sprachausgabe, Schalten
von WLAN- und Funksteckdosen, eigener Mailserver, Google-/CalDav-Kalenderan-
bindung, Miniserver Backup, usw. usw. 

Der LoxBerry wird vornehmlich für die Raspberry Pi Plattform entwickelt (womit
die Namensgebung wohl geklärt ist), wird aber von einigen Entwicklern teilweise
auch auf andere Hardwareplattformen portiert.  

Ziel des LoxBerry ist es, die erwähnten Erweiterungen unter einer grafischen
Oberfläche zur Verfügung zu stellen, sodass weder zur Installation noch zur
Konfiguration Linux-, Programmier- oder Kommandozeilenkenntnisse erforderlich
sind. 
 
Weitere Informationen
---------------------
 
Weitere Informationen findest Du im Wiki unter http://www.loxwiki.eu/display/LOXBERRY
