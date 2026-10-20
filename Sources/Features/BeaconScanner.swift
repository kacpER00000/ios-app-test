import CoreLocation
import Foundation

/// Ranges a single iBeacon and publishes the estimated distance in meters.
final class BeaconScanner: NSObject, ObservableObject, CLLocationManagerDelegate {

  // MARK: - Konfiguracja — PODMIEŃ NA UUID SWOJEGO iBEACONA
  static let beaconUUID = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")!

  enum State: Equatable {
    case waitingForPermission
    case denied
    case bluetoothOrLocationOff
    case searching
    case distance(Double)  // meters
  }

  @Published private(set) var state: State = .waitingForPermission

  private let manager = CLLocationManager()
  private lazy var constraint = CLBeaconIdentityConstraint(uuid: Self.beaconUUID)
  private var lastSeen: Date?
  private var timeoutTimer: Timer?

  override init() {
    super.init()
    manager.delegate = self
  }

  func start() {
    switch manager.authorizationStatus {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      state = .denied
    default:
      startRanging()
    }
  }

  func stop() {
    manager.stopRangingBeacons(satisfying: constraint)
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  private func startRanging() {
    guard CLLocationManager.isRangingAvailable() else {
      state = .bluetoothOrLocationOff
      return
    }
    state = .searching
    manager.startRangingBeacons(satisfying: constraint)

    // Jeśli beacon zniknie, wróć do stanu „szukam".
    timeoutTimer?.invalidate()
    timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self, let lastSeen = self.lastSeen else { return }
      if Date().timeIntervalSince(lastSeen) > 5 {
        self.state = .searching
        self.lastSeen = nil
      }
    }
  }

  // MARK: - CLLocationManagerDelegate

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      startRanging()
    case .denied, .restricted:
      state = .denied
    default:
      state = .waitingForPermission
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didRange beacons: [CLBeacon],
    satisfying constraint: CLBeaconIdentityConstraint
  ) {
    // accuracy < 0 oznacza, że odległość jest jeszcze nieznana.
    guard let beacon = beacons.first(where: { $0.accuracy >= 0 }) else { return }
    lastSeen = Date()
    state = .distance(beacon.accuracy)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    state = .bluetoothOrLocationOff
  }
}
