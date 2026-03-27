import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSearchChanged;
  final String hintText;

  const SearchAppBar({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Szukaj',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearchChanged('');
    setState(() => _isSearching = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closeSearch();
        }
      },
      child: AppBar(
        forceMaterialTransparency: true,
        titleSpacing: 12,
        title: GestureDetector(
          onTap: _isSearching ? null : _openSearch,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: _onSearchChanged,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(
                          widget.hintText,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                ),
                if (_isSearching)
                  GestureDetector(
                    onTap: _closeSearch,
                    child: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
