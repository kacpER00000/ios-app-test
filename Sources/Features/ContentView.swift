import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 1. Tworzymy obiekt (Siatka 10cm i niebieski materiał)
        let boxMesh = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let boxModel = ModelEntity(mesh: boxMesh, materials: [material])
        
        // 2. Tworzymy kotwicę szukającą płaskiej podłogi/stołu
        let anchor = AnchorEntity(plane: .horizontal)
        
        // 3. Łączymy obiekt z kotwicą, a kotwicę ze sceną
        anchor.addChild(boxModel)
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}