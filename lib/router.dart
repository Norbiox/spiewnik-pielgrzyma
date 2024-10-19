import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/about.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/custom_list_page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/home.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymn_page.dart';
import 'package:spiewnik_pielgrzyma/settings/page.dart';

final GoRouter router = GoRouter(initialLocation: '/', routes: <RouteBase>[
  GoRoute(
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const MyHomePage(initialIndex: 0),
      routes: <RouteBase>[
        GoRoute(
            path: 'hymn/:id',
            builder: (BuildContext context, GoRouterState state) =>
                HymnPage(hymnId: int.parse(state.pathParameters['id']!))),
        GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsPage()),
        GoRoute(
            path: 'about',
            builder: (BuildContext context, GoRouterState state) =>
                const AboutPage()),
      ]),
  GoRoute(
      path: '/favorites',
      builder: (BuildContext context, GoRouterState state) =>
          const MyHomePage(initialIndex: 1),
      routes: <RouteBase>[
        GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) =>
                HymnPage(hymnId: int.parse(state.pathParameters['id']!)))
      ]),
  GoRoute(
      path: '/custom-lists',
      builder: (BuildContext context, GoRouterState state) =>
          const MyHomePage(initialIndex: 2),
      routes: <RouteBase>[
        GoRoute(
            path: '/:id',
            builder: (BuildContext context, GoRouterState state) =>
                CustomListPage(listId: state.pathParameters['id']!))
      ]),
]);
