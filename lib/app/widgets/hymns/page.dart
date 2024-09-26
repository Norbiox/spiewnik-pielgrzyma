import 'package:flutter/material.dart';
import 'package:rate_limiter/rate_limiter.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingStatefulWidget {
  const HymnsListPage({super.key});

  @override
  State<HymnsListPage> createState() => _HymnsListPageState();
}

class _HymnsListPageState extends State<HymnsListPage> {
  TextEditingController searchController = TextEditingController();
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();

  String searchText = "";

  void updateSearchText(String text) {
    setState(() {
      searchText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    watch(provider);

    final debouncedSearch =
        debounce(updateSearchText, const Duration(milliseconds: 500));

    return Scaffold(
      body: Column(children: [
        FutureBuilder(
            future: provider.searchHymns(provider.getAll(), searchText),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                final hymns = snapshot.data;
                if (hymns!.isEmpty) {
                  return const Text("Nic nie znaleziono");
                }
                return Expanded(child: HymnsListWidget(hymnsList: hymns));
              }
            }),
        Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: TextField(
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onEditingComplete: () =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                controller: searchController,
                onChanged: (value) => debouncedSearch([value]),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    labelText: 'Szukaj',
                    hintText: 'Wpisz numer, fragment tytułu lub tekstu pieśni',
                    suffixIcon: IconButton(
                        onPressed: () {
                          updateSearchText("");
                          searchController.clear();
                        },
                        icon: const Icon(Icons.clear))))),
      ]),
    );
  }
}
