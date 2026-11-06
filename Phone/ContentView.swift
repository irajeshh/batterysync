import SwiftUI

struct ContentView: View {
    @StateObject private var model = BatteryViewModel()
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.02, green: 0.05, blue: 0.08), .black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack { watchCard() }.padding(12)
        }.preferredColorScheme(.dark)
    }
    private func header() -> some View {
        HStack { Image(systemName: "applewatch").font(.title2).padding(12).background(Circle().fill(Color.green.opacity(0.18))); VStack(alignment: .leading, spacing: 3) { Text("Watch Companion").font(.headline); Text("Battery · Connection · Distance").font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "gearshape.fill").padding(12).background(Circle().fill(Color.white.opacity(0.1))) }.foregroundStyle(.white)
    }
    private func watchCard() -> some View {
        VStack(spacing: 16) { HStack { Label("Apple Watch", systemImage: "applewatch").font(.headline); Spacer() }; batteryRing(); HStack(spacing: 0) { stat(title: "This iPhone", value: "\(Int(UIDevice.current.batteryLevel * 100))%", icon: "iphone"); Divider().frame(height: 42).padding(.horizontal, 14); HStack(spacing: 8) { Image(systemName: "antenna.radiowaves.left.and.right").font(.title3); VStack(alignment: .leading, spacing: 2) { Text("Distance").font(.caption).foregroundStyle(.secondary); HStack(spacing: 5) { Circle().fill(Color.green).frame(width: 8, height: 8); Text("Very close").font(.headline).foregroundStyle(.green) } } }.frame(maxWidth: .infinity, alignment: .leading) }; Button { model.pingWatch() } label: { Text("Tap to ping Watch · \(model.syncToken)").font(.caption.weight(.semibold)).foregroundStyle(.gray) } }.padding(18).background(RoundedRectangle(cornerRadius: 28).fill(Color.white.opacity(0.07))).overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.08)))
    }
    private func batteryRing() -> some View {
        let value = Double(model.percentage ?? 0) / 100
        return ZStack { Circle().stroke(Color.green.opacity(0.18), lineWidth: 12); Circle().trim(from: 0, to: value).stroke(AngularGradient(colors: [.green, .mint, .green], center: .center), style: StrokeStyle(lineWidth: 12, lineCap: .round)).rotationEffect(.degrees(-90)); Text(model.percentage.map { "\($0)%" } ?? "--").font(.system(size: 48, weight: .bold, design: .rounded)) }.frame(width: 220, height: 220).shadow(color: .green.opacity(0.25), radius: 18)
    }
    private func stat(title: String, value: String, icon: String) -> some View { HStack(spacing: 8) { Image(systemName: icon).font(.title3).foregroundStyle(.white); VStack(alignment: .leading, spacing: 2) { Text(title).font(.caption).foregroundStyle(.secondary); Text(value).font(.headline).foregroundStyle(.white) } }.frame(maxWidth: .infinity, alignment: .leading) }
}
