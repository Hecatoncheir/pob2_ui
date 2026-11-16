import Cocoa
import Carbon.HIToolbox
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private static let xmlCommands = ["o": "importXml", "s": "exportXml"]
  private static let ansiXmlKeys: [UInt16: String] = [
    UInt16(kVK_ANSI_O): "o",
    UInt16(kVK_ANSI_S): "s",
  ]
  private var xmlShortcuts: Set<String> = []
  private var xmlShortcutChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.title = ""
    self.setFrameAutosaveName("pob2_ui.mainWindow")
    self.setFrameUsingName("pob2_ui.mainWindow", force: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureXmlShortcutChannel(flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
    if UserDefaults.standard.bool(forKey: "pob2_ui.windowZoomed") {
      self.zoom(nil)
    }
  }

  private func configureXmlShortcutChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "pob2_ui/xml_shortcuts", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "configure", let commands = call.arguments as? [String] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.xmlShortcuts = Set(commands)
      result(nil)
    }
    xmlShortcutChannel = channel
  }

  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
    guard modifiers == .command,
          let command = xmlCommand(for: event),
          xmlShortcuts.contains(command) else {
      return super.performKeyEquivalent(with: event)
    }
    if !event.isARepeat {
      xmlShortcutChannel?.invokeMethod(command, arguments: nil)
    }
    return true
  }

  private func xmlCommand(for event: NSEvent) -> String? {
    if let key = event.charactersIgnoringModifiers?.lowercased(),
       key.utf8.count == 1, let code = key.utf8.first, (0x20...0x7E).contains(code) {
      return Self.xmlCommands[key]
    }
    // В кириллической раскладке используем позицию клавиши латинского сочетания.
    return Self.ansiXmlKeys[event.keyCode].flatMap { Self.xmlCommands[$0] }
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
