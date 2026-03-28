import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/favorites/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/shared/search_app_bar.dart';
import 'package:watch_it/watch_it.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;
  const BottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final List<String> _searchQueries = ['', '', ''];

  static const _hintTexts = ['Szukaj', 'Szukaj', 'Szukaj listy'];

  final GlobalKey<SearchAppBarState> _searchAppBarKey =
      GlobalKey<SearchAppBarState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _searchAppBarKey.currentState?.collapseSearch();
    setState(() => _currentIndex = index);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQueries[_currentIndex] = query);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _onTabTapped(0);
          }
        },
        child: Scaffold(
          appBar: SearchAppBar(
            key: _searchAppBarKey,
            onSearchChanged: _onSearchChanged,
            hintText: _hintTexts[_currentIndex],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _KeepAlivePage(
                  child: HymnsListPage(searchQuery: _searchQueries[0])),
              _KeepAlivePage(
                  child: FavoritesPage(searchQuery: _searchQueries[1])),
              _KeepAlivePage(
                  child: CustomListsPage(searchQuery: _searchQueries[2])),
            ],
          ),
          floatingActionButton: _currentIndex == 2
              ? FloatingActionButton(
                  onPressed: () async {
                    var newListName = await _showCreateListDialog(context);
                    if (newListName != null) {
                      GetIt.I<CustomListProvider>().createNewList(newListName);
                    }
                  },
                  tooltip: "Dodaj nową listę",
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note_outlined),
                activeIcon: Icon(Icons.music_note),
                label: 'Lista pieśni',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Ulubione',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_outlined),
                activeIcon: Icon(Icons.list),
                label: 'Twoje listy',
              ),
            ],
          ),
        ));
  }

  Future<String?> _showCreateListDialog(BuildContext context) async {
    final textFieldController =
        TextEditingController(text: DateTime.now().toString().split(".").first);

    return showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Nazwij nową listę"),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "Nazwa listy"),
                autofocus: true,
              ),
              actions: <Widget>[
                FilledButton.tonal(
                    child: const Text("Anuluj"),
                    onPressed: () => Navigator.pop(context)),
                FilledButton(
                    child: const Text("Zatwierdź"),
                    onPressed: () =>
                        Navigator.pop(context, textFieldController.text)),
              ]);
        });
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
