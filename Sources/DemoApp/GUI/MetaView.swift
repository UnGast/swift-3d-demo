import WidgetGUI
import CustomGraphicsMath

public class MetaView: SingleChildWidget {

    private let scene: Scene

    @Observable private var cameraPositionText = "None"

    @Observable private var cameraDirectionText = "None"

    public init(_ scene: Scene) {

        self.scene = scene
    }

    override public func buildChild() -> Widget {

        Background(fill: Color(50, 70, 80, 200)) { [unowned self] in

            Padding(all: 32) {

                TextConfigProvider(fontSize: 24, fontWeight: .Bold, color: .White) {

                    Column(spacing: 16) {
                        
                        Row {

                            Text("Position:")
                            
                            Text($cameraPositionText)
                        }

                        Row {

                            Text("Direction:")

                            Text($cameraDirectionText)
                        }

                        for (i, voxel) in scene.voxels.enumerated() {

                            MouseArea {
                                
                                Text("Voxel at x: \(voxel.position.x) y: \(voxel.position.y) z: \(voxel.position.z)")

                            } onClick: { _ in handleVoxelClick(i) }
                        }
                    }
                }
            }
        }
    }

    private func handleVoxelClick(_ i: Int) {

        scene.voxels[i].highlighted = true
    }

    public func update() {

        cameraPositionText = """
        x: \(scene.camera.position.x, format: "%.2f") y: \(scene.camera.position.y, format: "%.2f") z: \(scene.camera.position.z, format: "%.2f")
        """

        cameraDirectionText = """
        x: \(scene.camera.forward.x, format: "%.2f") y: \(scene.camera.forward.y, format: "%.2f") z: \(scene.camera.forward.z, format: "%.2f")
        """
    }
}