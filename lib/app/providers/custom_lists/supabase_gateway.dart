import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/infra/supabase.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _table = 'shared_lists';

class SupabaseSharedListGateway implements SharedListGateway {
  CustomList _fromRow(Map<String, dynamic> row) {
    final currentUserId = supabase.auth.currentUser?.id;
    return CustomList(
      row['id'] as String,
      row['name'] as String,
      hymnsIds: (row['hymns_ids'] as List).cast<int>(),
      archivedHymnsIds: (row['archived_hymns_ids'] as List).cast<int>(),
      shareToken: row['share_token'] as String?,
      isOwner: row['owner_id'] == currentUserId,
      version: row['version'] as int,
    );
  }

  @override
  Future<CustomList?> fetch(String id) async {
    final rows = await supabase.from(_table).select().eq('id', id);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<CustomList>> fetchAll(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await supabase.from(_table).select().inFilter('id', ids);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<CustomList> create(CustomList list) async {
    final userId = await ensureSignedIn();
    // Deliberately not `.insert(...).select().single()`. Under RLS, an INSERT
    // with RETURNING also has to pass the SELECT policy for the new row, and
    // shared_lists_select depends on is_list_participant() — a security
    // definer function running its own SELECT against shared_lists. That
    // inner SELECT does not reliably see a row inserted earlier in the same
    // statement, so the RETURNING clause fails with "new row violates
    // row-level security policy" even though owner_id matches auth.uid().
    // A plain insert followed by a separate select (new statement, row
    // already committed) sidesteps it.
    await supabase.from(_table).insert({
      'id': list.id,
      'owner_id': userId,
      'name': list.name,
      'hymns_ids': list.hymnsIds,
      'archived_hymns_ids': list.archivedHymnsIds,
    });
    final row = await supabase.from(_table).select().eq('id', list.id).single();
    return _fromRow(row);
  }

  @override
  Future<int?> update(CustomList list) async {
    final rows = await supabase
        .from(_table)
        .update({
          'name': list.name,
          'hymns_ids': list.hymnsIds,
          'archived_hymns_ids': list.archivedHymnsIds,
          'version': list.version + 1,
        })
        .eq('id', list.id)
        .eq('version', list.version)
        .select('version');
    if (rows.isEmpty) return null;
    return rows.first['version'] as int;
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from(_table).delete().eq('id', id);
  }

  @override
  Future<void> leave(String id) async {
    final userId = await ensureSignedIn();
    await supabase
        .from('shared_list_members')
        .delete()
        .eq('list_id', id)
        .eq('user_id', userId);
  }

  @override
  Future<SharedListPreview?> preview(String token) async {
    await ensureSignedIn();
    final rows = await supabase
        .rpc('preview_shared_list', params: {'p_token': token}) as List;
    if (rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;
    return SharedListPreview(
      row['id'] as String,
      row['name'] as String,
      row['hymns_count'] as int,
    );
  }

  @override
  Future<String> join(String token) async {
    await ensureSignedIn();
    final id =
        await supabase.rpc('join_shared_list', params: {'p_token': token});
    return id as String;
  }

  @override
  SharedListSubscription subscribe(
    String id, {
    required void Function(CustomList) onChange,
    required void Function() onDelete,
  }) {
    final channel = supabase.channel('shared_list:$id')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: _table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: id,
        ),
        callback: (payload) => onChange(_fromRow(payload.newRecord)),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: _table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: id,
        ),
        callback: (_) => onDelete(),
      );
    channel.subscribe();
    return _ChannelSubscription(channel);
  }
}

class _ChannelSubscription implements SharedListSubscription {
  final RealtimeChannel _channel;

  _ChannelSubscription(this._channel);

  @override
  Future<void> close() => supabase.removeChannel(_channel);
}
