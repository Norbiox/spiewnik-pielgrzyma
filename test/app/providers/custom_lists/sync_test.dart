import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

Hymn hymn(int id) => Hymn(id, '$id', 'Title $id', 'G', 'S', const []);

/// Records calls and lets each test script the responses it needs.
class FakeGateway implements SharedListGateway {
  /// Server-side state, keyed by list id.
  final Map<String, CustomList> rows = {};

  /// Versions that [update] should reject before accepting anything.
  int rejectUpdates = 0;

  /// When true, [update] throws instead of answering.
  bool failNetwork = false;

  /// Lists this user can no longer read, simulating a lost anonymous account.
  final Set<String> notAMember = {};

  int updateCalls = 0;

  @override
  Future<int?> update(CustomList list) async {
    updateCalls++;
    if (failNetwork) throw Exception('offline');
    if (rejectUpdates > 0) {
      rejectUpdates--;
      return null;
    }
    final stored = rows[list.id]!;
    stored.name = list.name;
    stored.hymnsIds = [...list.hymnsIds];
    stored.archivedHymnsIds = [...list.archivedHymnsIds];
    stored.version = stored.version + 1;
    return stored.version;
  }

  @override
  Future<CustomList?> fetch(String id) async =>
      notAMember.contains(id) ? null : rows[id]?.copy();

  @override
  Future<List<CustomList>> fetchAll(List<String> ids) async => ids
      .where((id) => !notAMember.contains(id))
      .map((id) => rows[id])
      .whereType<CustomList>()
      .map((l) => l.copy())
      .toList();

  @override
  Future<CustomList> create(CustomList list) async {
    final stored = list.copy()
      ..shareToken = 'token-${list.id}'
      ..isOwner = true
      ..version = 1;
    rows[list.id] = stored;
    return stored.copy();
  }

  @override
  Future<void> delete(String id) async => rows.remove(id);

  @override
  Future<void> leave(String id) async => rows.remove(id);

  @override
  Future<SharedListPreview?> preview(String token) async => null;

  @override
  Future<String> join(String token) async {
    final match = rows.values.where((l) => l.shareToken == token);
    if (match.isEmpty) throw Exception('list_not_found');
    final row = match.first;
    // A device that lost its account comes back as a member, not the owner.
    row.isOwner = false;
    notAMember.remove(row.id);
    return row.id;
  }

  @override
  SharedListSubscription subscribe(String id,
          {required void Function(CustomList) onChange,
          required void Function() onDelete}) =>
      throw UnimplementedError();
}

void main() {
  late SharedPreferences prefs;
  late FakeGateway gateway;
  late CustomListProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gateway = FakeGateway();
    provider = CustomListProvider(prefs, gateway: gateway);
  });

  /// Creates a list locally and marks it shared, both locally and on the fake
  /// server, without going through the share UI.
  CustomList givenSharedList({List<int> hymnsIds = const []}) {
    final list = CustomList('list-1', 'Pielgrzymka',
        hymnsIds: [...hymnsIds],
        shareToken: 'token-1',
        isOwner: true,
        version: 1);
    provider.save(list);
    gateway.rows['list-1'] = list.copy();
    return list;
  }

  test('a successful push stores the version the server returned', () async {
    final list = givenSharedList(hymnsIds: [1]);

    await provider.addHymn(list, hymn(2));

    expect(gateway.rows['list-1']!.hymnsIds, [1, 2]);
    expect(provider.getList('list-1').version, 2);
    expect(provider.getList('list-1').hymnsIds, [1, 2]);
  });

  test('a version conflict re-applies the intent to fresh state', () async {
    final list = givenSharedList(hymnsIds: [1]);
    // Someone else added hymn 9 and bumped the version.
    gateway.rows['list-1']!
      ..hymnsIds = [1, 9]
      ..version = 5;
    gateway.rejectUpdates = 1;

    await provider.addHymn(list, hymn(2));

    expect(gateway.updateCalls, 2);
    // The other user's hymn survived and ours was added on top of it.
    expect(provider.getList('list-1').hymnsIds, [1, 9, 2]);
  });

  test('a reorder survives a conflict because it is expressed with ids',
      () async {
    final list = givenSharedList(hymnsIds: [1, 2, 3, 4]);
    gateway.rows['list-1']!
      ..hymnsIds = [9, 1, 2, 3, 4]
      ..version = 5;
    gateway.rejectUpdates = 1;

    await provider.moveHymn(list, 4, 2);

    expect(provider.getList('list-1').hymnsIds, [9, 1, 4, 2, 3]);
  });

  test('a network failure rolls the local change back', () async {
    final list = givenSharedList(hymnsIds: [1]);
    gateway.failNetwork = true;

    await expectLater(provider.addHymn(list, hymn(2)), throwsException);

    expect(provider.getList('list-1').hymnsIds, [1]);
  });

  test('pushing to a list the owner deleted removes it locally', () async {
    final list = givenSharedList(hymnsIds: [1]);
    gateway.rejectUpdates = 1;
    gateway.rows.remove('list-1');

    await provider.addHymn(list, hymn(2));

    expect(provider.getLists(), isEmpty);
  });

  test('a private list never touches the gateway', () async {
    provider.createNewList('Prywatna');
    final list = provider.getLists().first;

    await provider.addHymn(list, hymn(1));

    expect(gateway.updateCalls, 0);
    expect(provider.getList(list.id).hymnsIds, [1]);
  });

  test('a list the owner deleted is dropped locally', () async {
    givenSharedList(hymnsIds: [1]);
    gateway.rows.remove('list-1');

    await provider.refreshSharedLists();

    expect(provider.getLists(), isEmpty);
  });

  test('a list gone unreadable is re-joined with the stored token', () async {
    givenSharedList(hymnsIds: [1]);
    // The account behind this device is gone, so RLS hides the row.
    gateway.notAMember.add('list-1');
    gateway.rows['list-1']!.hymnsIds = [1, 5];

    await provider.refreshSharedLists();

    final recovered = provider.getList('list-1');
    expect(recovered.hymnsIds, [1, 5]);
    expect(recovered.shareToken, 'token-1');
    // Edit rights are back; ownership is not.
    expect(recovered.isOwner, isFalse);
  });

  test('a readable list is refreshed from the server', () async {
    givenSharedList(hymnsIds: [1]);
    gateway.rows['list-1']!
      ..hymnsIds = [1, 2]
      ..version = 4;

    await provider.refreshSharedLists();

    expect(provider.getList('list-1').hymnsIds, [1, 2]);
    expect(provider.getList('list-1').version, 4);
  });
}
