import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_picker/file_picker.dart';
import 'package:jupiter/storage.dart';
import 'package:path_provider/path_provider.dart' as path;

typedef Callback = void Function(bool);
typedef IcsCallback = void Function(Stream<List<int>>);

class LocalFileActions{

  static Future<String> _getTempDirectory()async{
    if (kIsWeb) return '';
    return (await path.getTemporaryDirectory()).path;
  }

  static Future<String?> _getDownloadsFolder()async{
    if (kIsWeb) return null;
    return (await path.getDownloadsDirectory())?.path;
  }

  static Future<String?> openFilePicker(String dialogTitle)async{
    if (kIsWeb) return null;
    final result = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      initialDirectory: await _getDownloadsFolder(),
      type: FileType.custom,
      allowedExtensions: ['ics', 'ICS'],
    );
    return result?.path;
  }

  static Future<String> cloneFileToTemp(String path, String filename)async{
    if (kIsWeb) return '';
    final file = File(path);
    final fileBytes = await file.readAsBytes();
    final clone = File('${await _getTempDirectory()}/$filename');
    if(await clone.exists()){
      await clone.delete(recursive: false);
    }
    await clone.create(recursive: true);
    await clone.writeAsBytes(fileBytes, flush: true);
    return clone.path;
  }

  /// Deletes cached PDFs, installers and the calendar copy (logout).
  static Future<void> clearTempFiles() async {
    if (kIsWeb) return;
    try {
      final dir = Directory(await _getTempDirectory());
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final lower = entity.path.toLowerCase();
        if (lower.endsWith('.pdf') || lower.endsWith('.apk') || lower.endsWith(IcsImportHelper.ICSFILENAME.toLowerCase())) {
          try { await entity.delete(); } catch (_) {}
        }
      }
    } catch (_) {}
  }

  static Future<Stream<List<int>>?> openFileReadStream(String path)async{
    if (kIsWeb) return null;
    final file = File(path);
    if(!await file.exists()){
      return null;
    }
    final stream = file.openRead();
    return stream;
  }
}

class IcsImportHelper{
  static const String ICSFILENAME = 'OfflineUserCalendar.ics';

  static void onCalendarUploadAction(Callback onResult){
    try{
      Future.delayed(Duration.zero, ()async{
        final path = await LocalFileActions.openFilePicker('');
        if(path == null || path.isEmpty){
          onResult(false);
          return;
        }
        final clonePath = await LocalFileActions.cloneFileToTemp(path, IcsImportHelper.ICSFILENAME);
        await DataCache.setICSFileLocation(clonePath);
        await DataCache.setHasICSFile(true);
        onResult(true);
      });
    }
    catch (_){
      onResult(false);
    }
  }

  static Future<bool> streamIcsFileContent(IcsCallback fileStream)async{
    final result = await LocalFileActions.openFileReadStream(DataCache.getICSFileLocation() ?? '');
    if(result == null){
      return false;
    }
    fileStream(result);
    return true;
  }
}