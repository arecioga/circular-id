import AppKit
import CoreGraphics
import Foundation

struct VideoSpec {
    let width: Int
    let height: Int
    let fps: Int32
    let duration: Double
}

enum VideoBuildError: Error, CustomStringConvertible {
    case image(String)
    case context
    case writer(String)

    var description: String {
        switch self {
        case .image(let path): return "No se pudo abrir la imagen: \(path)"
        case .context: return "No se pudo crear el contexto gráfico."
        case .writer(let message): return "Error de codificación: \(message)"
        }
    }
}

let ink = NSColor(calibratedRed: 12 / 255, green: 27 / 255, blue: 51 / 255, alpha: 1)
let mint = NSColor(calibratedRed: 46 / 255, green: 230 / 255, blue: 166 / 255, alpha: 1)
let blue = NSColor(calibratedRed: 43 / 255, green: 127 / 255, blue: 1, alpha: 1)
let white = NSColor.white
let cloud = NSColor(calibratedRed: 244 / 255, green: 247 / 255, blue: 246 / 255, alpha: 1)
let warm = NSColor(calibratedRed: 246 / 255, green: 239 / 255, blue: 229 / 255, alpha: 1)
let slate = NSColor(calibratedRed: 82 / 255, green: 97 / 255, blue: 118 / 255, alpha: 1)

func cg(_ color: NSColor, alpha: CGFloat = 1) -> CGColor {
    color.withAlphaComponent(alpha).cgColor
}

func loadImage(_ path: String) throws -> CGImage {
    guard let image = NSImage(contentsOfFile: path),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw VideoBuildError.image(path)
    }
    return cgImage
}

func ease(_ value: Double) -> CGFloat {
    let x = max(0, min(1, value))
    return CGFloat(x * x * (3 - 2 * x))
}

func localProgress(_ time: Double, start: Double, end: Double) -> CGFloat {
    ease((time - start) / max(0.001, end - start))
}

func sceneAlpha(_ time: Double, start: Double, end: Double, fade: Double = 0.35) -> CGFloat {
    if time < start || time > end { return 0 }
    if time < start + fade { return ease((time - start) / fade) }
    if time > end - fade { return ease((end - time) / fade) }
    return 1
}

func fill(_ ctx: CGContext, _ color: NSColor, _ rect: CGRect) {
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
}

func roundedRect(_ ctx: CGContext, rect: CGRect, radius: CGFloat, fillColor: NSColor, strokeColor: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(fillColor.cgColor)
    ctx.fillPath()
    if let strokeColor {
        ctx.addPath(path)
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.strokePath()
    }
}

func drawText(
    _ ctx: CGContext,
    _ text: String,
    rect: CGRect,
    size: CGFloat,
    weight: NSFont.Weight = .regular,
    color: NSColor = white,
    alignment: NSTextAlignment = .left,
    lineSpacing: CGFloat = 0,
    alpha: CGFloat = 1
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = lineSpacing
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color.withAlphaComponent(alpha),
        .paragraphStyle: paragraph,
    ]
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    (text as NSString).draw(in: rect, withAttributes: attributes)
    NSGraphicsContext.restoreGraphicsState()
}

func drawTrackingText(_ ctx: CGContext, _ text: String, at point: CGPoint, size: CGFloat, color: NSColor, spacing: CGFloat, alpha: CGFloat = 1) {
    var x = point.x
    for scalar in text.unicodeScalars {
        let character = String(scalar)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: .bold),
            .foregroundColor: color.withAlphaComponent(alpha),
        ]
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        let width = (character as NSString).size(withAttributes: attributes).width
        (character as NSString).draw(at: CGPoint(x: x, y: point.y), withAttributes: attributes)
        NSGraphicsContext.restoreGraphicsState()
        x += width + spacing
    }
}

func drawAspectFill(_ ctx: CGContext, image: CGImage, rect: CGRect, zoom: CGFloat = 1, offset: CGPoint = .zero, alpha: CGFloat = 1) {
    let imageWidth = CGFloat(image.width)
    let imageHeight = CGFloat(image.height)
    let scale = max(rect.width / imageWidth, rect.height / imageHeight) * zoom
    let drawWidth = imageWidth * scale
    let drawHeight = imageHeight * scale
    let drawRect = CGRect(
        x: rect.midX - drawWidth / 2 + offset.x,
        y: rect.midY - drawHeight / 2 + offset.y,
        width: drawWidth,
        height: drawHeight
    )
    ctx.saveGState()
    ctx.clip(to: rect)
    ctx.setAlpha(alpha)
    ctx.draw(image, in: drawRect)
    ctx.restoreGState()
}

