# Colonel Blotto

Colonel Blotto (czyli Pułkownik Blotto) to wieloosobowa gra strategiczna. Każdy z
zawodników ma do dyspozycji 100 żołnierzy, których rozstawia do walki o 10 twierdz,
ponumerowanych od 1 do 10. W klasycznej wersji gry, pojedyncza runda gry między dwoma graczami (nazwijmy ich
Alicja oraz Robert), przebiega w następujący sposób:
1. Alicja oraz Robert ustalają swoje rozstawienia wojsk. Przykładowo, Alicja może powiedzieć, że jej 
   rozstawienie wygląda następująco: 10, 10, 10, 10, 10, 10, 10, 10, 10, 10. Oznacza to, że do każdego
   z zamku wysyła po 10 żołnierzy. Robert natomiast może wybrać takie rozstawienie: 0, 1, 2, 10, 5, 15, 7, 15, 15, 30.
   Oboje gracze wybierają wojska niezależnie i nie mają wiedzy o wyborach przeciwnika.
2. Po fazie rozstawiania następuje walka. Oba wojska szturmują odpowiednie twierdze. Daną twierdzę zdobywa gracz,
   który zaatakował ją większym zastępem żołnierzy. Przykładowo, twierdzę drugą zdobędzie Alicja, ponieważ
   zaatakowała ją 10 żołnierzami, a Robert jednym. W szczególności, zamku czwartego nie zdobywa żaden z graczy,
   ponieważ oboje wystawili tę samą liczbę żołnierzy.
3. Punkty danego gracza oblicza się poprzez sumę numerów zdobytych przez niego twierdz. W naszym przykładzie 
   Alicja zdobyła twierdze o numerach 1, 2, 3, 5 oraz 7, zatem jej wynik to 18 punktów. Natomiast Robert zdobył
   twierdze 6, 8, 9, oraz 10, zatem zdobywa 35 punktów.

W naszej grze bierze udział N graczy! N-osobowa wersja gry odbywa się w następujący sposób:
1. W fazie rozstawiania, każdy z graczy rozstawia 100 żołnierzy pomiędzy 10 twierdz, niezależnie
   od siebie i bez wiedzy, co robią jego przeciwnicy.
2. Kiedy faza rozstawiania się zakończy, każdy z graczy walczy z każdym innym! Konkretniej, dla każdego
   gracza obliczane są jego wyniki, gdyby odbył walki z każdym innym graczem w dwuosobowej wersji gry.
   Jego wynik w N-osobowej grze to średni wynik wszystkich wyników tych walk. Przykładowo, jeżeli jest 4 graczy,
   i pierwszy gracz miałby zdobyć 11, 25 oraz 24 punkty, walcząc odpowiednio z pozostałymi zawodnikami, 
   to jego ostateczny wynik w tej wersji gry wyniesie (11+25+24)/3 = 20 punktów.
3. Im wyższy wynik, tym wyższe miejsce w danej grze.

## Wskazówki

- Nie ma czegoś takiego, jak wojsko doskonałe. Ta gra to w pewnym sensie papier-kamień-nożyce, ale opcji
  wyboru jest znacznie więcej (spróbuj policzyć ile dokładnie!) i trzeba zdecydować się na jedną na samym
  początku i grać nią ze wszystkimi innymi graczami. Innymi słowy, dla każdego rozstawienia wojska istnieje
  inne rozstawienie, które z nim wygrywa.
- Przeczytaj dokładnie zasady każdej rundy, ponieważ każda z nich jest inna i mają dodatkowe twisty w sposobie
  obliczania wyniku pojedynku.
- Możesz spróbować napisać symulację, która spróbuje znaleźć dobrą strategię dla Ciebie!
