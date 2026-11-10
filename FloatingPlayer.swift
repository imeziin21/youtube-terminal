import Cocoa
import WebKit
import Darwin

final class Player: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSPanel!
    var web: WKWebView!
    let video: String
    let width: Int
    let height: Int
    var theme: String
    init(video: String, width: Int, height: Int, theme: String) {
        self.video = video; self.width = width; self.height = height; self.theme = theme
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        let rect = NSRect(x: 150, y: 400, width: width, height: height)
        window = NSPanel(contentRect: rect, styleMask: [.titled, .closable, .resizable, .nonactivatingPanel], backing: .buffered, defer: false)
        window.title = "YouTube Terminal · Pinned"
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        let config = WKWebViewConfiguration()
        // Set the YouTube theme before its scripts render the page.
        config.userContentController.addUserScript(themeScript(theme))
        web = WKWebView(frame: rect, configuration: config)
        web.navigationDelegate = self
        applyAppearance()
        window.contentView = web
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.accessory)
        if let url = URL(string: "https://www.youtube.com/watch?v=\(video)") { web.load(URLRequest(url: url)) }
        DispatchQueue.global(qos: .userInitiated).async { self.serve() }
    }
    func applyAppearance() {
        let dark = theme == "dark"
        window?.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        web?.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
    }
    func themeScript(_ mode: String) -> WKUserScript {
        let dark = mode == "dark"
        // YouTube uses the dark attribute and --yt-spec-* tokens for its UI.
        // The mutation observer handles YouTube's client-side re-rendering.
        let js = """
        (() => {
          const dark = \(dark ? "true" : "false");
          const apply = () => {
            const root = document.documentElement;
            if (!root) return;
            if (dark) { root.setAttribute('dark', 'true'); root.setAttribute('style', 'color-scheme: dark; background: #0f0f0f;'); }
            else { root.removeAttribute('dark'); root.setAttribute('style', 'color-scheme: light; background: #fff;'); }
          };
          apply();
          document.addEventListener('DOMContentLoaded', apply, {once:true});
          let busy = false;
          new MutationObserver(() => {
            if (busy) return;
            const shouldFix = dark ? !document.documentElement.hasAttribute('dark') : document.documentElement.hasAttribute('dark');
            if (shouldFix) { busy = true; apply(); busy = false; }
          }).observe(document.documentElement, {attributes:true, attributeFilter:['dark']});
        })();
        """
        return WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    }
    func serve() {
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { return }
        var reuse: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = UInt16(49381).bigEndian
        address.sin_addr = in_addr(s_addr: in_addr_t(0x7f000001).bigEndian)
        let bound = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        guard bound == 0, listen(fd, 5) == 0 else { close(fd); return }
        while true {
            let client = accept(fd, nil, nil)
            if client < 0 { continue }
            var bytes = [UInt8](repeating: 0, count: 2048)
            let count = recv(client, &bytes, bytes.count, 0)
            let input = count > 0 ? String(decoding: bytes.prefix(count), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let parts = input.split(separator: " ").map(String.init)
            DispatchQueue.main.async {
                guard let cmd = parts.first else { return }
                switch cmd {
                case "ping": break
                case "theme":
                    if parts.count == 2 && (parts[1] == "dark" || parts[1] == "light") {
                        self.theme = parts[1]
                        self.applyAppearance()
                        self.web.configuration.userContentController.removeAllUserScripts()
                        self.web.configuration.userContentController.addUserScript(self.themeScript(self.theme))
                        self.web.reload()
                    }
                case "quit": NSApp.terminate(nil)
                case "pause": self.web.evaluateJavaScript("document.querySelector('video')?.pause()")
                case "resume": self.web.evaluateJavaScript("document.querySelector('video')?.play()")
                case "size":
                    if parts.count == 3, let w = Double(parts[1]), let h = Double(parts[2]) {
                        self.window.setContentSize(NSSize(width: w, height: h))
                    }
                case "video":
                    if parts.count == 2, let url = URL(string: "https://www.youtube.com/watch?v=\(parts[1])") { self.web.load(URLRequest(url: url)) }
                case "hide": self.window.orderOut(nil)
                case "show": self.window.orderFrontRegardless()
                default: break
                }
            }
            _ = send(client, "ok\n", 3, 0)
            close(client)
        }
    }
}

let args = CommandLine.arguments
if args.count < 4 { fputs("usage: floating-player <video-id> <width> <height> [dark|light]\n", stderr); exit(2) }
let app = NSApplication.shared
let player = Player(video: args[1], width: Int(args[2]) ?? 300, height: Int(args[3]) ?? 250, theme: args.count > 4 && args[4] == "dark" ? "dark" : "light")
app.delegate = player
app.run()