func drawGradient(_ ctx: CGContext, rect: CGRect, colors: [NSColor], locations: [CGFloat], start: CGPoint, end: CGPoint) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors.map(\.cgColor) as CFArray, locations: locations) else { return }
    ctx.saveGState()
    ctx.clip(to: rect)
    ctx.drawLinearGradient(gradient, start: start, end: end, options: [])
    ctx.restoreGState()
}

func drawBrand(_ ctx: CGContext, avatar: CGImage, x: CGFloat, y: CGFloat, scale: CGFloat = 1, darkText: Bool = false, alpha: CGFloat = 1) {
    let size = 64 * scale
    ctx.saveGState()
    ctx.setAlpha(alpha)
    ctx.draw(avatar, in: CGRect(x: x, y: y, width: size, height: size))
    ctx.restoreGState()
    drawTrackingText(ctx, "CIRCULAR", at: CGPoint(x: x + size + 18 * scale, y: y + 17 * scale), size: 25 * scale, color: darkText ? ink : white, spacing: 1.2 * scale, alpha: alpha)
    drawTrackingText(ctx, "ID", at: CGPoint(x: x + size + 165 * scale, y: y + 17 * scale), size: 25 * scale, color: mint, spacing: 1.2 * scale, alpha: alpha)
}

func drawFooter(_ ctx: CGContext, width: CGFloat, y: CGFloat, network: String, alpha: CGFloat = 1, dark: Bool = false) {
    drawTrackingText(ctx, network, at: CGPoint(x: 70, y: y), size: 18, color: dark ? ink : white, spacing: 1, alpha: alpha)
    drawTrackingText(ctx, "#DCOM2526", at: CGPoint(x: width - 245, y: y), size: 18, color: dark ? blue : mint, spacing: 1, alpha: alpha)
}

func drawProgress(_ ctx: CGContext, width: CGFloat, y: CGFloat, active: Int, count: Int = 4, alpha: CGFloat = 1, dark: Bool = false) {
    let gap: CGFloat = 12
    let totalWidth = width - 140
    let segmentWidth = (totalWidth - CGFloat(count - 1) * gap) / CGFloat(count)
    for index in 0..<count {
        let rect = CGRect(x: 70 + CGFloat(index) * (segmentWidth + gap), y: y, width: segmentWidth, height: 6)
        roundedRect(ctx, rect: rect, radius: 3, fillColor: index <= active ? mint.withAlphaComponent(alpha) : (dark ? ink : white).withAlphaComponent(0.25 * alpha))
    }
}

func drawScanRings(_ ctx: CGContext, center: CGPoint, time: Double, alpha: CGFloat) {
    for index in 0..<3 {
        let phase = (time * 0.75 + Double(index) * 0.28).truncatingRemainder(dividingBy: 1)
        let radius = 95 + CGFloat(phase) * 150
        ctx.saveGState()
        ctx.setStrokeColor(cg(mint, alpha: (1 - CGFloat(phase)) * alpha))
        ctx.setLineWidth(7)
        ctx.strokeEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        ctx.restoreGState()
    }
}

