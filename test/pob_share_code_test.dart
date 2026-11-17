import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob2_ui/data/pob_share_code.dart';

void main() {
  const xml =
      '<?xml version="1.0"?><PathOfBuilding2><Build/><Notes>Ведьма</Notes></PathOfBuilding2>';

  test('Код соответствует zlib и Base64 URL и сохраняет Unicode', () async {
    final encoded = await encodePobShareCode(xml);
    expect(utf8.decode(zlib.decode(base64Url.decode(encoded))), xml);
    expect(await decodePobShareCode('  ${encoded.replaceAll('=', '')}\n'), xml);
  });

  test('Обрезанный архив и неверная контрольная сумма отклоняются', () async {
    final bytes = zlib.encode(utf8.encode(xml));
    final damaged = List.of(bytes)..last ^= 1;
    for (final payload in [bytes.sublist(0, bytes.length - 1), damaged]) {
      await expectLater(
        decodePobShareCode(base64Url.encode(payload)),
        throwsFormatException,
      );
    }
  });

  test('Размер распакованных данных ограничен', () async {
    final bytes = Uint8List(16 * 1024 * 1024 + 1);
    await expectLater(
      decodePobShareCode(base64Url.encode(zlib.encode(bytes))),
      throwsFormatException,
    );
  });
}
