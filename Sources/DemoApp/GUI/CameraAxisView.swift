import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

public class CameraAxisView: Widget {

    @Observable private var camera: Camera

    public init(camera: Observable<Camera>) {

        self._camera = camera
    }

    override public func getBoxConfig() -> BoxConfig {

        BoxConfig(preferredSize: DSize2(100, 100))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        return constraints.constrain(DSize2(100, 100))
    }

    override public func renderContent() -> RenderObject? {

        let projectionTransformation = Matrix4<Double>.orthographicProjection(top: 100, right: 100, bottom: -100, left: -100, near: 100, far: -100)

        let forwardProjection = projectAxis(axis: camera.forward, projectionTransformation: projectionTransformation)
        
        let upProjection = projectAxis(axis: camera.up, projectionTransformation: projectionTransformation)
        
        let rightProjection = projectAxis(axis: camera.right, projectionTransformation: projectionTransformation)

        let center = globalBounds.center

        let maxLength = globalBounds.size.width / 2

        return RenderObject.RenderStyle(fillColor: .White) {
            
            RenderObject.LineSegment(from: center, to: center + forwardProjection.normalized() * maxLength)
            
            RenderObject.LineSegment(from: center, to: center + upProjection.normalized() * maxLength)
            
            RenderObject.LineSegment(from: center, to: center + rightProjection.normalized() * maxLength)
        }
    }

    private func projectAxis(axis: DVec3, projectionTransformation: Matrix4<Double>) -> DVec2 {
        
        DVec2(Array(projectionTransformation.matmul(Vector4(axis.elements + [1])).elements[0..<2]))
    }
}