func drawPhone(_ ctx: CGContext, rect: CGRect, alpha: CGFloat, state: String) {
    ctx.saveGState()
    ctx.setAlpha(alpha)
    roundedRect(ctx, rect: rect, radius: 54, fillColor: ink, strokeColor: white.withAlphaComponent(0.35), lineWidth: 3)
    roundedRect(ctx, rect: rect.insetBy(dx: 18, dy: 18), radius: 39, fillColor: cloud)
    roundedRect(ctx, rect: CGRect(x: rect.midX - 70, y: rect.maxY - 42, width: 140, height: 12), radius: 6, fillColor: ink.withAlphaComponent(0.18))
    let content = rect.insetBy(dx: 55, dy: 95)
    drawTrackingText(ctx, "CIRCULAR ID", at: CGPoint(x: content.minX, y: content.maxY - 55), size: 21, color: ink, spacing: 1)
    let checkCenter = CGPoint(x: rect.midX, y: rect.midY + 105)
    ctx.setStrokeColor(mint.cgColor)
    ctx.setLineWidth(25)
    ctx.strokeEllipse(in: CGRect(x: checkCenter.x - 100, y: checkCenter.y - 100, width: 200, height: 200))
    drawText(ctx, "✓", rect: CGRect(x: checkCenter.x - 72, y: checkCenter.y - 77, width: 144, height: 150), size: 105, weight: .heavy, color: ink, alignment: .center)
    roundedRect(ctx, rect: CGRect(x: content.minX, y: rect.midY - 135, width: content.width, height: 74), radius: 37, fillColor: mint)
    drawText(ctx, state, rect: CGRect(x: content.minX + 18, y: rect.midY - 116, width: content.width - 36, height: 40), size: 24, weight: .bold, color: ink, alignment: .center)
    drawText(ctx, "Chaqueta · Colección 04", rect: CGRect(x: content.minX, y: rect.midY - 235, width: content.width, height: 50), size: 29, weight: .bold, color: ink, alignment: .center)
    drawText(ctx, "ID 040-871-ES", rect: CGRect(x: content.minX, y: rect.midY - 290, width: content.width, height: 38), size: 22, weight: .medium, color: slate, alignment: .center)
    ctx.restoreGState()
}

func drawServicePill(_ ctx: CGContext, rect: CGRect, number: String, title: String, alpha: CGFloat, dark: Bool = false) {
    ctx.saveGState()
    ctx.setAlpha(alpha)
    roundedRect(ctx, rect: rect, radius: 28, fillColor: dark ? white.withAlphaComponent(0.10) : white, strokeColor: dark ? white.withAlphaComponent(0.12) : ink.withAlphaComponent(0.08), lineWidth: 2)
    roundedRect(ctx, rect: CGRect(x: rect.minX + 20, y: rect.minY + 18, width: 78, height: rect.height - 36), radius: 20, fillColor: mint)
    drawText(ctx, number, rect: CGRect(x: rect.minX + 20, y: rect.minY + 31, width: 78, height: 44), size: 29, weight: .heavy, color: ink, alignment: .center)
    drawText(ctx, title, rect: CGRect(x: rect.minX + 126, y: rect.minY + 28, width: rect.width - 150, height: 52), size: 36, weight: .bold, color: dark ? white : ink)
    ctx.restoreGState()
}

