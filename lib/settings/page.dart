import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/services/bulk_pdf_download_service.dart';
import 'package:spiewnik_pielgrzyma/settings/theme.dart';
import 'package:watch_it/watch_it.dart';

class SettingsPage extends WatchingWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Theme settings section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Wygląd',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const _ThemeSettingsTile(),
          const Divider(),
          // Bulk PDF download section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pobieranie nut',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const _BulkPdfDownloadSection(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Informacje'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}

class _ThemeSettingsTile extends WatchingWidget {
  const _ThemeSettingsTile();

  @override
  Widget build(BuildContext context) {
    final themeProvider = GetIt.I<ThemeProvider>();
    watch(themeProvider);

    return ListTile(
      title: const Text('Motyw'),
      subtitle: Text(_getThemeModeLabel(themeProvider.themeMode)),
      trailing: Icon(themeProvider.themeMode == ThemeMode.light
          ? Icons.light_mode
          : Icons.dark_mode),
      onTap: () => themeProvider.toggleMode(),
    );
  }

  String _getThemeModeLabel(ThemeMode? mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Jasny';
      case ThemeMode.dark:
        return 'Ciemny';
      default:
        return 'Systemowy';
    }
  }
}

class _BulkPdfDownloadSection extends WatchingWidget {
  const _BulkPdfDownloadSection();

  @override
  Widget build(BuildContext context) {
    final downloadService = GetIt.I<BulkPdfDownloadService>();
    watch(downloadService);

    return FutureBuilder<bool>(
      future: downloadService.areAllHymnsDownloaded(),
      builder: (context, snapshot) {
        final allDownloaded = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              if (downloadService.downloadState == DownloadState.idle &&
                  !allDownloaded)
                _DownloadButton(
                  onPressed: () =>
                      _showConfirmationDialog(context, downloadService),
                ),
              if (downloadService.downloadState == DownloadState.downloading)
                _DownloadProgressSection(downloadService),
              if (downloadService.downloadState == DownloadState.paused)
                _PausedDownloadSection(downloadService),
              if (allDownloaded) _AllDownloadedIndicator(),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, BulkPdfDownloadService downloadService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text(
          'To spowoduje pobranie nut wszystkich pieśni. Czy jesteś pewien, że chcesz kontynuować?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              downloadService.startDownload();
            },
            child: const Text('Tak'),
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DownloadButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.download),
        label: const Text('Pobierz wszystkie nuty'),
      ),
    );
  }
}

class _DownloadProgressSection extends StatelessWidget {
  final BulkPdfDownloadService downloadService;

  const _DownloadProgressSection(this.downloadService);

  @override
  Widget build(BuildContext context) {
    final progress =
        downloadService.downloadedCount / downloadService.totalHymns;

    return Column(
      children: [
        Text(
          '${downloadService.downloadedCount} z ${downloadService.totalHymns} pobranych',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
          ),
        ),
        if (downloadService.isWaitingForConnectivity)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Oczekiwanie na połączenie internetowe...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.amber,
                  ),
            ),
          ),
        const SizedBox(height: 12),
        if (!downloadService.isWaitingForConnectivity)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => downloadService.pauseDownload(),
              icon: const Icon(Icons.pause),
              label: const Text('Wstrzymaj'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => downloadService.resumeDownload(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Wznów'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
          ),
      ],
    );
  }
}

class _PausedDownloadSection extends StatelessWidget {
  final BulkPdfDownloadService downloadService;

  const _PausedDownloadSection(this.downloadService);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${downloadService.downloadedCount} z ${downloadService.totalHymns} pobranych',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: downloadService.downloadedCount / downloadService.totalHymns,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pobieranie wstrzymane',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => downloadService.resumeDownload(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Wznów'),
          ),
        ),
      ],
    );
  }
}

class _AllDownloadedIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Wszystkie nuty zostały pobrane!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
