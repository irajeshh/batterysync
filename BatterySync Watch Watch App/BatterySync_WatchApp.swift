import SwiftUI
import WatchKit

@main
struct BatterySyncWatchApp: App {
    @StateObject private var sender = BatterySender()
    var body: some Scene { WindowGroup { CompanionView(sender: sender) } }
}

struct CompanionView: View {
    @ObservedObject var sender: BatterySender
    private var level: Double { Double(sender.watchBatteryPercent) / 100.0 }
    private var percent: Int { sender.watchBatteryPercent }
    var body: some View {
        VStack(spacing: 5) {
            Button { sender.refreshNow() } label: { batteryRing }
                .buttonStyle(.plain)
            phoneRow
        }
        .padding(6)
        .background(Color.black)
        .onAppear { sender.start() }
        .onDisappear { sender.stop() }
    }
    private var batteryRing: some View {
        ZStack {
            Circle().stroke(Color.green.opacity(0.2), lineWidth: 7)
            Circle().trim(from: 0, to: level).stroke(Color.green, style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90))
            VStack(spacing: 0) { Text("\(percent)%").font(.system(size: 31, weight: .bold)); Text("Watch").font(.system(size: 8)).foregroundStyle(.secondary) }
        }.frame(width: 88, height: 88)
    }
    private var phoneRow: some View {
        Button { sender.pingIPhone() } label: {
            HStack { Image(systemName: "iphone"); Text(sender.iphoneBattery.map { "iPhone \($0)%" } ?? "iPhone").font(.system(size: 10)); Spacer(); Circle().fill(rangeColor).frame(width: 9, height: 9); Text(sender.syncToken).font(.system(size: 9, design: .monospaced)).foregroundStyle(.gray) }
        }.buttonStyle(.plain)
    }
    private var rangeColor: Color { sender.proximity == "Nearby" ? .green : (sender.proximity == "Checking…" ? .yellow : .red) }
}
