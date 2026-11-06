import WidgetKit
import SwiftUI

struct WatchBatteryEntry: TimelineEntry { let date: Date; let watch: Int; let phone: Int; let token: String }

struct WatchBatteryProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchBatteryEntry { WatchBatteryEntry(date: .now, watch: 82, phone: 64, token: "AB") }
    func getSnapshot(in context: Context, completion: @escaping (WatchBatteryEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchBatteryEntry>) -> Void) { completion(Timeline(entries: [entry()], policy: .after(.now.addingTimeInterval(900)))) }
    private func entry() -> WatchBatteryEntry {
        let defaults = UserDefaults(suiteName: "group.com.irajeshh.batterysync")
        return WatchBatteryEntry(date: .now, watch: defaults?.integer(forKey: "watchBattery") ?? 0, phone: defaults?.integer(forKey: "iphoneBattery") ?? 0, token: defaults?.string(forKey: "syncToken") ?? "--")
    }
}

struct WatchBatteryWidgetView: View {
    let entry: WatchBatteryEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Apple Watch").font(.headline)
            Text("\(entry.watch)%").font(.system(size: 34, weight: .bold))
            Text("iPhone \(entry.phone)%").font(.caption).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(entry.token).font(.caption2.monospaced().bold()).foregroundStyle(.gray)
        }.containerBackground(.black.gradient, for: .widget)
    }
}

@main struct WatchBatteryWidget: Widget {
    let kind = "WatchBatteryWidget"
    var body: some WidgetConfiguration { StaticConfiguration(kind: kind, provider: WatchBatteryProvider()) { WatchBatteryWidgetView(entry: $0) }.configurationDisplayName("Watch Battery").description("Apple Watch and iPhone battery") .supportedFamilies([.systemSmall, .systemMedium]) }
}
