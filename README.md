# Data IHNED.cz

[Datablog](http://ihned.cz/data/) portálu [IHNED.cz](http://ihned.cz/) vydavatelství [e.conomia](http://economia.ihned.cz/)
ve spolupráci s oddělením vývoje redakčních technologií [IHNED.cz](http://ihned.cz/)

## Volební mapy

http://data.blog.ihned.cz/c1-61086960-jak-se-zmenila-politicka-mapa-republiky-vysledky-snemovnich-voleb-v-kazde-obci-od-roku-1996-do-vcerejska

Podrobné mapy s volebními výsledky významných stran ČR od roku 1996. Použitelné jako overlay pro OpenStreetMap / Google Maps. Pro zobrazení tooltipů využívá [UTFGrid](https://www.mapbox.com/developers/utfgrid/).

Repozitář obsahuje pouze mapové podklady a jednoduchou zobrazovací aplikaci. Neobsahuje generátor SVG mapy a volební výsledky, ty jsou v repozitáři [Volby 2013](https://github.com/economia/volby-2013). Utilita, která z SVG udělá zoomovatelné mapové dlaždice s UTFGrid JSONy je v repozitáři [SVG Mapper](https://github.com/economia/svg-mapper).

### Instalace

    npm install -g LiveScript
    npm install
    slake build

S dotazy a přípomínkami se obracejte na e-mail marcel.sulek@economia.cz.

Obsah je uvolněn pod licencí CC BY-NC-SA 3.0 CZ (http://creativecommons.org/licenses/by-nc-sa/3.0/cz/), tedy vždy uveďte autora, nevyužívejte dílo ani přidružená data komerčně a zachovejte licenci.
