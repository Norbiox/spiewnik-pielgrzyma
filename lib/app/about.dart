import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacje'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // O APLIKACJI
              Text('O aplikacji',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                  'Ponieważ oryginalna aplikacja „Śpiewnik Pielgrzyma" stworzona przez Kajetana Suchańskiego została przez zespół Google usunięta ze sklepu Play, podjąłem się wykonania nowej aplikacji na urządzenia mobilne o podobnych funkcjonalnościach.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                  'Podobnie jak w poprzedniej wersji, znajdziemy tu listę 875 pieśni z oryginalnego „Śpiewnika Pielgrzyma" wydawnictwa „Łaska i Pokój", wraz z ich tekstami.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                  'Pełna lista funkcjonalności dostępnych w aplikacji jak i tych w planach znajduje się niżej, w sekcji „Funkcjonalności”.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              // O WYDAWNICTWIE
              Text('Wydawnictwo „Łaska i Pokój"',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                  'Kierujemy szczególne wyrazy wdzięczności dla wydawnictwa „Łaska i Pokój” za udostępnienie skanów pieśni z oryginalnego śpiewnika z nutami, co czyni aplikację jeszcze bardziej przydatną dla usługujących na instrumentach muzycznych.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                  'Wydawnictwo prowadzone przez Kościół Wolnych Chrześcijan w RP już od 1925 roku wydaje czasopismo o tej samej nazwie, jak również książki i audiobooki chrześcijańskie.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Linkify(
                onOpen: _launchUrl,
                text:
                    'Serdecznie zapraszamy na stronę wydawnictwa https://kwch.org/wydawnictwo/ oraz do internetowego sklepu https://kwch.org/shop/',
                style: Theme.of(context).textTheme.bodyMedium,
                linkStyle: const TextStyle(color: Colors.blue),
                options: const LinkifyOptions(humanize: false),
              ),
              const SizedBox(height: 32),
              // Funkcjonalności
              Text('Funkcjonalności',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                  '- możliwość przeglądania pieśni i ich tekstów, także w trybie offline',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                  '- inteligentna wyszukiwarka pieśni pozwalająca szukać po numerach, fragmentach tytułów oraz tekstu pieśni',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                  '- (w trybie online) dostęp do skanów pieśni ze śpiewnika z nutami i akordami',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('- możliwość oznaczania pieśni jako ulubionych',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('- opcja tworzenia własnych, niestandardowych list pieśni',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              // POLITYKA PRYWATNOŚCI
              Text('Polityka prywatności',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                  'Aplikacja nie zbiera żadnych danych osobowych użytkowników.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                  'Twórca aplikacji zastrzega sobie prawo do zbierania anonimowych danych dotyczących użytkowania aplikacji w celach statystycznych. Dane te nie są udostępniane żadnym podmiotom trzecim i są anonimowe.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Linkify(
                onOpen: _launchUrl,
                text:
                    'Pełną politykę prywatności można znaleźć pod adresem https://norbiox.github.io/spiewnik-pielgrzyma/polityka_prywatnosci/',
                style: Theme.of(context).textTheme.bodyMedium,
                linkStyle: const TextStyle(color: Colors.blue),
                options: const LinkifyOptions(humanize: false),
              ),
              const SizedBox(height: 32),
              // KONTAKT
              Text('Kontakt', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SelectableLinkify(
                onOpen: _launchUrl,
                text:
                    'W przypadku pytań, uwag czy sugestii dotyczących aplikacji, prosimy o kontakt na adres email: norbertchmiel.it@gmail.com',
                style: Theme.of(context).textTheme.bodyMedium,
                linkStyle: const TextStyle(color: Colors.blue),
                options: const LinkifyOptions(humanize: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Nie można otworzyć linku ${link.url}');
    }
  }
}
