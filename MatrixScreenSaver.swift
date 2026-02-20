import ScreenSaver
import AppKit

@objc(MatrixScreenSaverView)
final class MatrixScreenSaverView: ScreenSaverView {

    private let colSize:     CGFloat = 14
    private let fadeAlpha:   CGFloat = 0.05
    private let speedMin:    Double  = 0.5
    private let speedMax:    Double  = 2.0
    private let resetChance: Double  = 0.3

    private let headColor = NSColor(calibratedHue: 160/360, saturation: 0.1, brightness: 0.90, alpha: 1)
    private let glyphs    = Array("アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789")

    private var numCols:  Int = 0
    private var drops:    [Double] = []
    private var speeds:   [Double] = []
    private var accumRep: NSBitmapImageRep?
    private var repW: Int = 0
    private var repH: Int = 0
    private var frameCount = 0

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 20.0
        NSLog("MatrixSaver init frame=%@ isPreview=%d", NSStringFromRect(frame), isPreview ? 1 : 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 20.0
        NSLog("MatrixSaver init(coder)")
    }

    override func startAnimation() {
        super.startAnimation()
        NSLog("MatrixSaver startAnimation bounds=%@ isAnimating=%d", NSStringFromRect(bounds), isAnimating ? 1 : 0)
    }

    private func setup() {
        repW = max(1, Int(bounds.width))
        repH = max(1, Int(bounds.height))
        numCols = repW / Int(colSize)
        NSLog("MatrixSaver setup repW=%d repH=%d numCols=%d", repW, repH, numCols)
        guard numCols > 0 else { return }

        let topRows = repH / Int(colSize)
        drops  = (0..<numCols).map { _ in Double.random(in: -Double(topRows)...0) }
        speeds = (0..<numCols).map { _ in Double.random(in: speedMin...speedMax) }

        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: repW, pixelsHigh: repH,
            bitsPerSample: 8, samplesPerPixel: 4,
            hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        if let ctx = NSGraphicsContext(bitmapImageRep: rep) {
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = ctx
            NSColor.black.setFill()
            NSRect(x: 0, y: 0, width: repW, height: repH).fill()
            NSGraphicsContext.restoreGraphicsState()
            NSLog("MatrixSaver setup: bitmap fill OK")
        } else {
            NSLog("MatrixSaver setup: NSGraphicsContext(bitmapImageRep:) returned nil!")
        }
        accumRep = rep
    }

    override func animateOneFrame() {
        frameCount += 1
        if frameCount <= 3 || frameCount % 60 == 0 {
            NSLog("MatrixSaver animateOneFrame #%d bounds=%@ numCols=%d layer=%@ window=%@ accumRep=%@",
                  frameCount,
                  NSStringFromRect(bounds),
                  numCols,
                  layer != nil ? "ok" : "nil",
                  window != nil ? "ok" : "nil",
                  accumRep != nil ? "ok" : "nil")
        }

        if numCols == 0 { setup() }
        guard let rep = accumRep, numCols > 0 else { return }
        guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
            NSLog("MatrixSaver: context nil in animateOneFrame")
            return
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = ctx
        NSColor.black.withAlphaComponent(fadeAlpha).setFill()
        NSRect(x: 0, y: 0, width: CGFloat(repW), height: CGFloat(repH)).fill()

        let font  = NSFont.monospacedSystemFont(ofSize: colSize, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: headColor]
        for i in 0..<numCols {
            let head = Int(drops[i])
            guard head >= 0 else { continue }
            let x = CGFloat(i) * colSize
            let y = CGFloat(repH) - CGFloat(head + 1) * colSize
            guard y > -colSize else { continue }
            NSAttributedString(string: String(glyphs.randomElement()!), attributes: attrs)
                .draw(at: NSPoint(x: x, y: y))
        }
        NSGraphicsContext.restoreGraphicsState()

        let maxRow = repH / Int(colSize) + 2
        for i in 0..<numCols {
            drops[i] += speeds[i]
            if Int(drops[i]) > maxRow, Double.random(in: 0...1) < resetChance {
                drops[i] = 0
            }
        }

        setNeedsDisplay(bounds)
        display()
    }

    override func draw(_ rect: NSRect) {
        if frameCount <= 3 { NSLog("MatrixSaver draw(_:) called rect=%@", NSStringFromRect(rect)) }
        NSColor.black.setFill()
        rect.fill()
        accumRep?.draw(in: bounds)
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
