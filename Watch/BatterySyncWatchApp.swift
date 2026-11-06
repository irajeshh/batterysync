import SwiftUI
import WatchKit

@main
struct BatterySyncWatchApp: App {
    @StateObject private var sender = BatterySender()
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 6) {
                HStack { Image(systemName: "applewatch"); Text("Watch Companion").font(.caption2); Spacer(); Text(Date(), style: .time).font(.caption2) }.foregroundStyle(.white)
                ZStack {
                    Circle().stroke(Color.green.opacity(0.18), lineWidth: 8)
                    Circle().trim(from: 0, to: max(0, min(1, WKInterfaceDevice.current().batteryLevel))).stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
                    VStack(spacing: 0) { Image(systemName: "bolt.fill").foregroundStyle(.green); Text("\(Int((WKInterfaceDevice.current().batteryLevel * 100).rounded()))%").font(.system(size: 30, weight: .bold, design: .rounded)); Text("Watch battery").font(.caption2).foregroundStyle(.secondary) }
                }.frame(width: 145, height: 145)
                Text("iPhone · Nearby").font(.caption2).foregroundStyle(.gray)
            }.padding(8).background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))).onAppear { sender.start() }.onDisappear { sender.stop() }
        }
    }
}
