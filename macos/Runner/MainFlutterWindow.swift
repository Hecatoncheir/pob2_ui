import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.title = ""
    self.setFrameAutosaveName("pob2_ui.mainWindow")
    self.setFrameUsingName("pob2_ui.mainWindow", force: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    if UserDefaults.standard.bool(forKey: "pob2_ui.windowZoomed") {
      self.zoom(nil)
    }
  }

  override func close() {
    UserDefaults.standard.set(self.isZoomed, forKey: "pob2_ui.windowZoomed")
    super.close()
  }

  override func performClose(_ sender: Any?) {
    // Окно остаётся открытым, пока Flutter сохраняет данные и решает, можно ли выйти.
    UserDefaults.standard.set(self.isZoomed, forKey: "pob2_ui.windowZoomed")
    NSApp.terminate(sender)
  }
}
