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
