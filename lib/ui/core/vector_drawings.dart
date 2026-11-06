// Сгенерировано tool/generate_vectors.py из SVG; правьте исходные SVG.
import 'dart:ui';

typedef VectorDrawing = ({Size size, void Function(Canvas, Color, Color) draw});
final vectorDrawings = <String, VectorDrawing>{
  'brand/app-icon': (size: Size(256, 256), draw: drawVector0),
  'brand/badge': (size: Size(124, 124), draw: drawVector1),
  'brand/emblem': (size: Size(600, 580), draw: drawVector2),
  'brand/logo': (size: Size(600, 192), draw: drawVector3),
  'brand/mark': (size: Size(160, 192), draw: drawVector4),
  'brand/wordmark': (size: Size(390, 132), draw: drawVector5),
  'icons/arrow': (size: Size(24, 24), draw: drawVector6),
  'icons/back': (size: Size(24, 24), draw: drawVector7),
  'icons/book': (size: Size(24, 24), draw: drawVector8),
  'icons/boots': (size: Size(32, 32), draw: drawVector9),
  'icons/box': (size: Size(24, 24), draw: drawVector10),
  'icons/chart': (size: Size(24, 24), draw: drawVector11),
  'icons/check': (size: Size(24, 24), draw: drawVector12),
  'icons/chest-armour': (size: Size(24, 24), draw: drawVector13),
  'icons/chevron': (size: Size(24, 24), draw: drawVector14),
  'icons/close': (size: Size(24, 24), draw: drawVector15),
  'icons/code': (size: Size(24, 24), draw: drawVector16),
  'icons/copy': (size: Size(24, 24), draw: drawVector17),
  'icons/download': (size: Size(24, 24), draw: drawVector18),
  'icons/eye': (size: Size(24, 24), draw: drawVector19),
  'icons/fit': (size: Size(24, 24), draw: drawVector20),
  'icons/flask': (size: Size(24, 24), draw: drawVector21),
  'icons/gem': (size: Size(24, 24), draw: drawVector22),
  'icons/grid': (size: Size(24, 24), draw: drawVector23),
  'icons/heart': (size: Size(24, 24), draw: drawVector24),
  'icons/helmet': (size: Size(24, 24), draw: drawVector25),
  'icons/info': (size: Size(24, 24), draw: drawVector26),
  'icons/link': (size: Size(24, 24), draw: drawVector27),
  'icons/minus': (size: Size(24, 24), draw: drawVector28),
  'icons/moon': (size: Size(24, 24), draw: drawVector29),
  'icons/plus': (size: Size(24, 24), draw: drawVector30),
  'icons/refresh': (size: Size(24, 24), draw: drawVector31),
  'icons/search': (size: Size(24, 24), draw: drawVector32),
  'icons/settings': (size: Size(24, 24), draw: drawVector33),
  'icons/shield': (size: Size(24, 24), draw: drawVector34),
  'icons/spark': (size: Size(24, 24), draw: drawVector35),
  'icons/sun': (size: Size(24, 24), draw: drawVector36),
  'icons/sword': (size: Size(24, 24), draw: drawVector37),
  'icons/trash': (size: Size(24, 24), draw: drawVector38),
  'icons/tree': (size: Size(24, 24), draw: drawVector39),
  'icons/upload': (size: Size(24, 24), draw: drawVector40),
  'illustrations/atlas': (size: Size(160, 160), draw: drawVector41),
  'illustrations/components': (size: Size(160, 160), draw: drawVector42),
  'illustrations/flask': (size: Size(160, 160), draw: drawVector43),
  'illustrations/gem': (size: Size(160, 160), draw: drawVector44),
};
void drawVector0(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(8.0, 8.0, 240.0, 240.0),
        topLeft: Radius.elliptical(66.0, 66.0),
        topRight: Radius.elliptical(66.0, 66.0),
        bottomLeft: Radius.elliptical(66.0, 66.0),
        bottomRight: Radius.elliptical(66.0, 66.0),
      ),
    );
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.translate(48.0, 28.0);
  canvas.save();
  final path1 = Path()
    ..moveTo(81.0, 186.0)
    ..cubicTo(37.0, 173.0, 13.0, 141.0, 18.0, 108.0)
    ..cubicTo(22.0, 83.0, 42.0, 70.0, 43.0, 41.0)
    ..cubicTo(60.0, 51.0, 63.0, 65.0, 62.0, 76.0)
    ..cubicTo(86.0, 55.0, 89.0, 25.0, 85.0, 5.0)
    ..cubicTo(120.0, 29.0, 135.0, 58.0, 129.0, 84.0)
    ..cubicTo(139.0, 78.0, 145.0, 67.0, 147.0, 56.0)
    ..cubicTo(170.0, 106.0, 160.0, 163.0, 81.0, 186.0)
    ..close();
  canvas.drawPath(path1, Paint()..color = background);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path2 = Path()
    ..moveTo(80.0, 160.0)
    ..lineTo(80.0, 106.0)
    ..moveTo(80.0, 131.0)
    ..lineTo(58.0, 112.0)
    ..moveTo(80.0, 116.0)
    ..lineTo(104.0, 92.0)
    ..moveTo(80.0, 145.0)
    ..lineTo(105.0, 125.0);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(Rect.fromCircle(center: Offset(80.0, 99.0), radius: 7.0));
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..addOval(Rect.fromCircle(center: Offset(52.0, 106.0), radius: 6.0));
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..addOval(Rect.fromCircle(center: Offset(110.0, 85.0), radius: 7.0));
  canvas.drawPath(
    path5,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(Rect.fromCircle(center: Offset(111.0, 119.0), radius: 6.0));
  canvas.drawPath(
    path6,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector1(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  canvas.translate(-454.0, -36.0);
  canvas.save();
  canvas.translate(516.0, 100.0);
  canvas.rotate(-0.087266);
  canvas.translate(-516.0, -100.0);
  canvas.save();
  final path0 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(466.0, 46.0, 103.0, 103.0),
        topLeft: Radius.elliptical(33.0, 33.0),
        topRight: Radius.elliptical(33.0, 33.0),
        bottomLeft: Radius.elliptical(33.0, 33.0),
        bottomRight: Radius.elliptical(33.0, 33.0),
      ),
    );
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(500.0, 74.0)
    ..lineTo(500.0, 122.0)
    ..moveTo(532.0, 74.0)
    ..lineTo(532.0, 122.0);
  canvas.drawPath(path1, Paint()..color = color);
  canvas.drawPath(
    path1,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector2(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  canvas.save();
  canvas.translate(300.0, 297.0);
  canvas.rotate(-0.471239);
  canvas.translate(-300.0, -297.0);
  final path0 = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(300.0, 297.0),
        width: 482.0,
        height: 302.0,
      ),
    );
  canvas.drawPath(
    path0,
    Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  canvas.translate(300.0, 297.0);
  canvas.rotate(0.523599);
  canvas.translate(-300.0, -297.0);
  final path1 = Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(300.0, 297.0),
        width: 408.0,
        height: 476.0,
      ),
    );
  canvas.drawPath(
    path1,
    Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(300.0, 297.0), radius: 206.0));
  canvas.drawPath(
    path2,
    Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..moveTo(138.0, 452.0)
    ..cubicTo(185.0, 422.0, 412.0, 421.0, 459.0, 452.0)
    ..cubicTo(505.0, 482.0, 430.0, 505.0, 385.0, 506.0)
    ..cubicTo(348.0, 506.0, 372.0, 529.0, 313.0, 531.0)
    ..cubicTo(241.0, 534.0, 277.0, 509.0, 217.0, 509.0)
    ..cubicTo(164.0, 509.0, 85.0, 485.0, 138.0, 452.0)
    ..close();
  canvas.drawPath(path3, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.translate(163.0, 58.0);
  canvas.scale(1.7, 1.7);
  canvas.save();
  final path4 = Path()
    ..moveTo(81.0, 186.0)
    ..cubicTo(37.0, 173.0, 13.0, 141.0, 18.0, 108.0)
    ..cubicTo(22.0, 83.0, 42.0, 70.0, 43.0, 41.0)
    ..cubicTo(60.0, 51.0, 63.0, 65.0, 62.0, 76.0)
    ..cubicTo(86.0, 55.0, 89.0, 25.0, 85.0, 5.0)
    ..cubicTo(120.0, 29.0, 135.0, 58.0, 129.0, 84.0)
    ..cubicTo(139.0, 78.0, 145.0, 67.0, 147.0, 56.0)
    ..cubicTo(170.0, 106.0, 160.0, 163.0, 81.0, 186.0)
    ..close();
  canvas.drawPath(path4, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path5 = Path()
    ..moveTo(80.0, 160.0)
    ..lineTo(80.0, 106.0)
    ..moveTo(80.0, 131.0)
    ..lineTo(58.0, 112.0)
    ..moveTo(80.0, 116.0)
    ..lineTo(104.0, 92.0)
    ..moveTo(80.0, 145.0)
    ..lineTo(105.0, 125.0);
  canvas.drawPath(
    path5,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(Rect.fromCircle(center: Offset(80.0, 99.0), radius: 7.0));
  canvas.drawPath(
    path6,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..addOval(Rect.fromCircle(center: Offset(52.0, 106.0), radius: 6.0));
  canvas.drawPath(
    path7,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path8 = Path()
    ..addOval(Rect.fromCircle(center: Offset(110.0, 85.0), radius: 7.0));
  canvas.drawPath(
    path8,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path9 = Path()
    ..addOval(Rect.fromCircle(center: Offset(111.0, 119.0), radius: 6.0));
  canvas.drawPath(
    path9,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path10 = Path()
    ..moveTo(85.0, 336.0)
    ..lineTo(125.0, 314.0)
    ..lineTo(165.0, 336.0)
    ..lineTo(125.0, 361.0)
    ..close();
  canvas.drawPath(path10, Paint()..color = background);
  canvas.drawPath(
    path10,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path11 = Path()
    ..moveTo(85.0, 336.0)
    ..lineTo(125.0, 361.0)
    ..lineTo(125.0, 408.0)
    ..lineTo(85.0, 384.0)
    ..close();
  canvas.drawPath(path11, Paint()..color = background);
  canvas.drawPath(
    path11,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path12 = Path()
    ..moveTo(125.0, 361.0)
    ..lineTo(165.0, 336.0)
    ..lineTo(165.0, 384.0)
    ..lineTo(125.0, 408.0)
    ..close();
  canvas.drawPath(path12, Paint()..color = color);
  canvas.drawPath(
    path12,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path13 = Path()
    ..moveTo(430.0, 187.0)
    ..lineTo(467.0, 126.0)
    ..lineTo(504.0, 187.0)
    ..lineTo(467.0, 209.0)
    ..close();
  canvas.drawPath(path13, Paint()..color = background);
  canvas.drawPath(
    path13,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path14 = Path()
    ..moveTo(467.0, 126.0)
    ..lineTo(504.0, 187.0)
    ..lineTo(467.0, 209.0)
    ..close();
  canvas.drawPath(path14, Paint()..color = color);
  canvas.drawPath(
    path14,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path15 = Path()
    ..moveTo(430.0, 187.0)
    ..lineTo(467.0, 209.0)
    ..lineTo(467.0, 244.0)
    ..close();
  canvas.drawPath(path15, Paint()..color = background);
  canvas.drawPath(
    path15,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path16 = Path()
    ..moveTo(467.0, 209.0)
    ..lineTo(504.0, 187.0)
    ..lineTo(467.0, 244.0)
    ..close();
  canvas.drawPath(path16, Paint()..color = color);
  canvas.drawPath(
    path16,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path17 = Path()
    ..moveTo(109.0, 154.0)
    ..lineTo(115.0, 171.0)
    ..lineTo(132.0, 177.0)
    ..lineTo(115.0, 183.0)
    ..lineTo(109.0, 200.0)
    ..lineTo(103.0, 183.0)
    ..lineTo(86.0, 177.0)
    ..lineTo(103.0, 171.0)
    ..close()
    ..moveTo(502.0, 338.0)
    ..lineTo(509.0, 358.0)
    ..lineTo(529.0, 365.0)
    ..lineTo(509.0, 372.0)
    ..lineTo(502.0, 392.0)
    ..lineTo(495.0, 372.0)
    ..lineTo(475.0, 365.0)
    ..lineTo(495.0, 358.0)
    ..close()
    ..moveTo(183.0, 73.0)
    ..lineTo(187.0, 84.0)
    ..lineTo(198.0, 88.0)
    ..lineTo(187.0, 92.0)
    ..lineTo(183.0, 103.0)
    ..lineTo(179.0, 92.0)
    ..lineTo(168.0, 88.0)
    ..lineTo(179.0, 84.0)
    ..close();
  canvas.drawPath(path17, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path18 = Path()
    ..addOval(Rect.fromCircle(center: Offset(77.0, 267.0), radius: 4.0));
  canvas.drawPath(path18, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path19 = Path()
    ..addOval(Rect.fromCircle(center: Offset(411.0, 64.0), radius: 5.0));
  canvas.drawPath(path19, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path20 = Path()
    ..addOval(Rect.fromCircle(center: Offset(548.0, 279.0), radius: 3.0));
  canvas.drawPath(path20, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path21 = Path()
    ..addOval(Rect.fromCircle(center: Offset(195.0, 429.0), radius: 4.0));
  canvas.drawPath(path21, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path22 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(112.0, 462.0), width: 28.0, height: 16.0),
    );
  canvas.drawPath(path22, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path23 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(458.0, 487.0), width: 22.0, height: 12.0),
    );
  canvas.drawPath(path23, Paint()..color = color);
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path24 = Path()
    ..moveTo(274.0, 475.0)
    ..lineTo(279.0, 486.0)
    ..lineTo(290.0, 491.0)
    ..lineTo(279.0, 496.0)
    ..lineTo(274.0, 507.0)
    ..lineTo(269.0, 496.0)
    ..lineTo(258.0, 491.0)
    ..lineTo(269.0, 486.0)
    ..close()
    ..moveTo(387.0, 452.0)
    ..lineTo(390.0, 460.0)
    ..lineTo(398.0, 463.0)
    ..lineTo(390.0, 466.0)
    ..lineTo(387.0, 474.0)
    ..lineTo(384.0, 466.0)
    ..lineTo(376.0, 463.0)
    ..lineTo(384.0, 460.0)
    ..close();
  canvas.drawPath(path24, Paint()..color = background);
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector3(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(81.0, 186.0)
    ..cubicTo(37.0, 173.0, 13.0, 141.0, 18.0, 108.0)
    ..cubicTo(22.0, 83.0, 42.0, 70.0, 43.0, 41.0)
    ..cubicTo(60.0, 51.0, 63.0, 65.0, 62.0, 76.0)
    ..cubicTo(86.0, 55.0, 89.0, 25.0, 85.0, 5.0)
    ..cubicTo(120.0, 29.0, 135.0, 58.0, 129.0, 84.0)
    ..cubicTo(139.0, 78.0, 145.0, 67.0, 147.0, 56.0)
    ..cubicTo(170.0, 106.0, 160.0, 163.0, 81.0, 186.0)
    ..close();
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(80.0, 160.0)
    ..lineTo(80.0, 106.0)
    ..moveTo(80.0, 131.0)
    ..lineTo(58.0, 112.0)
    ..moveTo(80.0, 116.0)
    ..lineTo(104.0, 92.0)
    ..moveTo(80.0, 145.0)
    ..lineTo(105.0, 125.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(80.0, 99.0), radius: 7.0));
  canvas.drawPath(
    path2,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(Rect.fromCircle(center: Offset(52.0, 106.0), radius: 6.0));
  canvas.drawPath(
    path3,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..addOval(Rect.fromCircle(center: Offset(110.0, 85.0), radius: 7.0));
  canvas.drawPath(
    path4,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..addOval(Rect.fromCircle(center: Offset(111.0, 119.0), radius: 6.0));
  canvas.drawPath(
    path5,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path6 = Path()
    ..moveTo(207.0, 139.0)
    ..lineTo(214.0, 43.0)
    ..lineTo(236.0, 43.0)
    ..cubicTo(284.0, 43.0, 280.0, 103.0, 233.0, 103.0)
    ..lineTo(210.0, 103.0);
  canvas.drawPath(
    path6,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..moveTo(310.0, 80.0)
    ..cubicTo(272.0, 77.0, 269.0, 144.0, 304.0, 143.0)
    ..cubicTo(340.0, 142.0, 346.0, 82.0, 310.0, 80.0)
    ..close();
  canvas.drawPath(
    path7,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path8 = Path()
    ..moveTo(363.0, 140.0)
    ..lineTo(370.0, 44.0)
    ..lineTo(393.0, 44.0)
    ..cubicTo(433.0, 44.0, 431.0, 90.0, 398.0, 91.0)
    ..cubicTo(439.0, 89.0, 439.0, 143.0, 395.0, 143.0)
    ..close();
  canvas.drawPath(
    path8,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.translate(516.0, 100.0);
  canvas.rotate(-0.087266);
  canvas.translate(-516.0, -100.0);
  canvas.save();
  final path9 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(466.0, 46.0, 103.0, 103.0),
        topLeft: Radius.elliptical(33.0, 33.0),
        topRight: Radius.elliptical(33.0, 33.0),
        bottomLeft: Radius.elliptical(33.0, 33.0),
        bottomRight: Radius.elliptical(33.0, 33.0),
      ),
    );
  canvas.drawPath(path9, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path10 = Path()
    ..moveTo(500.0, 74.0)
    ..lineTo(500.0, 122.0)
    ..moveTo(532.0, 74.0)
    ..lineTo(532.0, 122.0);
  canvas.drawPath(path10, Paint()..color = color);
  canvas.drawPath(
    path10,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector4(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(81.0, 186.0)
    ..cubicTo(37.0, 173.0, 13.0, 141.0, 18.0, 108.0)
    ..cubicTo(22.0, 83.0, 42.0, 70.0, 43.0, 41.0)
    ..cubicTo(60.0, 51.0, 63.0, 65.0, 62.0, 76.0)
    ..cubicTo(86.0, 55.0, 89.0, 25.0, 85.0, 5.0)
    ..cubicTo(120.0, 29.0, 135.0, 58.0, 129.0, 84.0)
    ..cubicTo(139.0, 78.0, 145.0, 67.0, 147.0, 56.0)
    ..cubicTo(170.0, 106.0, 160.0, 163.0, 81.0, 186.0)
    ..close();
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(80.0, 160.0)
    ..lineTo(80.0, 106.0)
    ..moveTo(80.0, 131.0)
    ..lineTo(58.0, 112.0)
    ..moveTo(80.0, 116.0)
    ..lineTo(104.0, 92.0)
    ..moveTo(80.0, 145.0)
    ..lineTo(105.0, 125.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(80.0, 99.0), radius: 7.0));
  canvas.drawPath(
    path2,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(Rect.fromCircle(center: Offset(52.0, 106.0), radius: 6.0));
  canvas.drawPath(
    path3,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..addOval(Rect.fromCircle(center: Offset(110.0, 85.0), radius: 7.0));
  canvas.drawPath(
    path4,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..addOval(Rect.fromCircle(center: Offset(111.0, 119.0), radius: 6.0));
  canvas.drawPath(
    path5,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector5(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  canvas.translate(-190.0, -30.0);
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(207.0, 139.0)
    ..lineTo(214.0, 43.0)
    ..lineTo(236.0, 43.0)
    ..cubicTo(284.0, 43.0, 280.0, 103.0, 233.0, 103.0)
    ..lineTo(210.0, 103.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(310.0, 80.0)
    ..cubicTo(272.0, 77.0, 269.0, 144.0, 304.0, 143.0)
    ..cubicTo(340.0, 142.0, 346.0, 82.0, 310.0, 80.0)
    ..close();
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..moveTo(363.0, 140.0)
    ..lineTo(370.0, 44.0)
    ..lineTo(393.0, 44.0)
    ..cubicTo(433.0, 44.0, 431.0, 90.0, 398.0, 91.0)
    ..cubicTo(439.0, 89.0, 439.0, 143.0, 395.0, 143.0)
    ..close();
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.translate(516.0, 100.0);
  canvas.rotate(-0.087266);
  canvas.translate(-516.0, -100.0);
  canvas.save();
  final path3 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(466.0, 46.0, 103.0, 103.0),
        topLeft: Radius.elliptical(33.0, 33.0),
        topRight: Radius.elliptical(33.0, 33.0),
        bottomLeft: Radius.elliptical(33.0, 33.0),
        bottomRight: Radius.elliptical(33.0, 33.0),
      ),
    );
  canvas.drawPath(path3, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..moveTo(500.0, 74.0)
    ..lineTo(500.0, 122.0)
    ..moveTo(532.0, 74.0)
    ..lineTo(532.0, 122.0);
  canvas.drawPath(path4, Paint()..color = color);
  canvas.drawPath(
    path4,
    Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector6(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(4.0, 12.0)
    ..lineTo(20.0, 12.0)
    ..moveTo(14.0, 6.0)
    ..lineTo(20.0, 12.0)
    ..lineTo(14.0, 18.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector7(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(20.0, 12.0)
    ..lineTo(4.0, 12.0)
    ..moveTo(10.0, 6.0)
    ..lineTo(4.0, 12.0)
    ..lineTo(10.0, 18.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector8(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(3.0, 4.0)
    ..lineTo(9.0, 4.0)
    ..cubicTo(11.0, 4.0, 12.0, 5.0, 12.0, 7.0)
    ..cubicTo(12.0, 5.0, 13.0, 4.0, 15.0, 4.0)
    ..lineTo(21.0, 4.0)
    ..lineTo(21.0, 20.0)
    ..lineTo(15.0, 20.0)
    ..cubicTo(13.0, 20.0, 12.0, 21.0, 12.0, 22.0)
    ..cubicTo(12.0, 21.0, 11.0, 20.0, 9.0, 20.0)
    ..lineTo(3.0, 20.0)
    ..close()
    ..moveTo(12.0, 7.0)
    ..lineTo(12.0, 22.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector9(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(8.0, 3.0)
    ..lineTo(21.0, 3.0)
    ..lineTo(19.0, 15.0)
    ..cubicTo(18.7, 17.0, 18.8, 18.3, 19.5, 19.5)
    ..lineTo(25.0, 21.5)
    ..cubicTo(27.8, 22.5, 29.5, 24.7, 30.0, 28.0)
    ..lineTo(5.0, 28.0)
    ..cubicTo(4.3, 24.8, 5.1, 22.5, 6.3, 20.0)
    ..lineTo(9.0, 14.0)
    ..cubicTo(10.0, 10.0, 9.5, 6.0, 8.0, 3.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(14.0, 3.0)
    ..cubicTo(14.4, 9.3, 13.9, 14.2, 8.5, 18.5)
    ..moveTo(6.2, 22.0)
    ..cubicTo(10.6, 22.0, 13.7, 18.8, 19.2, 18.0)
    ..moveTo(11.0, 28.0)
    ..cubicTo(12.2, 24.8, 14.6, 21.8, 20.4, 20.0)
    ..moveTo(23.0, 28.0)
    ..cubicTo(22.9, 25.4, 23.5, 23.9, 24.7, 22.4)
    ..moveTo(5.0, 30.0)
    ..lineTo(30.0, 30.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(17.3, 6.0), radius: 0.8));
  canvas.drawPath(path2, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(Rect.fromCircle(center: Offset(16.8, 9.5), radius: 0.8));
  canvas.drawPath(path3, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..addOval(Rect.fromCircle(center: Offset(16.0, 13.0), radius: 0.8));
  canvas.drawPath(path4, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..addOval(Rect.fromCircle(center: Offset(14.4, 16.5), radius: 0.8));
  canvas.drawPath(path5, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(Rect.fromCircle(center: Offset(7.3, 26.0), radius: 0.8));
  canvas.drawPath(path6, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..addOval(Rect.fromCircle(center: Offset(26.0, 26.0), radius: 0.8));
  canvas.drawPath(path7, Paint()..color = color);
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector10(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 2.0)
    ..lineTo(21.0, 7.0)
    ..lineTo(21.0, 17.0)
    ..lineTo(12.0, 22.0)
    ..lineTo(3.0, 17.0)
    ..lineTo(3.0, 7.0)
    ..close()
    ..moveTo(3.0, 7.0)
    ..lineTo(12.0, 12.0)
    ..lineTo(21.0, 7.0)
    ..moveTo(12.0, 12.0)
    ..lineTo(12.0, 22.0)
    ..moveTo(7.5, 4.5)
    ..lineTo(16.5, 9.5)
    ..lineTo(16.5, 14.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector11(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(4.0, 3.0)
    ..lineTo(4.0, 20.0)
    ..lineTo(21.0, 20.0)
    ..moveTo(8.0, 14.0)
    ..lineTo(12.0, 9.0)
    ..lineTo(16.0, 11.0)
    ..lineTo(21.0, 4.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector12(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(5.0, 12.0)
    ..lineTo(9.0, 16.0)
    ..lineTo(19.0, 6.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector13(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(8.0, 3.0)
    ..lineTo(4.0, 5.0)
    ..lineTo(2.0, 10.0)
    ..lineTo(6.0, 12.0)
    ..lineTo(6.0, 19.0)
    ..lineTo(12.0, 21.0)
    ..lineTo(18.0, 19.0)
    ..lineTo(18.0, 12.0)
    ..lineTo(22.0, 10.0)
    ..lineTo(20.0, 5.0)
    ..lineTo(16.0, 3.0)
    ..cubicTo(16.0, 7.0, 8.0, 7.0, 8.0, 3.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(12.0, 7.0)
    ..lineTo(12.0, 20.0)
    ..moveTo(6.0, 12.0)
    ..lineTo(12.0, 14.0)
    ..lineTo(18.0, 12.0)
    ..moveTo(4.0, 5.0)
    ..lineTo(7.0, 9.0)
    ..moveTo(20.0, 5.0)
    ..lineTo(17.0, 9.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector14(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(9.0, 5.0)
    ..lineTo(16.0, 12.0)
    ..lineTo(9.0, 19.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector15(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(6.0, 6.0)
    ..lineTo(18.0, 18.0)
    ..moveTo(6.0, 18.0)
    ..lineTo(18.0, 6.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector16(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(7.0, 6.0)
    ..lineTo(1.0, 12.0)
    ..lineTo(7.0, 18.0)
    ..moveTo(17.0, 6.0)
    ..lineTo(23.0, 12.0)
    ..lineTo(17.0, 18.0)
    ..moveTo(14.0, 3.0)
    ..lineTo(10.0, 21.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector17(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(8.0, 8.0, 13.0, 13.0),
        topLeft: Radius.elliptical(2.0, 2.0),
        topRight: Radius.elliptical(2.0, 2.0),
        bottomLeft: Radius.elliptical(2.0, 2.0),
        bottomRight: Radius.elliptical(2.0, 2.0),
      ),
    );
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(16.0, 8.0)
    ..lineTo(16.0, 3.0)
    ..lineTo(3.0, 3.0)
    ..lineTo(3.0, 16.0)
    ..lineTo(8.0, 16.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector18(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 3.0)
    ..lineTo(12.0, 15.0)
    ..moveTo(7.0, 10.0)
    ..lineTo(12.0, 15.0)
    ..lineTo(17.0, 10.0)
    ..moveTo(4.0, 17.0)
    ..lineTo(4.0, 21.0)
    ..lineTo(20.0, 21.0)
    ..lineTo(20.0, 17.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector19(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(2.0, 12.0)
    ..cubicTo(2.0, 12.0, 6.0, 5.0, 12.0, 5.0)
    ..cubicTo(18.0, 5.0, 22.0, 12.0, 22.0, 12.0)
    ..cubicTo(22.0, 12.0, 18.0, 19.0, 12.0, 19.0)
    ..cubicTo(6.0, 19.0, 2.0, 12.0, 2.0, 12.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..addOval(Rect.fromCircle(center: Offset(12.0, 12.0), radius: 3.0));
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector20(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(8.0, 3.0)
    ..lineTo(3.0, 3.0)
    ..lineTo(3.0, 8.0)
    ..moveTo(16.0, 3.0)
    ..lineTo(21.0, 3.0)
    ..lineTo(21.0, 8.0)
    ..moveTo(3.0, 16.0)
    ..lineTo(3.0, 21.0)
    ..lineTo(8.0, 21.0)
    ..moveTo(21.0, 16.0)
    ..lineTo(21.0, 21.0)
    ..lineTo(16.0, 21.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector21(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(8.0, 3.0)
    ..lineTo(16.0, 3.0)
    ..moveTo(9.0, 3.0)
    ..lineTo(9.0, 9.0)
    ..lineTo(3.0, 19.0)
    ..cubicTo(2.4, 20.0, 3.1, 21.0, 4.3, 21.0)
    ..lineTo(19.7, 21.0)
    ..cubicTo(20.9, 21.0, 21.6, 20.0, 21.0, 19.0)
    ..lineTo(15.0, 9.0)
    ..lineTo(15.0, 3.0)
    ..moveTo(6.0, 15.0)
    ..lineTo(18.0, 15.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..addOval(Rect.fromCircle(center: Offset(11.0, 17.0), radius: 0.6));
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector22(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 2.0)
    ..lineTo(20.0, 10.0)
    ..lineTo(12.0, 22.0)
    ..lineTo(4.0, 10.0)
    ..close()
    ..moveTo(4.0, 10.0)
    ..lineTo(20.0, 10.0)
    ..moveTo(12.0, 2.0)
    ..lineTo(9.0, 10.0)
    ..lineTo(12.0, 22.0)
    ..lineTo(15.0, 10.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector23(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(3.0, 3.0, 7.0, 7.0),
        topLeft: Radius.elliptical(2.0, 2.0),
        topRight: Radius.elliptical(2.0, 2.0),
        bottomLeft: Radius.elliptical(2.0, 2.0),
        bottomRight: Radius.elliptical(2.0, 2.0),
      ),
    );
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(14.0, 3.0, 7.0, 7.0),
        topLeft: Radius.elliptical(2.0, 2.0),
        topRight: Radius.elliptical(2.0, 2.0),
        bottomLeft: Radius.elliptical(2.0, 2.0),
        bottomRight: Radius.elliptical(2.0, 2.0),
      ),
    );
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(3.0, 14.0, 7.0, 7.0),
        topLeft: Radius.elliptical(2.0, 2.0),
        topRight: Radius.elliptical(2.0, 2.0),
        bottomLeft: Radius.elliptical(2.0, 2.0),
        bottomRight: Radius.elliptical(2.0, 2.0),
      ),
    );
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(14.0, 14.0, 7.0, 7.0),
        topLeft: Radius.elliptical(2.0, 2.0),
        topRight: Radius.elliptical(2.0, 2.0),
        bottomLeft: Radius.elliptical(2.0, 2.0),
        bottomRight: Radius.elliptical(2.0, 2.0),
      ),
    );
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector24(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 21.0)
    ..cubicTo(7.0, 17.0, 2.0, 13.0, 2.0, 8.0)
    ..arcToPoint(
      Offset(12.0, 7.0),
      radius: Radius.elliptical(5.0, 5.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: true,
    )
    ..arcToPoint(
      Offset(22.0, 8.0),
      radius: Radius.elliptical(5.0, 5.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: true,
    )
    ..cubicTo(22.0, 13.0, 17.0, 17.0, 12.0, 21.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector25(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(6.0, 6.0)
    ..cubicTo(8.0, 2.0, 16.0, 2.0, 18.0, 6.0)
    ..lineTo(19.0, 16.0)
    ..lineTo(12.0, 21.0)
    ..lineTo(5.0, 16.0)
    ..lineTo(6.0, 6.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(6.0, 9.0)
    ..lineTo(18.0, 9.0)
    ..moveTo(12.0, 9.0)
    ..lineTo(12.0, 20.0)
    ..moveTo(7.5, 12.0)
    ..lineTo(9.5, 12.0)
    ..moveTo(14.5, 12.0)
    ..lineTo(16.5, 12.0)
    ..moveTo(7.5, 15.0)
    ..lineTo(9.5, 15.0)
    ..moveTo(14.5, 15.0)
    ..lineTo(16.5, 15.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector26(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addOval(Rect.fromCircle(center: Offset(12.0, 12.0), radius: 9.0));
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(12.0, 11.0)
    ..lineTo(12.0, 17.0)
    ..moveTo(12.0, 7.0)
    ..lineTo(12.0, 7.1);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector27(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(9.0, 15.0)
    ..lineTo(15.0, 9.0)
    ..moveTo(10.0, 6.0)
    ..lineTo(12.0, 4.0)
    ..arcToPoint(
      Offset(20.0, 12.0),
      radius: Radius.elliptical(5.0, 5.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: true,
    )
    ..lineTo(18.0, 14.0)
    ..moveTo(14.0, 18.0)
    ..lineTo(12.0, 20.0)
    ..arcToPoint(
      Offset(4.0, 12.0),
      radius: Radius.elliptical(5.0, 5.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: true,
    )
    ..lineTo(6.0, 10.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector28(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(5.0, 12.0)
    ..lineTo(19.0, 12.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector29(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(20.0, 14.0)
    ..arcToPoint(
      Offset(10.0, 4.0),
      radius: Radius.elliptical(8.0, 8.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: true,
    )
    ..arcToPoint(
      Offset(20.0, 14.0),
      radius: Radius.elliptical(8.5, 8.5),
      rotation: 0.0,
      largeArc: true,
      clockwise: false,
    )
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector30(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 5.0)
    ..lineTo(12.0, 19.0)
    ..moveTo(5.0, 12.0)
    ..lineTo(19.0, 12.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector31(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(20.0, 8.0)
    ..arcToPoint(
      Offset(6.0, 5.0),
      radius: Radius.elliptical(8.0, 8.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: false,
    )
    ..lineTo(3.0, 8.0)
    ..moveTo(3.0, 3.0)
    ..lineTo(3.0, 8.0)
    ..lineTo(8.0, 8.0)
    ..moveTo(4.0, 16.0)
    ..arcToPoint(
      Offset(18.0, 19.0),
      radius: Radius.elliptical(8.0, 8.0),
      rotation: 0.0,
      largeArc: false,
      clockwise: false,
    )
    ..lineTo(21.0, 16.0)
    ..moveTo(21.0, 21.0)
    ..lineTo(21.0, 16.0)
    ..lineTo(16.0, 16.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector32(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addOval(Rect.fromCircle(center: Offset(10.5, 10.5), radius: 6.5));
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(16.0, 16.0)
    ..lineTo(21.0, 21.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector33(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(4.0, 7.0)
    ..lineTo(20.0, 7.0)
    ..moveTo(4.0, 17.0)
    ..lineTo(20.0, 17.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..addOval(Rect.fromCircle(center: Offset(9.0, 7.0), radius: 3.0));
  canvas.drawPath(path1, Paint()..color = background);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(15.0, 17.0), radius: 3.0));
  canvas.drawPath(path2, Paint()..color = background);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector34(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 2.0)
    ..lineTo(20.0, 5.0)
    ..lineTo(20.0, 12.0)
    ..cubicTo(20.0, 17.0, 12.0, 22.0, 12.0, 22.0)
    ..cubicTo(12.0, 22.0, 4.0, 17.0, 4.0, 12.0)
    ..lineTo(4.0, 5.0)
    ..close()
    ..moveTo(12.0, 7.0)
    ..lineTo(12.0, 17.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector35(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 2.0)
    ..lineTo(15.0, 9.0)
    ..lineTo(22.0, 12.0)
    ..lineTo(15.0, 15.0)
    ..lineTo(12.0, 22.0)
    ..lineTo(9.0, 15.0)
    ..lineTo(2.0, 12.0)
    ..lineTo(9.0, 9.0)
    ..close();
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector36(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addOval(Rect.fromCircle(center: Offset(12.0, 12.0), radius: 4.0));
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..moveTo(12.0, 1.0)
    ..lineTo(12.0, 3.0)
    ..moveTo(12.0, 21.0)
    ..lineTo(12.0, 23.0)
    ..moveTo(1.0, 12.0)
    ..lineTo(3.0, 12.0)
    ..moveTo(21.0, 12.0)
    ..lineTo(23.0, 12.0)
    ..moveTo(4.0, 4.0)
    ..lineTo(6.0, 6.0)
    ..moveTo(18.0, 18.0)
    ..lineTo(20.0, 20.0)
    ..moveTo(4.0, 20.0)
    ..lineTo(6.0, 18.0)
    ..moveTo(18.0, 6.0)
    ..lineTo(20.0, 4.0);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector37(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(6.0, 15.0)
    ..lineTo(17.0, 3.0)
    ..lineTo(21.0, 2.0)
    ..lineTo(20.0, 7.0)
    ..lineTo(9.0, 18.0)
    ..moveTo(3.0, 13.0)
    ..lineTo(11.0, 21.0)
    ..moveTo(2.0, 22.0)
    ..lineTo(6.0, 17.0)
    ..moveTo(4.0, 19.0)
    ..lineTo(6.0, 21.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector38(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(3.0, 6.0)
    ..lineTo(21.0, 6.0)
    ..moveTo(9.0, 6.0)
    ..lineTo(9.0, 3.0)
    ..lineTo(15.0, 3.0)
    ..lineTo(15.0, 6.0)
    ..moveTo(5.0, 6.0)
    ..lineTo(6.0, 21.0)
    ..lineTo(18.0, 21.0)
    ..lineTo(19.0, 6.0)
    ..moveTo(10.0, 10.0)
    ..lineTo(10.0, 17.0)
    ..moveTo(14.0, 10.0)
    ..lineTo(14.0, 17.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector39(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 21.0)
    ..lineTo(12.0, 4.0)
    ..moveTo(12.0, 15.0)
    ..lineTo(5.0, 10.0)
    ..moveTo(12.0, 11.0)
    ..lineTo(19.0, 6.0)
    ..moveTo(12.0, 19.0)
    ..lineTo(19.0, 15.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path1 = Path()
    ..addOval(Rect.fromCircle(center: Offset(12.0, 3.0), radius: 2.0));
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(Rect.fromCircle(center: Offset(3.0, 9.0), radius: 2.0));
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(Rect.fromCircle(center: Offset(21.0, 5.0), radius: 2.0));
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..addOval(Rect.fromCircle(center: Offset(21.0, 14.0), radius: 2.0));
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector40(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(12.0, 16.0)
    ..lineTo(12.0, 4.0)
    ..moveTo(7.0, 9.0)
    ..lineTo(12.0, 4.0)
    ..lineTo(17.0, 9.0)
    ..moveTo(4.0, 17.0)
    ..lineTo(4.0, 21.0)
    ..lineTo(20.0, 21.0)
    ..lineTo(20.0, 17.0);
  canvas.drawPath(
    path0,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
}

void drawVector41(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(24.0, 126.0)
    ..lineTo(91.0, 88.0)
    ..lineTo(143.0, 118.0)
    ..lineTo(77.0, 157.0)
    ..close();
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(31.0, 35.0)
    ..lineTo(98.0, 10.0)
    ..lineTo(125.0, 25.0)
    ..lineTo(125.0, 120.0)
    ..lineTo(58.0, 146.0)
    ..lineTo(31.0, 130.0)
    ..close();
  canvas.drawPath(path1, Paint()..color = background);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..moveTo(31.0, 35.0)
    ..lineTo(58.0, 50.0)
    ..lineTo(125.0, 25.0)
    ..moveTo(58.0, 50.0)
    ..lineTo(58.0, 146.0);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..moveTo(99.0, 11.0)
    ..lineTo(125.0, 25.0)
    ..lineTo(125.0, 120.0)
    ..lineTo(99.0, 106.0)
    ..close();
  canvas.drawPath(path3, Paint()..color = color);
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..moveTo(37.0, 125.0)
    ..lineTo(53.0, 134.0)
    ..moveTo(37.0, 118.0)
    ..lineTo(53.0, 127.0)
    ..moveTo(63.0, 139.0)
    ..lineTo(119.0, 117.0);
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..moveTo(83.0, 112.0)
    ..lineTo(83.0, 66.0)
    ..moveTo(83.0, 92.0)
    ..lineTo(69.0, 81.0)
    ..moveTo(83.0, 80.0)
    ..lineTo(96.0, 67.0)
    ..moveTo(83.0, 105.0)
    ..lineTo(94.0, 95.0);
  canvas.drawPath(
    path5,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(Rect.fromCircle(center: Offset(83.0, 61.0), radius: 5.0));
  canvas.drawPath(path6, Paint()..color = background);
  canvas.drawPath(
    path6,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..addOval(Rect.fromCircle(center: Offset(66.0, 78.0), radius: 4.0));
  canvas.drawPath(path7, Paint()..color = background);
  canvas.drawPath(
    path7,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path8 = Path()
    ..addOval(Rect.fromCircle(center: Offset(99.0, 63.0), radius: 4.0));
  canvas.drawPath(path8, Paint()..color = background);
  canvas.drawPath(
    path8,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path9 = Path()
    ..addOval(Rect.fromCircle(center: Offset(98.0, 91.0), radius: 4.0));
  canvas.drawPath(path9, Paint()..color = background);
  canvas.drawPath(
    path9,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector42(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(16.0, 119.0)
    ..lineTo(84.0, 80.0)
    ..lineTo(150.0, 119.0)
    ..lineTo(82.0, 158.0)
    ..close();
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(25.0, 77.0)
    ..lineTo(67.0, 53.0)
    ..lineTo(110.0, 77.0)
    ..lineTo(110.0, 126.0)
    ..lineTo(67.0, 150.0)
    ..lineTo(25.0, 126.0)
    ..close();
  canvas.drawPath(path1, Paint()..color = background);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..moveTo(25.0, 77.0)
    ..lineTo(67.0, 101.0)
    ..lineTo(110.0, 77.0)
    ..moveTo(67.0, 101.0)
    ..lineTo(67.0, 150.0);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..moveTo(67.0, 53.0)
    ..lineTo(110.0, 77.0)
    ..lineTo(110.0, 126.0)
    ..lineTo(67.0, 150.0)
    ..lineTo(67.0, 101.0)
    ..lineTo(25.0, 77.0)
    ..close();
  canvas.drawPath(path3, Paint()..color = color);
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..moveTo(75.0, 25.0)
    ..lineTo(105.0, 8.0)
    ..lineTo(135.0, 25.0)
    ..lineTo(135.0, 61.0)
    ..lineTo(105.0, 78.0)
    ..lineTo(75.0, 61.0)
    ..close();
  canvas.drawPath(path4, Paint()..color = background);
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..moveTo(75.0, 25.0)
    ..lineTo(105.0, 42.0)
    ..lineTo(135.0, 25.0)
    ..moveTo(105.0, 42.0)
    ..lineTo(105.0, 78.0);
  canvas.drawPath(
    path5,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..moveTo(105.0, 8.0)
    ..lineTo(135.0, 25.0)
    ..lineTo(135.0, 61.0)
    ..lineTo(105.0, 78.0)
    ..lineTo(105.0, 42.0)
    ..lineTo(75.0, 25.0)
    ..close();
  canvas.drawPath(path6, Paint()..color = color);
  canvas.drawPath(
    path6,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..moveTo(37.0, 100.0)
    ..lineTo(54.0, 110.0)
    ..lineTo(54.0, 123.0)
    ..lineTo(37.0, 113.0)
    ..close();
  canvas.drawPath(path7, Paint()..color = background);
  canvas.drawPath(
    path7,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path8 = Path()
    ..moveTo(88.0, 20.0)
    ..lineTo(118.0, 37.0)
    ..lineTo(118.0, 54.0)
    ..lineTo(109.0, 49.0)
    ..lineTo(109.0, 42.0)
    ..lineTo(82.0, 26.0)
    ..close();
  canvas.drawPath(path8, Paint()..color = background);
  canvas.drawPath(
    path8,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector43(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(90.0, 136.0), width: 110.0, height: 32.0),
    );
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(60.0, 26.0)
    ..lineTo(60.0, 55.0)
    ..lineTo(33.0, 111.0)
    ..cubicTo(23.0, 136.0, 127.0, 145.0, 128.0, 114.0)
    ..lineTo(100.0, 55.0)
    ..lineTo(100.0, 26.0)
    ..close();
  canvas.drawPath(path1, Paint()..color = background);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(80.0, 26.0), width: 50.0, height: 22.0),
    );
  canvas.drawPath(path2, Paint()..color = background);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(80.0, 24.0), width: 32.0, height: 10.0),
    );
  canvas.drawPath(path3, Paint()..color = color);
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..moveTo(47.0, 93.0)
    ..lineTo(37.0, 116.0)
    ..cubicTo(34.0, 132.0, 124.0, 138.0, 124.0, 115.0)
    ..lineTo(112.0, 90.0)
    ..close();
  canvas.drawPath(path4, Paint()..color = color);
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path5 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(80.0, 92.0), width: 64.0, height: 24.0),
    );
  canvas.drawPath(path5, Paint()..color = background);
  canvas.drawPath(
    path5,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(
      Rect.fromCenter(center: Offset(80.0, 92.0), width: 38.0, height: 12.0),
    );
  canvas.drawPath(path6, Paint()..color = color);
  canvas.drawPath(
    path6,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path7 = Path()
    ..addOval(Rect.fromCircle(center: Offset(60.0, 116.0), radius: 4.0));
  canvas.drawPath(path7, Paint()..color = background);
  canvas.restore();
  canvas.save();
  final path8 = Path()
    ..addOval(Rect.fromCircle(center: Offset(94.0, 120.0), radius: 2.0));
  canvas.drawPath(path8, Paint()..color = background);
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path9 = Path()
    ..addOval(Rect.fromCircle(center: Offset(117.0, 52.0), radius: 3.0));
  canvas.drawPath(path9, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path10 = Path()
    ..addOval(Rect.fromCircle(center: Offset(39.0, 54.0), radius: 2.0));
  canvas.drawPath(path10, Paint()..color = color);
  canvas.restore();
  canvas.restore();
  canvas.restore();
}

void drawVector44(Canvas canvas, Color color, Color background) {
  canvas.save();
  canvas.save();
  final path0 = Path()
    ..moveTo(33.0, 127.0)
    ..lineTo(86.0, 107.0)
    ..lineTo(135.0, 131.0)
    ..lineTo(82.0, 153.0)
    ..close();
  canvas.drawPath(path0, Paint()..color = color);
  canvas.restore();
  canvas.save();
  canvas.save();
  final path1 = Path()
    ..moveTo(38.0, 66.0)
    ..lineTo(83.0, 13.0)
    ..lineTo(125.0, 64.0)
    ..lineTo(82.0, 139.0)
    ..close();
  canvas.drawPath(path1, Paint()..color = background);
  canvas.drawPath(
    path1,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path2 = Path()
    ..moveTo(83.0, 13.0)
    ..lineTo(66.0, 63.0)
    ..lineTo(82.0, 139.0)
    ..lineTo(101.0, 66.0)
    ..close();
  canvas.drawPath(path2, Paint()..color = background);
  canvas.drawPath(
    path2,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path3 = Path()
    ..moveTo(38.0, 66.0)
    ..lineTo(66.0, 63.0)
    ..lineTo(101.0, 66.0)
    ..lineTo(125.0, 64.0)
    ..lineTo(82.0, 139.0)
    ..lineTo(101.0, 66.0)
    ..close();
  canvas.drawPath(path3, Paint()..color = color);
  canvas.drawPath(
    path3,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.save();
  final path4 = Path()
    ..moveTo(38.0, 66.0)
    ..lineTo(66.0, 63.0)
    ..lineTo(82.0, 139.0);
  canvas.drawPath(
    path4,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.restore();
  canvas.restore();
  canvas.save();
  canvas.save();
  final path5 = Path()
    ..moveTo(27.0, 27.0)
    ..lineTo(30.0, 36.0)
    ..lineTo(39.0, 39.0)
    ..lineTo(30.0, 42.0)
    ..lineTo(27.0, 51.0)
    ..lineTo(24.0, 42.0)
    ..lineTo(15.0, 39.0)
    ..lineTo(24.0, 36.0)
    ..close()
    ..moveTo(130.0, 92.0)
    ..lineTo(133.0, 100.0)
    ..lineTo(141.0, 103.0)
    ..lineTo(133.0, 106.0)
    ..lineTo(130.0, 114.0)
    ..lineTo(127.0, 106.0)
    ..lineTo(119.0, 103.0)
    ..lineTo(127.0, 100.0)
    ..close();
  canvas.drawPath(path5, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path6 = Path()
    ..addOval(Rect.fromCircle(center: Offset(124.0, 29.0), radius: 2.5));
  canvas.drawPath(path6, Paint()..color = color);
  canvas.restore();
  canvas.save();
  final path7 = Path()
    ..addOval(Rect.fromCircle(center: Offset(20.0, 99.0), radius: 2.0));
  canvas.drawPath(path7, Paint()..color = color);
  canvas.restore();
  canvas.restore();
  canvas.restore();
}
