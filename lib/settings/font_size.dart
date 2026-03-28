import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  static const _preferenceKey = 'fontSizeScale';
  static const double minScale = 0.7;
  static const double maxScale = 2.0;
  static const double defaultScale = 1.0;

  final SharedPreferences _prefs;
  double _scale;

  FontSizeProvider(this._prefs) : _scale = _loadScale(_prefs);

  static double _loadScale(SharedPreferences prefs) {
    final stored = prefs.getDouble(_preferenceKey) ?? defaultScale;
    return stored.clamp(minScale, maxScale).toDouble();
  }

  double get scale => _scale;

  void setScale(double value) {
    _scale = value.clamp(minScale, maxScale);
    _prefs.setDouble(_preferenceKey, _scale);
    notifyListeners();
  }

  void setScaleVisual(double value) {
    _scale = value.clamp(minScale, maxScale);
    notifyListeners();
  }

  void persistScale() {
    _prefs.setDouble(_preferenceKey, _scale);
  }

  void reset() {
    setScale(defaultScale);
  }

  double scaledFontSize(double baseFontSize) {
    return baseFontSize * _scale;
  }
}
