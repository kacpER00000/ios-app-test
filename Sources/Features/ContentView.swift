
import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var scanner = BeaconScanner()

    var body: some View {
        ARViewContainer(scanner: scanner)
            .ignoresSafeArea()
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
           distance < 1.0 {

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

            let anchorEntity = AnchorEntity(plane: .vertical)
            anchorEntity.addChild(boxEntity)

            uiView.scene.addAnchor(anchorEntity)
            context.coordinator.anchorEntity = anchorEntity

        } else {
            if let anchor = context.coordinator.anchorEntity {
                uiView.scene.removeAnchor(anchor)
                context.coordinator.anchorEntity = nil
            }
        }
    }

    class Coordinator {
        var anchorEntity: AnchorEntity?
    }
}