func renderInstagram(_ ctx: CGContext, frame: Int, spec: VideoSpec, photo: CGImage, avatar: CGImage) {
    let t = Double(frame) / Double(spec.fps)
    let width = CGFloat(spec.width)
    let height = CGFloat(spec.height)
    let canvas = CGRect(x: 0, y: 0, width: width, height: height)
    fill(ctx, ink, canvas)
    let zoom = 1.08 + CGFloat(t / spec.duration) * 0.08
    let offset = CGPoint(x: -45 + CGFloat(t / spec.duration) * 85, y: -20)
    drawAspectFill(ctx, image: photo, rect: canvas, zoom: zoom, offset: offset)
    drawGradient(ctx, rect: canvas, colors: [ink.withAlphaComponent(0.92), ink.withAlphaComponent(0.46), ink.withAlphaComponent(0.78)], locations: [0, 0.52, 1], start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: height))

    let a1 = sceneAlpha(t, start: 0, end: 3.0, fade: 0.12)
    if a1 > 0 {
        let p = localProgress(t, start: 0, end: 3.0)
        ctx.saveGState(); ctx.setAlpha(a1)
        drawBrand(ctx, avatar: avatar, x: 72, y: height - 150, alpha: a1)
        roundedRect(ctx, rect: CGRect(x: 72, y: height - 270, width: 260, height: 54), radius: 27, fillColor: mint)
        drawTrackingText(ctx, "REEL · 15 S", at: CGPoint(x: 101, y: height - 253), size: 17, color: ink, spacing: 1.2)
        let slide = (1 - p) * -38
        drawText(ctx, "UNA PRENDA.\nUNA IDENTIDAD.", rect: CGRect(x: 72 + slide, y: 650, width: 900, height: 520), size: 108, weight: .heavy, color: white, lineSpacing: -8)
        drawText(ctx, "Una evidencia digital vinculada al registro de la marca.", rect: CGRect(x: 78 + slide, y: 520, width: 790, height: 100), size: 34, weight: .medium, color: white.withAlphaComponent(0.82), lineSpacing: 4)
        drawProgress(ctx, width: width, y: 175, active: 0, alpha: a1)
        drawFooter(ctx, width: width, y: 95, network: "INSTAGRAM · 01/04", alpha: a1)
        ctx.restoreGState()
    }

    let a2 = sceneAlpha(t, start: 3.0, end: 6.0, fade: 0.12)
    if a2 > 0 {
        let p = localProgress(t, start: 3.0, end: 6.0)
        ctx.saveGState(); ctx.setAlpha(a2)
        fill(ctx, ink.withAlphaComponent(0.42), canvas)
        drawBrand(ctx, avatar: avatar, x: 72, y: height - 150, alpha: a2)
        drawText(ctx, "ACERCA O\nESCANEA.", rect: CGRect(x: 72, y: height - 520, width: 900, height: 270), size: 92, weight: .heavy, color: white, lineSpacing: -6)
        let phoneRect = CGRect(x: 245, y: 340 + (1 - p) * -40, width: 590, height: 980)
        drawPhone(ctx, rect: phoneRect, alpha: a2, state: "LEYENDO ETIQUETA")
        drawScanRings(ctx, center: CGPoint(x: width / 2, y: 900), time: t, alpha: a2)
        drawProgress(ctx, width: width, y: 175, active: 1, alpha: a2)
        drawFooter(ctx, width: width, y: 95, network: "INSTAGRAM · 02/04", alpha: a2)
        ctx.restoreGState()
    }

    let a3 = sceneAlpha(t, start: 6.0, end: 11.0, fade: 0.12)
    if a3 > 0 {
        let p = localProgress(t, start: 6.0, end: 11.0)
        ctx.saveGState(); ctx.setAlpha(a3)
        fill(ctx, ink.withAlphaComponent(0.70), canvas)
        drawBrand(ctx, avatar: avatar, x: 72, y: height - 150, alpha: a3)
        drawText(ctx, "LA PANTALLA\nEXPLICA.", rect: CGRect(x: 72, y: height - 510, width: 900, height: 250), size: 87, weight: .heavy, color: white, lineSpacing: -5)
        let card = CGRect(x: 82, y: 440 + (1 - p) * -32, width: 916, height: 830)
        roundedRect(ctx, rect: card, radius: 55, fillColor: cloud)
        ctx.setStrokeColor(mint.cgColor); ctx.setLineWidth(26)
        ctx.strokeEllipse(in: CGRect(x: width / 2 - 112, y: 880, width: 224, height: 224))
        drawText(ctx, "✓", rect: CGRect(x: width / 2 - 86, y: 905, width: 172, height: 180), size: 125, weight: .heavy, color: ink, alignment: .center)
        drawTrackingText(ctx, "REGISTRO COINCIDENTE", at: CGPoint(x: 182, y: 775), size: 26, color: ink, spacing: 1.1)
        drawText(ctx, "La referencia consultada coincide con el registro mostrado por la marca.", rect: CGRect(x: 175, y: 635, width: 730, height: 120), size: 34, weight: .medium, color: slate, alignment: .center, lineSpacing: 5)
        roundedRect(ctx, rect: CGRect(x: 245, y: 515, width: 590, height: 78), radius: 39, fillColor: mint)
        drawText(ctx, "VER EVIDENCIAS", rect: CGRect(x: 260, y: 535, width: 560, height: 45), size: 27, weight: .bold, color: ink, alignment: .center)
        drawText(ctx, "Evidencia de registro · No es una garantía absoluta", rect: CGRect(x: 105, y: 365, width: 870, height: 50), size: 24, weight: .medium, color: white.withAlphaComponent(0.78), alignment: .center)
        drawProgress(ctx, width: width, y: 175, active: 2, alpha: a3)
        drawFooter(ctx, width: width, y: 95, network: "INSTAGRAM · 03/04", alpha: a3)
        ctx.restoreGState()
    }

    let a4 = sceneAlpha(t, start: 11.0, end: 15.0, fade: 0.12)
    if a4 > 0 {
        let p = localProgress(t, start: 11.0, end: 15.0)
        ctx.saveGState(); ctx.setAlpha(a4)
        fill(ctx, ink.withAlphaComponent(0.96), canvas)
        drawBrand(ctx, avatar: avatar, x: 72, y: height - 150, alpha: a4)
        drawText(ctx, "LA RELACIÓN\nCONTINÚA.", rect: CGRect(x: 72, y: height - 540, width: 900, height: 270), size: 94, weight: .heavy, color: white, lineSpacing: -6)
        drawText(ctx, "Más utilidad durante la vida de la prenda.", rect: CGRect(x: 76, y: height - 620, width: 840, height: 60), size: 32, weight: .medium, color: white.withAlphaComponent(0.72))
        let rise = (1 - p) * -45
        drawServicePill(ctx, rect: CGRect(x: 82, y: 890 + rise, width: 916, height: 120), number: "01", title: "Cuidados", alpha: a4, dark: true)
        drawServicePill(ctx, rect: CGRect(x: 82, y: 735 + rise, width: 916, height: 120), number: "02", title: "Garantía", alpha: a4, dark: true)
        drawServicePill(ctx, rect: CGRect(x: 82, y: 580 + rise, width: 916, height: 120), number: "03", title: "Reventa", alpha: a4, dark: true)
        roundedRect(ctx, rect: CGRect(x: 82, y: 385, width: 916, height: 100), radius: 50, fillColor: mint)
        drawText(ctx, "ACERCA. ESCANEA. COMPRUEBA.", rect: CGRect(x: 110, y: 416, width: 860, height: 45), size: 28, weight: .heavy, color: ink, alignment: .center)
        drawProgress(ctx, width: width, y: 175, active: 3, alpha: a4)
        drawFooter(ctx, width: width, y: 95, network: "INSTAGRAM · 04/04", alpha: a4)
        ctx.restoreGState()
    }
}

