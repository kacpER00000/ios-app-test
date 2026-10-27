import SwiftUI
import RealityKit

struct ContentView: View {
  @StateObject private var scanner = BeaconScanner()
    var body: some View {
        ARViewContainer(scanner: scanner).edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
  @ObservedObject var scanner: BeaconScanner
    func makeUIView(context: Context) -> ARView {
        ArView(frame: .zero)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if case let .distance(distance) = scanner.state, distance < 1.0 {
            let boxMesh = MeshResource.generateBox(size: 0.1)
            let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [blueMaterial])
            
            let anchorEntity = AnchorEntity(plane: .vertical)
            anchorEntity.addChild(boxEntity)
            arView.scene.addAnchor(anchorEntity)
        } else {
            arView.scene.anchors.removeAll()
        }
    }
}