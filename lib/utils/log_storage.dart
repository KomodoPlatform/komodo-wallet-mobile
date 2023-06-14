import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class LogStorage {
  final dateFormat = DateFormat('yyyy-MM-dd');
  IOSink _logFileSink;
  File _currentFile;

  String logFolderPath() {
    if (applicationDocumentsDirectorySync == null)
      throw Exception(
        'Application documents directory is null. '
        'It must be initialized before calling logFolderPath()',
      );

    // Ideally we would put the logs in their own folder, but this is left as
    // is for now for backwards compatibility. There likely won't be any
    // backwards compatibility issues, but there may be if there are any parts
    // of the app that rely on the logs being in original location.
    return applicationDocumentsDirectorySync.path;
  }

// Function to get log file path
  String getLogFilePath(DateTime date) {
    var filename = dateFormat.format(date) + '.log';
    return '${logFolderPath()}/$filename';
  }

  Future<File> getLogFile(DateTime date) async {
    return File(getLogFilePath(date));
  }

// Function to append string to log file
  Future<void> appendLog(DateTime date, String text) async {
    if (text == null || date == null) return;

    if (!text.endsWith('\n')) text += '\n';

    final file = await getLogFile(date);

    if (_currentFile?.path != file.path) {
      await closeLogFile();
      _logFileSink = file.openWrite(mode: FileMode.append);
      _currentFile = file;
    }

    _logFileSink.write(text);
  }

  Future<void> closeLogFile() async {
    await _logFileSink?.flush();
    await _logFileSink?.close();
    _logFileSink = null;
    _currentFile = null;
  }

  // Export all logs to a g.zip file, split up into 24MB files.
  Future<List<File>> exportLogs() async {
    await deleteExportedArchives();

    final logFiles = Directory(logFolderPath())
        .listSync(followLinks: false, recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList();

    final compressedFiles = <File>[];
    final compressedSizes = <int>[];

    Archive archive = Archive();
    const compressionLevel = Deflate.DEFAULT_COMPRESSION;
    const maxSizeBytes = 24 * 1000 * 1000; // 24MB. Discord limit is 25MB.

    for (var logFile in logFiles) {
      List<int> fileBytes = logFile.readAsBytesSync();
      final fileName = p.basename(logFile.path);

      final logArchive = ArchiveFile(fileName, fileBytes.length, fileBytes);

      archive.addFile(logArchive);

      final compressedBytes =
          GZipEncoder().encode(fileBytes, level: compressionLevel);

      if (compressedBytes.length > maxSizeBytes) {
        throw Exception('Log file ${logFile.path} is larger than 24MB');
      }

      // If archive size of the current + next file is > 24MB, export the
      // current archive and start a new one.
      final wouldBeOverLimit = compressedSizes.fold<int>(0, (a, b) => a + b) +
              compressedBytes.length >
          maxSizeBytes;

      compressedSizes.add(compressedBytes.length);

      final isLastFile = logFile == logFiles.last;

      if (wouldBeOverLimit || isLastFile) {
        final archiveFile = File(
          '${logFolderPath()}/komodo_wallet_logs_archive_${compressedFiles.length}.g.zip',
        );

        final archiveBytes =
            ZipEncoder().encode(archive, level: compressionLevel);
        final gzipBytes =
            GZipEncoder().encode(archiveBytes, level: compressionLevel);

        final savedFile =
            await archiveFile.writeAsBytes(gzipBytes, flush: true);

        compressedFiles.add(savedFile);

        archive = Archive();
      }
    }
    return compressedFiles;
  }

  Future<void> deleteExportedArchives() async {
    final archives = Directory(logFolderPath())
        .listSync(followLinks: false, recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.g.zip'))
        .toList();

    for (var archive in archives) {
      await archive.delete();
    }
  }
}
