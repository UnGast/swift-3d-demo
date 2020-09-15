import WidgetGUI
import CustomGraphicsMath

public class MetaView: SingleChildWidget {

    private let scene: Scene

    @Observable private var cameraPositionText = "None"

    @Observable private var cameraAngleText = "None"

    @Observable private var cameraForwardText = "None"
    
    @Observable private var cameraUpText = "None"
    
    @Observable private var cameraRightText = "None"

    @Observable private var directionsDebugAngleText = "None"

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

                                    Text("Angle:")

                                    Text($cameraAngleText)
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

                                Row {

                                    Text("Directions Debug Angles:")

                                    Text($directionsDebugAngleText)
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

        cameraAngleText = "Pitch: \(Int(scene.camera.pitch / 2 / Double.pi * 360)) Yaw: \(Int(scene.camera.yaw / 2 / Double.pi * 360))"

        cameraForwardText = generateVectorText(scene.camera.forward)
        
        cameraUpText = generateVectorText(scene.camera.up)
        
        cameraRightText = generateVectorText(scene.camera.right)

        directionsDebugAngleText = """
        (Forward, Up): \(getAngleDegrees(scene.camera.forward, scene.camera.up), format: "%.4f")
        (Forward, Right): \(getAngleDegrees(scene.camera.forward, scene.camera.right), format: "%.4f")
        (Right, Up): \(getAngleDegrees(scene.camera.right, scene.camera.up), format: "%.4f")
        """

        camera = scene.camera
    }

    private func generateVectorText(_ vector: DVec3) -> String {

        return """
        x: \(vector.x, format: "%.2f") y: \(vector.y, format: "%.2f") z: \(vector.z, format: "%.2f")
        """
    }
    
    private func getAngleDegrees(_ vector1: DVec3, _ vector2: DVec3) -> Double {

        vector1.absAngle(to: vector2) / 2 / Double.pi * 360
    }
}