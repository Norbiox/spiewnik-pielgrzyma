import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes the Supabase client. Makes no network call, so it is safe to
/// run at startup even offline.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );
}

SupabaseClient get supabase => Supabase.instance.client;

/// Returns the current user id, creating an anonymous account on first use.
///
/// Sign-in is deliberately lazy: it happens when a user first shares or joins
/// a list, never at startup, so users who never touch sharing never get an
/// account.
///
/// A cached session is not trusted blindly. The account behind it can be gone —
/// deleted by the dormant-account cleanup, or lost when the refresh token
/// expired — and a stale id would then fail a foreign key check on insert with
/// no useful error. [getUser] costs one round trip on an action that happens
/// rarely, and turns that into a clean re-sign-in.
Future<String> ensureSignedIn() async {
  if (supabase.auth.currentSession != null) {
    try {
      final user = (await supabase.auth.getUser()).user;
      if (user != null) return user.id;
    } on AuthException {
      await supabase.auth.signOut();
    }
  }
  final response = await supabase.auth.signInAnonymously();
  return response.user!.id;
}
