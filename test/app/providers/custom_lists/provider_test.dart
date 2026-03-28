import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';

void main() {
  late SharedPreferences prefs;
  late CustomListProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    provider = CustomListProvider(prefs);
  });

  test('archiveList moves list to archived and notifies', () {
    provider.createNewList('Test List');
    final list = provider.getLists().first;

    var notified = false;
    provider.addListener(() => notified = true);

    provider.archiveList(list);

    expect(provider.getLists(), isEmpty);
    expect(provider.getArchivedLists().length, 1);
    expect(provider.getArchivedLists().first.name, 'Test List');
    expect(notified, isTrue);
  });

  test('restoreList moves list back to active at front and notifies', () {
    provider.createNewList('First');
    provider.createNewList('Second');
    final second = provider.getLists().first; // 'Second' is at front

    provider.archiveList(second);

    var notified = false;
    provider.addListener(() => notified = true);

    final archived = provider.getArchivedLists().first;
    provider.restoreList(archived);

    final lists = provider.getLists();
    expect(lists.length, 2);
    expect(lists[0].name, 'Second');
    expect(lists[1].name, 'First');
    expect(provider.getArchivedLists(), isEmpty);
    expect(notified, isTrue);
  });

  test('getArchivedLists returns empty when none archived', () {
    expect(provider.getArchivedLists(), isEmpty);
  });
}