func renderLinkedIn(_ ctx: CGContext, frame: Int, spec: VideoSpec, photo: CGImage, avatar: CGImage) {
    let t = Double(frame) / Double(spec.fps)
    let width = CGFloat(spec.width)
    let height = CGFloat(spec.height)
    let canvas = CGRect(x: 0, y: 0, width: width, height: height)
    fill(ctx, ink, canvas)

    let a1 = sceneAlpha(t, start: 0, end: 3.0, fade: 0.12)
    if a1 > 0 {
        let p = localProgress(t, start: 0, end: 3.0)
        ctx.saveGState(); ctx.setAlpha(a1)
        fill(ctx, ink, CGRect(x: 0, y: 0, width: 690, height: height))
        drawAspectFill(ctx, image: photo, rect: CGRect(x: 690, y: 0, width: 390, height: height), zoom: 1.12 + p * 0.07, offset: CGPoint(x: -40, y: 0))
        drawGradient(ctx, rect: CGRect(x: 620, y: 0, width: 270, height: height), colors: [ink, ink.withAlphaComponent(0)], locations: [0, 1], start: CGPoint(x: 620, y: 0), end: CGPoint(x: 890, y: 0))
        drawBrand(ctx, avatar: avatar, x: 64, y: height - 126, scale: 0.82, alpha: a1)
        drawTrackingText(ctx, "PASO 01", at: CGPoint(x: 68, y: height - 270), size: 19, color: mint, spacing: 1.5)
        drawText(ctx, "LA MARCA\nREGISTRA.", rect: CGRect(x: 64, y: 555, width: 590, height: 330), size: 87, weight: .heavy, color: white, lineSpacing: -6)
        drawText(ctx, "Una unidad o lote se vincula con un identificador y sus datos esenciales.", rect: CGRect(x: 68, y: 405, width: 540, height: 130), size: 30, weight: .medium, color: white.withAlphaComponent(0.72), lineSpacing: 5)
        drawProgress(ctx, width: width, y: 118, active: 0, alpha: a1)
        drawFooter(ctx, width: width, y: 55, network: "LINKEDIN · 01/04", alpha: a1)
        ctx.restoreGState()
    }

    let a2 = sceneAlpha(t, start: 3.0, end: 6.0, fade: 0.12)
    if a2 > 0 {
        let p = localProgress(t, start: 3.0, end: 6.0)
        ctx.saveGState(); ctx.setAlpha(a2)
        drawAspectFill(ctx, image: photo, rect: canvas, zoom: 1.12 + p * 0.05, offset: CGPoint(x: 45, y: -25))
        fill(ctx, ink.withAlphaComponent(0.70), canvas)
        drawBrand(ctx, avatar: avatar, x: 64, y: height - 126, scale: 0.82, alpha: a2)
        drawTrackingText(ctx, "PASO 02", at: CGPoint(x: 68, y: height - 250), size: 19, color: mint, spacing: 1.5)
        drawText(ctx, "EL CLIENTE\nCONSULTA.", rect: CGRect(x: 64, y: 825, width: 750, height: 220), size: 72, weight: .heavy, color: white, lineSpacing: -5)
        let phoneRect = CGRect(x: 330, y: 205 + (1 - p) * -35, width: 470, height: 720)
        drawPhone(ctx, rect: phoneRect, alpha: a2, state: "LEYENDO ETIQUETA")
        drawScanRings(ctx, center: CGPoint(x: 565, y: 590), time: t, alpha: a2)
        drawProgress(ctx, width: width, y: 118, active: 1, alpha: a2)
        drawFooter(ctx, width: width, y: 55, network: "LINKEDIN · 02/04", alpha: a2)
        ctx.restoreGState()
    }

    let a3 = sceneAlpha(t, start: 6.0, end: 9.0, fade: 0.12)
    if a3 > 0 {
        let p = localProgress(t, start: 6.0, end: 9.0)
        ctx.saveGState(); ctx.setAlpha(a3)
        fill(ctx, ink, canvas)
        drawBrand(ctx, avatar: avatar, x: 64, y: height - 126, scale: 0.82, alpha: a3)
        drawTrackingText(ctx, "PASO 03", at: CGPoint(x: 68, y: height - 250), size: 19, color: mint, spacing: 1.5)
        drawText(ctx, "LA PANTALLA\nEXPLICA.", rect: CGRect(x: 64, y: 825, width: 780, height: 220), size: 72, weight: .heavy, color: white, lineSpacing: -5)
        let card = CGRect(x: 64, y: 285 + (1 - p) * -30, width: 952, height: 470)
        roundedRect(ctx, rect: card, radius: 38, fillColor: white)
        ctx.setStrokeColor(mint.cgColor); ctx.setLineWidth(20)
        ctx.strokeEllipse(in: CGRect(x: 115, y: 475, width: 170, height: 170))
        drawText(ctx, "✓", rect: CGRect(x: 130, y: 492, width: 140, height: 140), size: 100, weight: .heavy, color: ink, alignment: .center)
        drawTrackingText(ctx, "REGISTRO COINCIDENTE", at: CGPoint(x: 340, y: 585), size: 25, color: ink, spacing: 1)
        drawText(ctx, "El identificador consultado coincide con el registro mostrado.", rect: CGRect(x: 340, y: 455, width: 590, height: 110), size: 30, weight: .medium, color: slate, lineSpacing: 4)
        roundedRect(ctx, rect: CGRect(x: 340, y: 350, width: 540, height: 70), radius: 35, fillColor: mint)
        drawText(ctx, "VER EVIDENCIAS", rect: CGRect(x: 360, y: 368, width: 500, height: 40), size: 24, weight: .bold, color: ink, alignment: .center)
        drawText(ctx, "Evidencia de registro · No garantiza por sí sola toda la autenticidad", rect: CGRect(x: 70, y: 205, width: 940, height: 45), size: 21, weight: .medium, color: white.withAlphaComponent(0.68), alignment: .center)
        drawProgress(ctx, width: width, y: 118, active: 2, alpha: a3)
        drawFooter(ctx, width: width, y: 55, network: "LINKEDIN · 03/04", alpha: a3)
        ctx.restoreGState()
    }

    let a4 = sceneAlpha(t, start: 9.0, end: 12.0, fade: 0.12)
    if a4 > 0 {
        let p = localProgress(t, start: 9.0, end: 12.0)
        ctx.saveGState(); ctx.setAlpha(a4)
        fill(ctx, warm, canvas)
        drawBrand(ctx, avatar: avatar, x: 64, y: height - 126, scale: 0.82, darkText: true, alpha: a4)
        drawTrackingText(ctx, "PASO 04", at: CGPoint(x: 68, y: height - 250), size: 19, color: blue, spacing: 1.5)
        drawText(ctx, "LA RELACIÓN\nCONTINÚA.", rect: CGRect(x: 64, y: 840, width: 820, height: 220), size: 72, weight: .heavy, color: ink, lineSpacing: -5)
        drawText(ctx, "La etiqueta también puede aportar valor después de la compra.", rect: CGRect(x: 68, y: 750, width: 780, height: 70), size: 28, weight: .medium, color: slate)
        let rise = (1 - p) * -35
        drawServicePill(ctx, rect: CGRect(x: 64, y: 570 + rise, width: 952, height: 105), number: "01", title: "Cuidados", alpha: a4)
        drawServicePill(ctx, rect: CGRect(x: 64, y: 435 + rise, width: 952, height: 105), number: "02", title: "Garantía", alpha: a4)
        drawServicePill(ctx, rect: CGRect(x: 64, y: 300 + rise, width: 952, height: 105), number: "03", title: "Reventa", alpha: a4)
        drawProgress(ctx, width: width, y: 118, active: 3, alpha: a4, dark: true)
        drawFooter(ctx, width: width, y: 55, network: "LINKEDIN · 04/04", alpha: a4, dark: true)
        ctx.restoreGState()
    }
}

