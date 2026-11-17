import 'dart:convert';
import 'dart:io' show zlib;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'pob_build_document.dart';

const _xmlLimit = 16 * 1024 * 1024;
const pobShareCodeLimit = ((_xmlLimit + 2) ~/ 3) * 4;
const _invalidCode = FormatException('Некорректный или обрезанный код PoB.');
final _alphabet = RegExp(r'^[A-Za-z0-9_-]+={0,2}$');

Future<String> decodePobShareCode(String code) =>
    Isolate.run(() => _decode(code));

Future<String> encodePobShareCode(String xml) => Isolate.run(() {
  final bytes = utf8.encode(xml);
  if (bytes.length > _xmlLimit) {
    throw const FormatException('XML больше 16 МБ');
  }
  final code = base64Url.encode(zlib.encode(bytes));
  if (code.length > pobShareCodeLimit) {
    throw const FormatException('Код PoB слишком велик.');
  }
  return code;
});

String _decode(String input) {
  final code = input.trim();
  if (code.isEmpty)
    throw const FormatException('В буфере обмена нет кода PoB.');
  if (code.length > pobShareCodeLimit) {
    throw const FormatException('Код PoB слишком велик.');
  }
  if (!_alphabet.hasMatch(code)) throw _invalidCode;

  final xml = _decodeXml(code);
  try {
    PobBuildDocument(xml);
  } on XmlException {
    throw _invalidCode;
  }
  return xml;
}

String _decodeXml(String code) {
  try {
    final compressed = base64Url.decode(base64Url.normalize(code));
    if (compressed.length < 6) throw _invalidCode;

    final bytes = const ZLibDecoder().decodeBytes(
      compressed,
      maxOutputSize: _xmlLimit,
    );
    final checksum = ByteData.sublistView(compressed)
        .getUint32(compressed.length - 4);
    if (getAdler32(bytes) != checksum) throw _invalidCode;
    return utf8.decode(bytes);
  } on ArchiveException {
    throw _invalidCode;
  } on FormatException {
    throw _invalidCode;
  }
}
