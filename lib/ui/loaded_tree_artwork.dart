import 'dart:typed_data';
import 'dart:ui' as ui;

import '../domain/original_tree_scene.dart';
import 'original_tree_artwork.dart';

class LoadedTreeArtwork {
  LoadedTreeArtwork._(this.artwork, this.images);
  final OriginalTreeArtwork artwork;
  final Map<String, ui.Image> images;

  static Future<LoadedTreeArtwork> load(
    OriginalTreeScene scene,
    Map<String, Uint8List> bytes,
    Map<String, ui.Image> existing,
  ) async {
    final images = <String, ui.Image>{};
    try {
      for (final entry in bytes.entries) {
        images[entry.key] =
            existing[entry.key]?.clone() ?? await _decode(entry.value);
      }
      return LoadedTreeArtwork._(OriginalTreeArtwork(scene, images), images);
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
  }

  static Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  void dispose() {
    artwork.dispose();
    for (final image in images.values) {
      image.dispose();
    }
  }
}
