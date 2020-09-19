import WidgetGUI
import CustomGraphicsMath

public class MetaView: SingleChildWidget {

    private let scene: Scene

    private var worldEventBuffer: [World.Event] = []

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

        super.init()

        _ = self.scene.world.onEvent { [unowned self] in

            worldEventBuffer.append($0)
        }
    }

    override public func buildChild() -> Widget {

        Background(fill: Color(50, 70, 80, 255)) { [unowned self] in

            Padding(all: 32) {

                TextConfigProvider(fontSize: 16, fontWeight: .Regular, color: .White) {

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

                        LabelledArea(label: "Voxels") {

                            ScrollArea {

                                Column {

                                    for voxel in scene.world.voxels {

                                        buildVoxelEntry(voxel)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func buildVoxelEntry(_ voxel: Voxel) -> Widget {

        Background(fill: voxel.highlighted ? .Green : .Transparent) { [unowned self] in

            MouseArea {
                                                
                Padding(all: 16) {

                    Row {

                        Text("x: \(voxel.position.x) y: \(voxel.position.y) z: \(voxel.position.z)")
                    }
                }

            } onClick: { _ in handleVoxelClick(voxel) }
        }
    }

    private func handleVoxelClick(_ voxel: Voxel) {

        var updatedVoxel = voxel

        updatedVoxel.highlighted = true

        scene.world.updateVoxel(updatedVoxel)
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

        worldEventBuffer = []
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