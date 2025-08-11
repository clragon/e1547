import 'dart:io';

import 'package:e1547/app/data/initialize.dart';
import 'package:e1547/app/widget/initialize.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef DatabaseInfo = ({String name, String size});

final _logger = Logger('DbManagement');

class DatabaseManagementPage extends StatelessWidget {
  const DatabaseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TransparentAppBar(
        child: DefaultAppBar(leading: CloseButton()),
      ),
      body: LimitedWidthLayout.builder(
        builder: (context) => ListView(
          padding: defaultActionListPadding.add(
            LimitedWidthLayout.of(context).padding,
          ),
          children: const [
            DatabaseInfoDisplay(),
            SizedBox(height: 64),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                child: Column(
                  children: [DatabaseExportTile(), DatabaseImportTile()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseInfoDisplay extends StatelessWidget {
  const DatabaseInfoDisplay({super.key});

  Future<DatabaseInfo> _loadDatabaseInfo() async {
    final dbPath = await getAppDatabasePath();
    final dbFile = File(dbPath);

    final name = dbPath.split(Platform.pathSeparator).last;
    final size = dbFile.existsSync()
        ? filesize(dbFile.lengthSync())
        : 'Unknown';

    return (name: name, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return SubFuture<DatabaseInfo>(
      create: _loadDatabaseInfo,
      builder: (context, snapshot) {
        final dbInfo =
            snapshot.data ??
            (snapshot.error != null
                ? (name: 'Error loading database', size: 'N/A')
                : (name: 'Loading...', size: '...'));

        return Center(
          child: Column(
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                radius: 64,
                child: const Icon(Icons.storage, size: 64),
              ),
              const SizedBox(height: 16),
              Text(dbInfo.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Dimmed(
                child: Text(
                  dbInfo.size,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class DatabaseExportTile extends StatelessWidget {
  const DatabaseExportTile({super.key});

  Future<void> _exportDatabase(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4),
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Exporting database...'),
              ),
            ],
          ),
        ),
      );

      final dbPath = await getAppDatabasePath();
      final dbFile = File(dbPath);
      if (!dbFile.existsSync()) {
        throw Exception('Database file does not exist');
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Database',
        fileName: 'e1547_database_backup.db',
        type: FileType.custom,
        allowedExtensions: ['db'],
        bytes: await dbFile.readAsBytes(),
      );

      navigator.pop();
      if (outputFile != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Database exported successfully')),
        );
      }
    } on Exception catch (e) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Export failed')));
      _logger.severe('Database export failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_download),
      title: const Text('Export'),
      subtitle: const Text(
        'Save a backup copy of your database',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _exportDatabase(context),
    );
  }
}

class DatabaseImportTile extends StatelessWidget {
  const DatabaseImportTile({super.key});

  Future<void> _importDatabase(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await _showImportWarning(context);
    if (!confirmed) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Database',
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result?.files.single.path == null) return;
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4),
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Importing database...'),
              ),
            ],
          ),
        ),
      );

      final importFile = File(result!.files.single.path!);
      final dbPath = await getAppDatabasePath();
      final newDbPath = '$dbPath.new';
      await importFile.copy(newDbPath);

      navigator.pop();
      if (context.mounted) {
        await _showRestartDialog(context);
      }
    } on Exception catch (e) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<bool> _showImportWarning(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AlertDialog(
          title: const Text('Import Database'),
          content: const Text(
            'This will replace your current database. \n'
            'All data will be lost. This cannot be undone!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    ),
  ).then((value) => value ?? false);

  Future<void> _showRestartDialog(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Restart Required'),
      content: const Text('The app needs to restart to apply changes.'),
      actions: [
        TextButton(
          onPressed: () => AppInit.of(context).reinitialize(),
          child: const Text('Restart Now'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_upload),
      title: const Text('Import'),
      subtitle: const Text(
        'Replace current database with imported one',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _importDatabase(context),
    );
  }
}
