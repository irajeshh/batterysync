import Foundation
import Combine
import WatchConnectivity
import AudioToolbox
import WidgetKit
#if canImport(UIKit)
import UIKit
#endif

final class BatteryViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var percentage: Int?
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isReachable = false
    @Published private(set) var syncToken = "------"

    private let session = WCSession.default
    private var pingTimer: Timer?
    private var batteryTimer: Timer?

    override init() {
        super.init()
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        #endif
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
        sendPhoneBattery()
        batteryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in self?.sendPhoneBattery() }
    }

    private func sendPhoneBattery() {
        #if canImport(UIKit)
        let payload: [String: Any] = ["iphoneBattery": Double(UIDevice.current.batteryLevel), "updatedAt": Date().timeIntervalSince1970]
        let shared = UserDefaults(suiteName: "group.com.irajeshh.batterysync")
        shared?.set(Int((UIDevice.current.batteryLevel * 100).rounded()), forKey: "iphoneBattery")
        WidgetCenter.shared.reloadAllTimelines()
        try? session.updateApplicationContext(payload)
        if session.isReachable { session.sendMessage(payload, replyHandler: nil) }
        #endif
    }
    func pingWatch() {
        let payload: [String: Any] = ["action": "pingWatch"]
        if session.isReachable { session.sendMessage(payload, replyHandler: nil) }
        try? session.transferUserInfo(payload)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        sendPhoneBattery()
        Task { @MainActor in self.isReachable = session.isReachable }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in self.isReachable = session.isReachable }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["action"] as? String == "watchBatteryChanged" {
            AudioServicesPlaySystemSound(1007)
        } else if message["action"] as? String == "ping" {
            for index in 0..<7 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.8)) {
                    AudioServicesPlaySystemSound(1007)
                }
            }
        }
        apply(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        apply(userInfo)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        apply(applicationContext)
    }

    private func apply(_ payload: [String: Any]) {
        guard let rawPercentage = (payload["percentage"] as? Double) ?? (payload["batteryLevel"] as? Double),
              let timestamp = (payload["timestamp"] as? Double) ?? (payload["updatedAt"] as? Double) else { return }
        Task { @MainActor in
            percentage = Int((rawPercentage * 100).rounded())
            lastUpdated = Date(timeIntervalSince1970: timestamp)
            syncToken = (payload["syncToken"] as? String) ?? syncToken
            let shared = UserDefaults(suiteName: "group.com.irajeshh.batterysync")
            shared?.set(percentage, forKey: "watchBattery")
            shared?.set(syncToken, forKey: "syncToken")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
