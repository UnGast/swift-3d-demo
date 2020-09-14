import WidgetGUI
import CustomGraphicsMath

public class MetaView: SingleChildWidget {

    private let scene: Scene

    @Observable private var cameraPositionText = "None"

    @Observable private var cameraForwardText = "None"
    
    @Observable private var cameraUpText = "None"
    
    @Observable private var cameraRightText = "None"

    @Observable private var camera: Camera

    public init(_ scene: Scene) {

        self.scene = scene

        self.camera = scene.camera
    }

    override public func buildChild() -> Widget {

        Background(fill: Color(50, 70, 80, 255)) { [unowned self] in

            Padding(all: 32) {

                TextConfigProvider(fontSize: 24, fontWeight: .Bold, color: .White) {

                    Column(spacing: 16) {

                        LabelledArea(label: "Camera") {
                            
                            Column(spacing: 16) {

                                Row {

                                    Text("Position:")
                                    
                                    Text($cameraPositionText)
                                }

                                Row {

                                    Text("Forward:")

                                    Text($cameraForwardText)
                                }

                                Row {

                                    Text("Up:")

                                    Text($cameraUpText)
                                }

                                Row {

                                    Text("Right:")

                                    Text($cameraRightText)
                                }

                                CameraAxisView(camera: $camera)
                            }
                        }

                        for (i, voxel) in scene.world.voxels.enumerated() {

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

        scene.world.voxels[i].highlighted = true
    }

    public func update() {

        cameraPositionText = generateVectorText(scene.camera.position)
        
        cameraForwardText = generateVectorText(scene.camera.forward)
        
        cameraUpText = generateVectorText(scene.camera.up)
        
        cameraRightText = generateVectorText(scene.camera.right)

        camera = scene.camera
    }

    private func generateVectorText(_ vector: DVec3) -> String {

        return """
        x: \(vector.x, format: "%.2f") y: \(vector.y, format: "%.2f") z: \(vector.z, format: "%.2f")
        """
    }
}