import Combine
import Foundation
import WatchConnectivity
import WatchKit

final class BatterySender: NSObject, ObservableObject, WCSessionDelegate {
    private let session = WCSession.default
    private var timer: Timer?

    func start() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
        sendReading()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.sendReading()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sendReading() {
        let device = WKInterfaceDevice.current()
        device.isBatteryMonitoringEnabled = true
        let payload: [String: Any] = [
            "percentage": Double(device.batteryLevel),
            "timestamp": Date().timeIntervalSince1970,
        ]
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil)
        } else {
            session.transferUserInfo(payload)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
