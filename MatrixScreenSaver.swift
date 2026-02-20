import ScreenSaver
import WebKit

// @objc(MatrixScreenSaverView) is required — without it Swift registers
// the class as "MatrixScreenSaver.MatrixScreenSaverView" in the ObjC
// runtime, which won't match the plain "MatrixScreenSaverView" in Info.plist.
@objc(MatrixScreenSaverView)
final class MatrixScreenSaverView: ScreenSaverView {

    private var webView: WKWebView?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = true

        let wv = WKWebView(frame: bounds, configuration: config)
        wv.autoresizingMask = [.width, .height]
        wv.setValue(false, forKey: "drawsBackground")
        addSubview(wv)
        webView = wv

        let bundle = Bundle(for: MatrixScreenSaverView.self)
        if let fileURL = bundle.url(forResource: "index", withExtension: "html"),
           let resourceURL = bundle.resourceURL {
            wv.loadFileURL(fileURL, allowingReadAccessTo: resourceURL)
        }
    }

    // Animation is driven by requestAnimationFrame inside the HTML.
    override func animateOneFrame() {}

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