func buildVideo(spec: VideoSpec, outputURL: URL, ffmpegPath: String, render: @escaping (CGContext, Int, VideoSpec) -> Void) throws {
    try? FileManager.default.removeItem(at: outputURL)
    let process = Process()
    let inputPipe = Pipe()
    let errorPipe = Pipe()
    process.executableURL = URL(fileURLWithPath: ffmpegPath)
    process.arguments = [
        "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo",
        "-pixel_format", "bgra",
        "-video_size", "\(spec.width)x\(spec.height)",
        "-framerate", "\(spec.fps)",
        "-i", "pipe:0",
        "-an",
        "-c:v", "libx264",
        "-preset", "fast",
        "-crf", "20",
        "-profile:v", "high",
        "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        "-metadata", "title=Circular ID · Proyecto académico",
        outputURL.path,
    ]
    process.standardInput = inputPipe
    process.standardError = errorPipe
    try process.run()

    let totalFrames = Int(spec.duration * Double(spec.fps))
    for frame in 0..<totalFrames {
        try autoreleasepool {
            var frameData = Data(count: spec.width * spec.height * 4)
            let rendered = frameData.withUnsafeMutableBytes { bytes -> Bool in
                guard let baseAddress = bytes.baseAddress,
                      let context = CGContext(
                    data: baseAddress,
                    width: spec.width,
                    height: spec.height,
                    bitsPerComponent: 8,
                    bytesPerRow: spec.width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
                      ) else { return false }
                context.setShouldAntialias(true)
                context.setAllowsAntialiasing(true)
                render(context, frame, spec)
                return true
            }
            guard rendered else { throw VideoBuildError.context }
            inputPipe.fileHandleForWriting.write(frameData)
        }
    }
    inputPipe.fileHandleForWriting.closeFile()
    process.waitUntilExit()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorMessage = String(data: errorData, encoding: .utf8) ?? ""
    guard process.terminationStatus == 0 else { throw VideoBuildError.writer(errorMessage.isEmpty ? "FFmpeg terminó con código \(process.terminationStatus)." : errorMessage) }
}

