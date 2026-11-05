"""Перенести геометрию SVG в нативные Path Flutter без сетевых шрифтов и пакетов."""

import math
from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def number(value):
    return str(round(float(value), 6))


class SvgPath:
    def __init__(self):
        self.x = self.y = 0.0
        self.start = (0.0, 0.0)
        self.control = None
        self.output = []

    def point(self, a, b, relative):
        return (a + self.x, b + self.y) if relative else (a, b)

    def line(self, kind, values, relative):
        x, y = self.point(*values, relative)
        method = 'moveTo' if kind == 'M' else 'lineTo'
        self.output.append(f'..{method}({number(x)}, {number(y)})')
        self.x, self.y = x, y
        if kind == 'M': self.start = (x, y)

    def axis(self, kind, values, relative):
        if kind == 'H': self.x = values[0] + (self.x if relative else 0)
        else: self.y = values[0] + (self.y if relative else 0)
        self.output.append(f'..lineTo({number(self.x)}, {number(self.y)})')

    def curve(self, kind, values, relative):
        first = self.point(*values[:2], relative) if kind == 'C' else self.reflected()
        second = self.point(*values[-4:-2], relative)
        end = self.point(*values[-2:], relative)
        coords = ', '.join(number(v) for point in (first, second, end) for v in point)
        self.output.append('..cubicTo(' + coords + ')')
        self.control, (self.x, self.y) = second, end

    def reflected(self):
        if self.control is None: return self.x, self.y
        return 2 * self.x - self.control[0], 2 * self.y - self.control[1]

    def arc(self, values, relative):
        rx, ry, rotation, large, sweep, a, b = values
        self.x, self.y = self.point(a, b, relative)
        self.output.append(f'..arcToPoint(Offset({number(self.x)}, {number(self.y)}), radius: Radius.elliptical({number(rx)}, {number(ry)}), rotation: {number(math.radians(rotation))}, largeArc: {str(bool(large)).lower()}, clockwise: {str(bool(sweep)).lower()})')

    def append(self, command, values):
        kind, relative = command.upper(), command.islower()
        if kind in {'M', 'L'}: self.line(kind, values, relative)
        elif kind in {'H', 'V'}: self.axis(kind, values, relative)
        elif kind in {'C', 'S'}: self.curve(kind, values, relative)
        elif kind == 'A': self.arc(values, relative)
        elif kind == 'Z':
            self.output.append('..close()')
            self.x, self.y = self.start
        if kind not in {'C', 'S'}: self.control = None


def path_code(source):
    tokens = re.findall(r'[MLHVCSAZmlhvcsaz]|[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?', source)
    count = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'A': 7, 'Z': 0}
    path, index, command = SvgPath(), 0, ''
    while index < len(tokens):
        if tokens[index].isalpha():
            command = tokens[index]
            index += 1
        size = count[command.upper()]
        values = [float(value) for value in tokens[index:index + size]]
        index += size
        path.append(command, values)
        if command.upper() == 'M': command = 'l' if command.islower() else 'L'
    return 'Path()' + ''.join(path.output)


def color(value, opacity):
    if value.startswith('var('): value = re.search(r'#[a-fA-F0-9]+', value)[0]
    if value.startswith('#') and len(value) == 4: value = '#' + ''.join(c*2 for c in value[1:])
    base = 'color' if value == 'currentColor' else f'const Color(0xFF{value.lstrip("#").upper()})'
    return base if opacity == 1 else f'{base}.withValues(alpha: {number(opacity)})'


def shape(element):
    values = element.attrib
    tag = element.tag.split('}')[-1]
    n = lambda name, default=0: number(values.get(name, default))
    if tag == 'path': return path_code(values['d'])
    if tag == 'circle': return f'Path()..addOval(Rect.fromCircle(center: Offset({n("cx")}, {n("cy")}), radius: {n("r")}))'
    if tag == 'ellipse': return f'Path()..addOval(Rect.fromCenter(center: Offset({n("cx")}, {n("cy")}), width: {number(2*float(values["rx"]))}, height: {number(2*float(values["ry"]))}))'
    rectangle = f'Rect.fromLTWH({n("x")}, {n("y")}, {n("width")}, {n("height")})'
    return f'Path()..addRRect(RRect.fromRectAndCorners({rectangle}, topLeft: Radius.elliptical({n("rx")}, {n("ry", values.get("rx", 0))}), topRight: Radius.elliptical({n("rx")}, {n("ry", values.get("rx", 0))}), bottomLeft: Radius.elliptical({n("rx")}, {n("ry", values.get("rx", 0))}), bottomRight: Radius.elliptical({n("rx")}, {n("ry", values.get("rx", 0))})))'


def transforms(value):
    output = []
    for name, arguments in re.findall(r'(\w+)\(([^)]*)\)', value):
        args = [float(v) for v in re.findall(r'[-+]?\d*\.?\d+', arguments)]
        if name == 'translate': output.append(f'canvas.translate({number(args[0])}, {number(args[1] if len(args)>1 else 0)});')
        elif name == 'scale': output.append(f'canvas.scale({number(args[0])}, {number(args[-1])});')
        elif name == 'rotate':
            x, y = args[1:] if len(args) == 3 else (0, 0)
            output.extend([f'canvas.translate({number(x)}, {number(y)});', f'canvas.rotate({number(math.radians(args[0]))});', f'canvas.translate({number(-x)}, {number(-y)});'])
    return output


def draw(element, inherited, output, counter):
    tag = element.tag.split('}')[-1]
    if tag == 'title': return
    style = {**inherited, **element.attrib}
    style['opacity'] = float(inherited.get('opacity', 1)) * float(element.get('opacity', 1))
    output.append('canvas.save();')
    output.extend(transforms(element.get('transform', '')))
    if tag in {'svg', 'g'}:
        for child in element: draw(child, style, output, counter)
    else:
        name = f'path{counter[0]}'
        counter[0] += 1
        output.append(f'final {name} = {shape(element)};')
        for key in ('fill', 'stroke'):
            value = style.get(key, 'black' if key == 'fill' else 'none')
            if value == 'none': continue
            if value == 'black': value = '#000000'
            paint = f'Paint()..color = {color(value, style["opacity"])}'
            if key == 'stroke': paint += f'..style = PaintingStyle.stroke..strokeWidth = {number(style.get("stroke-width", 1))}..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round'
            output.append(f'canvas.drawPath({name}, {paint});')
    output.append('canvas.restore();')


def main():
    files = sorted((ROOT / 'docs/assets').rglob('*.svg'))
    header = ["// Сгенерировано tool/generate_vectors.py из SVG; правьте исходные SVG.", "import 'dart:ui';", "typedef VectorDrawing = ({Size size, void Function(Canvas, Color) draw});", 'final vectorDrawings = <String, VectorDrawing>{']
    functions = []
    for index, file in enumerate(files):
        tree = ET.parse(file).getroot()
        _, _, width, height = tree.get('viewBox').split()
        key = file.relative_to(ROOT / 'docs/assets').with_suffix('').as_posix()
        header.append(f"'{key}': (size: Size({width}, {height}), draw: drawVector{index}),")
        body = []
        draw(tree, {}, body, [0])
        functions.append(f'void drawVector{index}(Canvas canvas, Color color) {{\n' + '\n'.join(body) + '\n}')
    output = ROOT / 'lib/ui/core/vector_drawings.dart'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text('\n'.join(header + ['};'] + functions), encoding='utf-8')


if __name__ == '__main__': main()
