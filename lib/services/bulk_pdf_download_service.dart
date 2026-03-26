import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymn_pdf.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

enum DownloadState { idle, downloading, paused, completed }

class _AppLifecycleObserver with WidgetsBindingObserver {
  final BulkPdfDownloadService _service;

  _AppLifecycleObserver(this._service);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _service._onAppLifecycleStateChanged(state);
  }
}

class BulkPdfDownloadService with ChangeNotifier {
  final SharedPreferences prefs;
  final List<Hymn> hymns;
  final HymnPdfProvider pdfProvider;
  final Connectivity _connectivity = Connectivity();

  DownloadState _downloadState = DownloadState.idle;
  int _currentHymnIndex = 0;
  int _successfulDownloads = 0;
  int _currentRetryCount = 0;
  List<int> _failedHymnIds = [];
  StreamSubscription? _connectivitySubscription;
  bool _isWaitingForConnectivity = false;
  late _AppLifecycleObserver _lifecycleObserver;

  static const int maxRetries = 3;

  // Keys for SharedPreferences
  static const String _stateKey = 'bulkDownload:state';
  static const String _lastIndexKey = 'bulkDownload:lastDownloadedIndex';
  static const String _failedHymnsKey = 'bulkDownload:failedHymns';
  static const String _successfulDownloadsKey =
      'bulkDownload:successfulDownloads';
  static const String _currentRetryCountKey = 'bulkDownload:currentRetryCount';

  BulkPdfDownloadService(
    this.prefs,
    this.hymns,
    this.pdfProvider,
  );

  // Getters
  DownloadState get downloadState => _downloadState;
  int get totalHymns => hymns.length;
  // Display progress as "X z Y" where X is current position (1-based)
  int get downloadedCount => _currentHymnIndex + 1;
  int get successfulDownloads => _successfulDownloads;
  int get currentHymnIndex => _currentHymnIndex;
  List<int> get failedHymnIds => _failedHymnIds;
  bool get isWaitingForConnectivity => _isWaitingForConnectivity;

