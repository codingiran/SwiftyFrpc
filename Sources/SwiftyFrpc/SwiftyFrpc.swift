import Libfrpc

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("SwiftyFrpc doesn't support Swift versions below 5.5.")
#endif

/// Current SwiftyFrpc version 0.51.3. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.51.3"

public enum Frpc {
    /// FRP 版本号
    public static var version: String { LibfrpVersion() }

    /// FRP 客户端是否正在运行
    public static var isRunning: Bool { LibfrpIsFrpcRunning() }

    /// 运行 FRP 客户端
    public static func run(_ configPath: String?) throws {
        var error: NSError?
        let result = LibfrpRunFrpc(configPath, &error)
        if !result {
            throw error ?? NSError(domain: "frpc", code: 9527, userInfo: [NSLocalizedDescriptionKey: "Unknow Error"])
        }
    }

    /// 重载 FRP 客户端
    @discardableResult
    public static func reload() -> Bool {
        return LibfrpReloadFrpc()
    }

    /// 停止 FRP 客户端
    public static func stop() throws {
        var error: NSError?
        let result = LibfrpStopFrpc(&error)
        if !result {
            throw error ?? NSError(domain: "frpc", code: 9528, userInfo: [NSLocalizedDescriptionKey: "Unknow Error"])
        }
    }

    /// 监听 FRP 客户端
    public static func setLogListener(_ listener: LibfrpFrpLogListenerProtocol) {
        LibfrpSetFrpLogListener(listener)
    }
}

public extension Frpc {
    enum AuthenticationMethod: String, CaseIterable {
        case token
        case oidc
    }

    enum ServerProtocol: String, CaseIterable {
        case tcp
        case kcp
        case quic
        case websocket
        case wss
    }
}

public class FrpLogListener: NSObject, LibfrpFrpLogListenerProtocol {
    var logLocale: String
    var logListener: (String) -> Void

    public init(logLocale: String = "", logListener: @escaping (String) -> Void) {
        self.logLocale = logLocale
        self.logListener = logListener
    }

    public func location() -> String { logLocale }

    public func log(_ log: String?) {
        guard let log else { return }
        logListener(log)
    }
}
