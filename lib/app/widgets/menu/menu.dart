import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String item) {
        context.go(item);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: "/settings",
          child: ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Ustawienia')),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: "/about",
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informacje'),
          ),
        ),
      ],
    );
  }
}