  Future<void> initialize() async {
    await _loadProgress();
    _setupConnectivityListener();
    _lifecycleObserver = _AppLifecycleObserver(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // If download was in progress, automatically resume if online
    if (_downloadState == DownloadState.downloading) {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        _isWaitingForConnectivity = true;
        debugPrint('No internet connection. Waiting for connectivity...');
      } else {
        // Don't await - run download in background to avoid blocking initialization
        _resumeDownload();
      }
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (_isWaitingForConnectivity &&
          !result.contains(ConnectivityResult.none)) {
        _isWaitingForConnectivity = false;
        debugPrint('Internet connection restored. Resuming downloads...');
        // Don't await - run download in background
        _resumeDownload();
      } else if (result.contains(ConnectivityResult.none) &&
          _downloadState == DownloadState.downloading) {
        _isWaitingForConnectivity = true;
        debugPrint('Internet connection lost. Pausing downloads...');
        notifyListeners();
      }
    });
  }

  void _onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isWaitingForConnectivity &&
          _downloadState == DownloadState.downloading) {
        debugPrint('App resumed. Checking connectivity...');
        _connectivity.checkConnectivity().then((result) {
          if (!result.contains(ConnectivityResult.none)) {
            debugPrint(
                'App resumed with internet available. Resuming downloads...');
            _isWaitingForConnectivity = false;
            _resumeDownload();
          }
        });
      }
    }
  }

  Future<void> startDownload() async {
    _downloadState = DownloadState.downloading;
    _currentHymnIndex = 0;
    _successfulDownloads = 0;
    _currentRetryCount = 0;
    _failedHymnIds = [];
    await _saveProgress();
    notifyListeners();

    await _downloadNextHymn();
  }

  Future<void> pauseDownload() async {
    if (_downloadState == DownloadState.downloading) {
      _downloadState = DownloadState.paused;
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> resumeDownload() async {
    if (_downloadState == DownloadState.paused ||
        (_downloadState == DownloadState.downloading &&
            _isWaitingForConnectivity)) {
      _isWaitingForConnectivity = false;
      _downloadState = DownloadState.downloading;
      await _saveProgress();
      notifyListeners();
      await _downloadNextHymn();
    }
  }

  Future<void> _resumeDownload() async {
    if (_downloadState == DownloadState.paused ||
        _downloadState == DownloadState.downloading) {
      _downloadState = DownloadState.downloading;
      await _saveProgress();
      notifyListeners();
      await _downloadNextHymn();
    }
  }

  Future<void> _downloadNextHymn() async {
    while (_currentHymnIndex < hymns.length) {
      // Check if download was paused
      if (_downloadState == DownloadState.paused) {
        await _saveProgress();
        return;
      }

      // Check if waiting for connectivity
      if (_isWaitingForConnectivity ||
          _downloadState != DownloadState.downloading) {
        await _saveProgress();
        return;
      }

      final hymn = hymns[_currentHymnIndex];

      try {
        debugPrint(
            'Downloading PDF for hymn ${hymn.number} (attempt ${_currentRetryCount + 1}/$maxRetries)...');
        await pdfProvider.getHymnPdfFile(hymn);

        // Success
        _successfulDownloads++;
        _currentRetryCount = 0;
        debugPrint('Successfully downloaded hymn ${hymn.number}');

        // Move to next hymn
        _currentHymnIndex++;
        await _saveProgress();
        notifyListeners();
      } catch (e) {
        final isNetworkError = _isNetworkError(e);

        if (isNetworkError) {
          // Network error - pause and wait for connectivity
          debugPrint(
              'Network error downloading hymn ${hymn.number}: $e. Pausing...');
          _isWaitingForConnectivity = true;
          await _saveProgress();
          notifyListeners();
          return; // Exit loop to wait for connectivity
        } else {
          // Non-network error - retry up to maxRetries times
          _currentRetryCount++;

          if (_currentRetryCount >= maxRetries) {
            // Failed after all retries - skip this hymn
            debugPrint(
                'Failed to download hymn ${hymn.number} after $maxRetries attempts: $e');
            _failedHymnIds.add(hymn.id);
            _currentRetryCount = 0;

            // Move to next hymn
            _currentHymnIndex++;
            await _saveProgress();
            notifyListeners();
          } else {
            // Retry the same hymn
            debugPrint(
                'Error downloading hymn ${hymn.number}, retrying... ($_currentRetryCount/$maxRetries)');
            await _saveProgress();
            notifyListeners();
          }
        }
      }

      // Small delay between download attempts to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // All downloads completed
    _downloadState = DownloadState.completed;
    await _saveProgress();
    notifyListeners();
    debugPrint(
        'All hymn PDFs processed. Successful: $_successfulDownloads, Failed: ${_failedHymnIds.length}');
  }

  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Check for network-related error messages
    if (errorStr.contains('connection') ||
        errorStr.contains('internet') ||
        errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('unable to reach host')) {
      return true;
    }

    return false;
  }

  Future<bool> areAllHymnsDownloaded() async {
    for (final hymn in hymns) {
      final isDlProvider =
          pdfProvider as DecryptingNetworkHymnPdfProviderWithStorage;
      final pdf = await isDlProvider.hymnPdfStorage.getHymnPdfFile(hymn.number);
      if (pdf == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveProgress() async {
    await prefs.setString(_stateKey, _downloadState.toString());
    await prefs.setInt(_lastIndexKey, _currentHymnIndex);
    await prefs.setStringList(
        _failedHymnsKey, _failedHymnIds.map((id) => id.toString()).toList());
    await prefs.setInt(_successfulDownloadsKey, _successfulDownloads);
    await prefs.setInt(_currentRetryCountKey, _currentRetryCount);
  }

  Future<void> _loadProgress() async {
    final stateStr = prefs.getString(_stateKey);
    if (stateStr != null) {
      _downloadState =
          DownloadState.values.firstWhere((e) => e.toString() == stateStr);
    }
    _currentHymnIndex = prefs.getInt(_lastIndexKey) ?? 0;
    final failedStr = prefs.getStringList(_failedHymnsKey) ?? [];
    _failedHymnIds = failedStr.map((id) => int.parse(id)).toList();
    _successfulDownloads = prefs.getInt(_successfulDownloadsKey) ?? 0;
    _currentRetryCount = prefs.getInt(_currentRetryCountKey) ?? 0;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }
}
