import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
  @StateObject private var scanner = BeaconScanner()
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 1. Tworzymy obiekt (Siatka 10cm i niebieski materiał)
        if(scanner.state == .distance(let distance) && distance < 1.0) {
            let boxMesh = MeshResource.generateBox(size: 0.1)
            let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [blueMaterial])
            
            // 2. Tworzymy kotwicę i dodajemy obiekt do sceny
            let anchorEntity = AnchorEntity(plane: .vertical)
            anchorEntity.addChild(boxEntity)
            arView.scene.addAnchor(anchorEntity)
        } else {
            arView.scene.anchors.removeAll()
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}