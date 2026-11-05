# Растровые размеры логотипа из той же геометрии, что docs/assets/brand/app-icon.svg.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
$iconRoot = Join-Path $projectRoot 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
$cream = [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#f2efe5'))
$graphite = [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#242722'))
$stroke = [Drawing.Pen]::new($graphite, 7)
$stroke.StartCap = $stroke.EndCap = [Drawing.Drawing2D.LineCap]::Round
$stroke.LineJoin = [Drawing.Drawing2D.LineJoin]::Round
$flame = [Drawing.Drawing2D.GraphicsPath]::new()
$flame.AddBezier(81,186,37,173,13,141,18,108)
$flame.AddBezier(18,108,22,83,42,70,43,41)
$flame.AddBezier(43,41,60,51,63,65,62,76)
$flame.AddBezier(62,76,86,55,89,25,85,5)
$flame.AddBezier(85,5,120,29,135,58,129,84)
$flame.AddBezier(129,84,139,78,145,67,147,56)
$flame.AddBezier(147,56,170,106,160,163,81,186)
$flame.CloseFigure()
foreach ($size in @(16,32,64,128,256,512,1024)) {
    $bitmap = [Drawing.Bitmap]::new($size, $size)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.ScaleTransform($size / 256.0, $size / 256.0)
    $background = [Drawing.Drawing2D.GraphicsPath]::new()
    foreach ($arc in @(@(8,8,180), @(116,8,270), @(116,116,0), @(8,116,90))) {
        $background.AddArc($arc[0], $arc[1], 132, 132, $arc[2], 90)
    }
    $background.CloseFigure()
    $graphics.FillPath($graphite, $background)
    $graphics.TranslateTransform(48,28)
    $graphics.FillPath($cream, $flame)
    foreach ($segment in @(@(80,160,80,106), @(80,131,58,112), @(80,116,104,92), @(80,145,105,125))) {
        $graphics.DrawLine($stroke, $segment[0], $segment[1], $segment[2], $segment[3])
    }
    foreach ($circle in @(@(80,99,7), @(52,106,6), @(110,85,7), @(111,119,6))) {
        $radius = $circle[2]
        $graphics.DrawEllipse($stroke, $circle[0]-$radius, $circle[1]-$radius, 2*$radius, 2*$radius)
    }
    $bitmap.Save((Join-Path $iconRoot "app_icon_$size.png"), [Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose(); $bitmap.Dispose(); $background.Dispose()
}
$stroke.Dispose(); $cream.Dispose(); $graphite.Dispose(); $flame.Dispose()
# ICO поддерживает несколько PNG-размеров без стороннего конвертера.
$iconFile = [IO.BinaryWriter]::new([IO.File]::Create((Join-Path $projectRoot 'windows/runner/resources/app_icon.ico')))
$sizes = @(16,32,64,128,256)
$iconFile.Write([UInt16]0); $iconFile.Write([UInt16]1); $iconFile.Write([UInt16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
foreach ($size in $sizes) {
    $bytes = [IO.File]::ReadAllBytes((Join-Path $iconRoot "app_icon_$size.png"))
    $dimension = if ($size -eq 256) { 0 } else { $size }
    $iconFile.Write([Byte]$dimension); $iconFile.Write([Byte]$dimension)
    $iconFile.Write([UInt16]0); $iconFile.Write([UInt16]1); $iconFile.Write([UInt16]32)
    $iconFile.Write([UInt32]$bytes.Length); $iconFile.Write([UInt32]$offset)
    $offset += $bytes.Length
}
foreach ($size in $sizes) { $iconFile.Write([IO.File]::ReadAllBytes((Join-Path $iconRoot "app_icon_$size.png"))) }
$iconFile.Dispose()
