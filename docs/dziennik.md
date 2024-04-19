# Dziennik

## Intro

Projekt śpiewnika rozpocząłem na nowo, ponieważ zostałem zaproszony do wyzwania 100commitów.pl i podjąłem rękawicę. To świetna okazja by, z pomocą dodatkowej motywacji, wreszcie dopiąć swego i stworzyć swoją pierwszą aplikację mobilną. W dodatku jakże potrzebną! W tym pliku chcę zapisywać krótkie notki z tej podróży. Tym razem chcę rozpocząć mniej chaotycznie: zacząć od zdobycia potrzebnej wiedzy, i przystąpić do kodowania, kiedy będę miał już solidne podstawy. Przewiduję, że zacznę pisać coś konkretnego za kilka tygodni. Narazie mój cel to ok 0.5-1h dziennie na czytanie o Flutterze.

Wiedzę będę czerpał z książki "Flutter for begginners - third edition". Kod do książki znajduje się [tutaj](https://github.com/PacktPublishing/Flutter-for-Beginners-Third-Edition).

## 01.03.2024
- odinstalowałem poprzednią instalację Fluttera i zainstalowałem na nowo Fluttera metodą Snap

## 02.03.2024
- utworzyłem projekt na GitHub i zdefiniowałem kolejne feature'y i potrzebne zmiany

## 03.03.2024
- skończyłem pierwszy rozdział książki o Flutterze
- uruchomiłe emulator telefonu Pixel 3a
- utworzyłem projekt hello_world i uruchomiłem w emulatorze

## 04.03.2024
- przeczytałem kolejny rozdział książki, poświęcony językowi Dart

## 05.03.2024
- poznałem OOP w Dart, domieszki, generyki i fundamenty programowania asynchronicznego

## 06.03.2024
- poznałem typy oraz podstawy budowy widgetów we Flutterze

## 07.03.2024
- zapoznałem się z podstawowymi wbudowanymi widgetami

## 08.03.2024
- poznałem metody uzyskiwania inputu od użytkowników, formatki oraz obsługę gestów

## 09.03.2024
- zapoznałem się z kolejną porcją widgetów, podstawowymi możliwościami ich stylowania
- SliverList może być przydatne w tym projekcie - dodałem notkę do odpowiedniego taska w projekcie na GitHubie

## 10.03.2024
- zapoznałem się z routingiem we Flutterze

## 11.03.2024
- poznałem sposób na tworzenie własnych animacji przejść między ekranami
- przegląd metod przechowywania i przekazywania stanu między widgetami

## 12.03.2024
- nauczyłem się dodawania i używania pluginów, oraz tego gdzie ich szukać: https://pub.dev

## 13.03.2024
- stworzyłem projekt w Firebase i zapoznałem się z możliwościami jakie daje

## 14.03.2024
- zerknąłem na możliwości animowania widgetów (narazie nie będę tego potrzebował)
- dowiedziałem się jak testować kod oraz widgety
- nauczyłem się debugowania aplikacji
- dowiedziałem się w jaki sposób przygotować aplikację do wdrożenia oraz wdrożyć ją w sklepie Google Play, Apple App Store i Firebase

## 15.03.2024
- utworzyłem projekt Flutter

## 16.03.2024
- dodałem klasę przechowującą szczegóły pieśni

## 17.03.2024
- zbudowałem stronę domową aplikacji
- zbudowałem podstawową, przewijalną listę pieśni

## 18.03.2024
- dowiedziałem się więcej o zarządzaniu stanem aplikacji
- dodałem bibliotekę "provider"
- użyłem biblioteki do inicjalizacji listy pieśni i przechowywania jej

## 19.03.2024
- dodałem suwak do listy pieśni

## 20.03.2024
- bezskutecznie próbowałem sprawić, by lista pieśni nie przewijała się do początku po przełączeniu się na inną zakładkę

## 21.03.2024
- przeniosłem MyHomePage do osobnego pliku
- lista pieśni zapamiętuje pozycję podczas przełączania się pomiędzy tabami
    - osiągnąłem to z użyciem `AutomaticKeepAliveClientMixin` znalezionego w odpowiedzi w [tym wątku na StackOverflow](https://stackoverflow.com/questions/49087703/preserving-state-between-tab-view-pages)

## 22.03.2024
- dodałem podstawową wersję strony z tekstem pieśni
- dodałem otwieranie strony pieśni z poziomu listy

## 23.03.2024
- dodałem abstrakcję repozytorium ulubionych pieśni
- zaimplementowałem repozytorium w oparciu o Set w pamięci oraz w oparciu o SharedPreferences

## 24.03.2024
- zrobiłem działające ikony Favorite, można je już klikać dodając w ten sposób pieśni do listy ulubionych
- niestety implementacja pozostawia wiele do życzenia w kwestii wydajności...
- poprawiłem enkapsulację FavoriteRepository - repo działa teraz na obiektach *Hymn*

## 25.03.2024
- dodałem listę ulubionych pieśni
- dodałem sortowanie po indeksie pieśni w liście ulubionych

## 26.03.2024
- zaaplikowałem automatyczne poprawki zasugerowane przez Darta
- dodałem wczytywanie tekstów do funkcji wczytującej pieśni tak, by były wczytywane wszystkie przy starcie aplikacji

## 27.03.2024
- dodałem SnackBar z informacją o dodaniu lub usunięciu pieśni z listy ulubionych

## 28.03.2024
- zamieniłem `dart analyze` na `flutter analyze` w workflow
- wprowadziłem poprawki tak, by build przechodził na zielono
- zmieniłem sposób przechowywania ulubionych pieśni na InMemory+SharedPreferences

## 29.03.2024
- drobne poprawki w UI

## 30.03.2024
- wyciągnąłem widget listy pieśni do osobnego pliku

## 31.03.2024
- dodałem podstawowe wyszukiwanie po numerach i tytułach pieśni

## 1.04.2024
- poprawiłem performance listy pieśni dodając `prototypeItem` do buildera
- tymczasowo wyłączyłem snackbary ponieważ nie chowają się na androidzie
- dodałem padding w widoku pieśni
- dodałem ikonę "Ulubiona" do widoku pieśni
- usprawniłem wyszukiwanie pieśni - dodałem system oparty o obliczanie score'a na podstawie występowania szukanego tekstu w numerze, tytule i tekście pieśni

## 2.04.2024
- dodałem brakujące testy search engine

## 3.04.2024
- dodałem ignorowanie znaków specjalnych podczas wyszukiwania pieśni

## 4.04.2024
- założyłem projekt w Firebase i podpiąłem aplikację
- utworzyłem bazę danych w Firebase i zacząłem się dokształcać

## 5.04.2024
- narazie zawiesiłem prace nad integracją z Firebase, postanowiłem wypuścić pierwszą wersję aplikacji działającą zupełnie offline
- zacząłem wdrażać get_it i watch_it dla późniejszej wygody

## 6.04.2024
- dokończyłem migrację na get_it+watch_it

## 7.04.2024
- dodałem stronę list użytkownika z przyciskiem do tworzenia list

## 8.04.2024
- kombinowałem nieco z repozytorium list użytkownika, prace w toku

## 9.04.2024
- próbowałem z listami coś podziałać, ale muszę najpierw więcej poczytać o zarządzaniu stanem

## 10.04.2024
- dokształcałem się z Fluttera przez podcasty

## 11.04.2024
- dodałem podstawową listę list użytkownika
- lista jest przewijalna
- można zmieniać kolejność list na liście

## 12.04.2024
- naprawiłem buga związanego z niewyświetlaniem się nowo utworzonej listy na widoku list
- plan na jutro: walidacja list, usuwanie list

## 13.04.2024
- dodałem klasę-kontener na listy użytkownika
- nowa klasa waliduje, czy nazwy list się nie powtarzają
- pozostaje nauczyć repozytorium i widgety z niej korzystać

## 14.04.2024
- dodałem więcej testów, wykrywając masę błędów i poprawiając je

## 15.04.2024
- dodałem więcej metod do listy list użytkownika
- refaktoring

## 16.04.2024
- nauczyłem repozytorium list użytkownika operować na nowych modelach
- użyłem nowych modeli i repo w widgetach

## 17.04.2024
- zaktualizowałem strukturę projektu

## 18.04.2024
- poczytałem o SQLite
- zacząłem planować migrację z SharedPreferences do SQLite

## 19.04.2024
- zmigrowałem pieśni do SQLa
- przygotowałem podwaliny pod migrację z SharedPreferences do SQLite
