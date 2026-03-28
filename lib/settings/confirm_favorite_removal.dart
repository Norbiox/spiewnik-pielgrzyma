import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmFavoriteRemovalProvider extends ChangeNotifier {
  static const _preferenceKey = 'confirmFavoriteRemoval';

  final SharedPreferences _prefs;
  bool _isEnabled;

  ConfirmFavoriteRemovalProvider(this._prefs)
      : _isEnabled = _prefs.getBool(_preferenceKey) ?? true;

  bool get isEnabled => _isEnabled;

  void toggle() {
    _isEnabled = !_isEnabled;
    _prefs.setBool(_preferenceKey, _isEnabled);
    notifyListeners();
  }
}
