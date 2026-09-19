import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';

/// Landing screen for an invite link. Previews the list, asks, then joins.
class JoinListPage extends StatefulWidget {
  final String token;

  const JoinListPage({super.key, required this.token});

  @override
  State<JoinListPage> createState() => _JoinListPageState();
}

class _JoinListPageState extends State<JoinListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final gateway = GetIt.I<SharedListGateway>();
    final provider = GetIt.I<CustomListProvider>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    SharedListPreview? preview;
    try {
      preview = await gateway.preview(widget.token);
    } catch (_) {
      preview = null;
    }

    if (!mounted) return;

    if (preview == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ta lista już nie istnieje')),
      );
      router.go('/custom-lists');
      return;
    }

    // Already have it? Skip the dialog and just open it.
    final known = provider.getLists().where((l) => l.id == preview!.id);
    if (known.isNotEmpty) {
      router.go('/custom-lists/${preview.id}');
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content:
            Text('Czy chcesz dodać udostępnioną ci listę „${preview!.name}”?\n'
                'Pieśni: ${preview.hymnsCount}'),
        actions: [
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tak'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (accepted != true) {
      router.go('/custom-lists');
      return;
    }

    try {
      final id = await gateway.join(widget.token);
      final joined = await gateway.fetch(id);
      if (joined == null) throw Exception('list_not_found');
      joined.shareToken = widget.token;
      provider.applyRemote(joined);
      if (!mounted) return;
      router.go('/custom-lists/$id');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nie udało się dodać listy')),
      );
      router.go('/custom-lists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
