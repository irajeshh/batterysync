# BatterySync

Local-only Apple Watch battery prototype. Add the `Phone` files to an iOS SwiftUI target and `Watch` files to a watchOS companion target in Xcode.

The watch sends the current battery percentage and timestamp through WatchConnectivity. The phone displays the latest value. It intentionally does not use Firebase yet; background/workout execution is the next milestone.
