import SwiftUI

/// Single screen: shows only the distance to the iBeacon.
struct ContentView: View {
  @StateObject private var scanner = BeaconScanner()

  var body: some View {
    Text(text)
      .font(.system(size: 64, weight: .bold, design: .rounded))
      .monospacedDigit()
      .minimumScaleFactor(0.4)
      .lineLimit(2)
      .multilineTextAlignment(.center)
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .contentTransition(.numericText())
      .animation(.snappy, value: text)
      .onAppear { scanner.start() }
      .onDisappear { scanner.stop() }
  }

  private var text: String {
    switch scanner.state {
    case .distance(let meters):
      return String(format: "%.1f m", meters)
    case .searching:
      return "Szukam…"
    case .waitingForPermission:
      return "…"
    case .denied:
      return "Brak zgody na lokalizację"
    case .bluetoothOrLocationOff:
      return "Włącz Bluetooth i lokalizację"
    }
  }
}

#Preview {
  ContentView()
}
