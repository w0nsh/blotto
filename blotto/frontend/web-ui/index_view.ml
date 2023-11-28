open! Core
open! Import
(* open Bonsai.Let_syntax *)

let rules =
  [ N.p
      [ View.text
          "Colonel Blotto (czyli Pułkownik Blotto) to wieloosobowa gra strategiczna. \
           Każdy z\n\
           zawodników ma do dyspozycji 100 żołnierzy, których rozstawia do walki o 10 \
           twierdz,\n\
           ponumerowanych od 1 do 10. W klasycznej wersji gry, pojedyncza runda gry \
           między dwoma graczami (nazwijmy ich\n\
           Alicja oraz Robert), przebiega w następujący sposób"
      ; N.ol
          [ N.li
              [ View.text
                  "Alicja oraz Robert ustalają swoje rozstawienia wojsk. Przykładowo, \
                   Alicja może powiedzieć, że jej \n\
                  \  rozstawienie wygląda następująco: "
              ; N.create "b" [ N.text "10, 10, 10, 10, 10, 10, 10, 10, 10, 10" ]
              ; View.text
                  ". Oznacza to, że do każdego\n\
                  \  z zamku wysyła po 10 żołnierzy. Robert natomiast może wybrać takie \
                   rozstawienie: "
              ; N.create "b" [ N.text "0, 1, 2, 10, 5, 15, 7, 15, 15, 30" ]
              ; View.text
                  ".\n\
                   Oboje gracze wybierają wojska niezależnie i nie mają wiedzy o \
                   wyborach przeciwnika."
              ]
          ; N.li
              [ View.text
                  "Po fazie rozstawiania następuje walka. Oba wojska szturmują \
                   odpowiednie twierdze. Daną twierdzę zdobywa gracz,\n\
                  \  który zaatakował ją większym zastępem żołnierzy. Twierdzę drugą \
                   zdobędzie Alicja, ponieważ\n\
                  \  zaatakowała ją 10 żołnierzami, a Robert jednym. Zamku czwartego nie \
                   zdobywa żaden z graczy,\n\
                  \  ponieważ oboje wystawili tę samą liczbę żołnierzy."
              ]
          ; N.li
              [ View.text
                  "Punkty danego gracza oblicza się sumując numery zdobytych przez niego \
                   twierdz. W naszym przykładzie \n\
                  \  Alicja zdobyła twierdze o numerach 1, 2, 3, 5 oraz 7, zatem jej \
                   wynik to 18 punktów. Natomiast Robert zdobył\n\
                  \  twierdze 6, 8, 9, oraz 10, zatem zdobywa 33 punktów."
              ]
          ]
      ; View.text
          "W naszej grze bierze udział N graczy! N-osobowa wersja gry odbywa się w \
           następujący sposób:"
      ; N.ol
          [ N.li
              [ View.text
                  "W fazie rozstawiania, każdy z graczy rozstawia 100 żołnierzy pomiędzy \
                   10 twierdz, niezależnie\n\
                  \  od siebie i bez wiedzy, co robią jego przeciwnicy."
              ]
          ; N.li
              [ View.text
                  "Kiedy faza rozstawiania się zakończy, każdy z graczy walczy z każdym \
                   innym. Konkretniej, dla każdego\n\
                  \  gracza obliczane są jego wyniki, gdyby odbył walki z każdym innym \
                   graczem w dwuosobowej wersji gry.\n\
                  \  Jego wynik w N-osobowej grze to średni wynik wszystkich wyników \
                   tych walk. Przykładowo, jeżeli jest 4 graczy,\n\
                  \  i pierwszy gracz miałby zdobyć 11, 25 oraz 24 punkty, walcząc \
                   odpowiednio z pozostałymi zawodnikami, \n\
                  \  to jego ostateczny wynik w tej wersji gry wyniesie (11+25+24)/3 = \
                   20 punktów."
              ]
          ; N.li [ View.text "Im wyższy wynik, tym wyższe miejsce w danej grze." ]
          ]
      ; N.h3 [ View.text "Wskazówki" ]
      ; N.ul
          [ N.li
              [ View.text
                  "Nie ma czegoś takiego, jak wojsko doskonałe. Ta gra to w pewnym \
                   sensie papier-kamień-nożyce, ale opcji\n\
                  \                  wyboru jest znacznie więcej (spróbuj policzyć ile \
                   dokładnie!) i trzeba zdecydować się na jedną na samym\n\
                  \                  początku, a następnie grać nią ze wszystkimi innymi \
                   graczami. Innymi słowy, dla każdego rozstawienia wojska \
                   prawdopodobnie istnieje\n\
                  \                  inne rozstawienie, które z nim wygrywa."
              ]
          ; N.li
              [ View.text
                  "Przeczytaj dokładnie zasady każdej rundy, ponieważ każda z nich jest \
                   inna i mają dodatkowe twisty w sposobie\n\
                  \                  obliczania wyniku pojedynku."
              ]
          ]
      ]
  ]
;;

let component = Bonsai.const (Pane.component ~attrs:[ A.class_ "index-view" ] rules)
