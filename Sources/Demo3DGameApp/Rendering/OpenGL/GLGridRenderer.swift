import CustomGraphicsMath
import GL

public class GLGridRenderer {

    public var axisConfigs = [
        
        AxisConfig(direction: DVec3(1, 0, 0), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Red),

        AxisConfig(direction: DVec3(0, 1, 0), crossDirection: DVec3(1, 0, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Green),

        AxisConfig(direction: DVec3(0, 0, 1), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Blue)
    ]

    private var mainAxisLineThickness = 0.01

    private var gridLineThickness = 0.001

    private var gridLineColor = Color.White

    private var gridSize = 0.5

    private var lines: [DrawableLine] = []

    private let lineRenderer: GLLineRenderer


    public init() {

        lineRenderer = GLLineRenderer()
    }


    public func setup() throws {

        try lineRenderer.setup()

        updateBuffers()
    }

    private func updateBuffers() {

        lines = [DrawableLine]()

        for (i, axisConfig) in axisConfigs.enumerated() {

            let mainAxisLine = DrawableLine(
                
                start: axisConfig.direction * axisConfig.positiveLength,
                
                end: -axisConfig.direction * axisConfig.negativeLength,

                thickness: mainAxisLineThickness,

                color: axisConfig.color)
            
            lines.append(mainAxisLine)

            for (j, otherAxisConfig) in axisConfigs.enumerated() {

                if j == i {

                    continue
                }

                let positiveCount = Int(otherAxisConfig.positiveLength / gridSize)

                let negativeCount = Int(otherAxisConfig.negativeLength / gridSize)

                for i in 0..<(negativeCount + positiveCount) {

                    let translation: DVec3

                    if i >= positiveCount {

                        translation = otherAxisConfig.direction * gridSize * Double(i - positiveCount) * -1                 

                    } else {

                        translation = otherAxisConfig.direction * gridSize * Double(i)
                    }

                    lines.append(DrawableLine(

                        start: mainAxisLine.start + translation,

                        end: mainAxisLine.end + translation,

                        thickness: gridLineThickness,

                        color: gridLineColor
                    ))
                }
            }
        }

        lineRenderer.updateBuffers(lines: lines)
    }

    public func render(scene: Scene, context: GLRenderContext) {

        lineRenderer.render(context: context)
    }
}

extension GLGridRenderer {

    public struct AxisConfig {

        public var direction: DVec3

        public var crossDirection: DVec3

        public var positiveLength: Double

        public var negativeLength: Double

        public var color: Color
    }
}