import WidgetGUI
import CustomGraphicsMath

public class MetaView: SingleChildWidget {

    private let scene: Scene

    @Reference private var cameraPositionWidget: Text

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
                            
                            Text("Non asdasdasd asd se").connect(ref: $cameraPositionWidget)
                        }

                        for voxel in scene.voxels {

                            Text("Voxel at x: \(voxel.position.x) y: \(voxel.position.y) z: \(voxel.position.z)")
                        }
                    }
                }
            }
        }
    }

    public func update() {

        cameraPositionWidget.text = """
        x: \(scene.camera.position.x, format: "%.2f") y: \(scene.camera.position.y, format: "%.2f") z: \(scene.camera.position.z, format: "%.2f")
        """

        cameraPositionWidget.invalidateLayout()
    
        cameraPositionWidget.layout(constraints: cameraPositionWidget.previousConstraints!)
    }
}