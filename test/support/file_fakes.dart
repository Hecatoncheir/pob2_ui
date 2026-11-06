import 'dart:async';
import 'dart:io';

import 'package:pob2_ui/data/atomic_text_file.dart';
import 'package:pob2_ui/data/xml_file_service.dart';

class SelectPaths implements XmlFileDialogs {
  String? openPath;
  String? savePath;
  String? suggestion;
  @override
  Future<String?> open() async => openPath;
  @override
  Future<String?> save(String suggestedName) async {
    suggestion = suggestedName;
    return savePath;
  }
}

class FailingTextFiles extends AtomicTextFile {
  String? failName;
  bool failAll = false;
  Completer<void>? gate;
  @override
  Future<void> write(File target, String text, {bool backup = false}) async {
    await gate?.future;
    if (failAll || target.uri.pathSegments.last == failName) {
      throw FileSystemException('Нет места на диске', target.path);
    }
    return super.write(target, text, backup: backup);
  }
}
