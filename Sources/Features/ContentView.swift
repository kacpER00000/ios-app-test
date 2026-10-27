
import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var scanner = BeaconScanner()

    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer(scanner: scanner)
                .ignoresSafeArea()

            Text(text)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.leading, 16)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            scanner.start()
        }
        .onDisappear {
            scanner.stop()
        }
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

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var scanner: BeaconScanner

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        ARView(frame: .zero)
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if case let .distance(distance) = scanner.state,
           distance < 2.5 {

            guard context.coordinator.anchorEntity == nil else {
                return
            }

            let boxMesh = MeshResource.generateBox(size: 0.1)
            let blueMaterial = SimpleMaterial(
                color: .blue,
                isMetallic: false
            )
            let boxEntity = ModelEntity(
                mesh: boxMesh,
                materials: [blueMaterial]
            )

            let anchorEntity = AnchorEntity(plane: .horizontal)
            anchorEntity.addChild(boxEntity)

            uiView.scene.addAnchor(anchorEntity)
            context.coordinator.anchorEntity = anchorEntity

        } else if let anchor = context.coordinator.anchorEntity {
            uiView.scene.removeAnchor(anchor)
            context.coordinator.anchorEntity = nil
        }
    }

    class Coordinator {
        var anchorEntity: AnchorEntity?
    }
}
