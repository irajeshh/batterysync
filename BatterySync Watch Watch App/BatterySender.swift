import Foundation
import Combine
import WatchConnectivity
import WatchKit

final class BatterySender: NSObject, ObservableObject, WCSessionDelegate {
    private var timer: Timer?
    @Published private(set) var syncToken = "------"
    @Published private(set) var iphoneBattery: Int?
    @Published private(set) var proximity = "Checking…"
    @Published private(set) var watchBatteryPercent = 0
    private var lastBatteryPercent: Int?
    override init() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        super.init()
    }
    func start() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        watchBatteryPercent = Int((WKInterfaceDevice.current().batteryLevel * 100).rounded())
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        proximity = session.isReachable ? "Nearby" : "Out of range"
        send()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.send() }
    }
    func stop() { timer?.invalidate(); timer = nil }
    func refreshNow() { send() }
    func pingIPhone() { WCSession.default.sendMessage(["action": "ping"], replyHandler: nil) }
    private func send() {
        syncToken = String(UUID().uuidString.prefix(2))
        let level = Double(WKInterfaceDevice.current().batteryLevel)
        let percent = Int((level * 100).rounded())
        watchBatteryPercent = percent
        let changed = lastBatteryPercent != nil && lastBatteryPercent != percent
        lastBatteryPercent = percent
        let payload: [String: Any] = ["batteryLevel": level, "updatedAt": Date().timeIntervalSince1970, "syncToken": syncToken]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil)
            if changed { session.sendMessage(["action": "watchBatteryChanged"], replyHandler: nil) }
        }
        try? session.updateApplicationContext(payload)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let value = applicationContext["iphoneBattery"] as? Double { DispatchQueue.main.async { self.iphoneBattery = Int((value * 100).rounded()) } }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleAction(message)
        proximity = "Nearby"
        if let value = message["iphoneBattery"] as? Double { DispatchQueue.main.async { self.iphoneBattery = Int((value * 100).rounded()) } }
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) { handleAction(userInfo) }
    private func handleAction(_ message: [String: Any]) {
        if message["action"] as? String == "pingWatch" {
            for index in 0..<7 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.8)) {
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
    }
    func sessionReachabilityDidChange(_ session: WCSession) { DispatchQueue.main.async { self.proximity = session.isReachable ? "Nearby" : "Out of range" } }
}