let root = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath
let ffmpegPath = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "/usr/local/bin/ffmpeg"
let photoPath = root + "/social/assets/foto-prenda-nfc-v1.png"
let avatarPath = root + "/social/assets/avatar-circular-id.png"
let instagramOutput = URL(fileURLWithPath: root + "/social/instagram/publicables/ig-03-reel-circular-id.mp4")
let linkedInOutput = URL(fileURLWithPath: root + "/social/linkedin/publicables/li-03-video-circular-id.mp4")

do {
    let photo = try loadImage(photoPath)
    let avatar = try loadImage(avatarPath)
    let instagram = VideoSpec(width: 1080, height: 1920, fps: 30, duration: 15)
    let linkedIn = VideoSpec(width: 1080, height: 1350, fps: 30, duration: 12)

    print("Generando Reel de Instagram…")
    try buildVideo(spec: instagram, outputURL: instagramOutput, ffmpegPath: ffmpegPath) { context, frame, spec in
        renderInstagram(context, frame: frame, spec: spec, photo: photo, avatar: avatar)
    }
    print("Generando vídeo de LinkedIn…")
    try buildVideo(spec: linkedIn, outputURL: linkedInOutput, ffmpegPath: ffmpegPath) { context, frame, spec in
        renderLinkedIn(context, frame: frame, spec: spec, photo: photo, avatar: avatar)
    }

    print("Vídeos generados correctamente. Las hojas de revisión se extraen con FFmpeg.")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
