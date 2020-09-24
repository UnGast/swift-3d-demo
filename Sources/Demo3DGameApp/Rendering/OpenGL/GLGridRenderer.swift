import CustomGraphicsMath
import GL

public class GLGridRenderer {

    public var axisConfigs = [
        
        AxisConfig(direction: DVec3(1, 0, 0), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Red),

        AxisConfig(direction: DVec3(0, 1, 0), crossDirection: DVec3(1, 0, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Green),

        AxisConfig(direction: DVec3(0, 0, 1), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Blue)
    ]

    private var mainAxisLineThickness = 0.1

    private var gridLineThickness = 0.001

    private var gridLineColor = Color.White

    private var gridSize = 0.5

    private var lines: [DrawableLine] = []

    private let lineRenderer: GLLineRenderer

    private var arrowShaderProgram = GLShaderProgram(

        vertex: GLGridRenderer.arrowVertexShader,

        fragment: GLGridRenderer.arrowFragmentShader
    )

    lazy private var arrowVertexArray = GLVertexArray(attributes: [

        GLVertexArray.ContiguousAttributes(buffer: arrowVertexBuffer, attributes: [

            GLVertexAttribute(location: 0, dataType: Float.self, length: 3),
            
            GLVertexAttribute(location: 1, dataType: Float.self, length: 4)
        ])
    ])

    private var arrowVertexBuffer = GLBuffer()


    public init() {

        lineRenderer = GLLineRenderer()
    }


    public func setup() throws {

        try lineRenderer.setup()

        try arrowShaderProgram.compile()

        arrowVertexBuffer.setup()

        arrowVertexArray.setup()

        updateBuffers()
    }

    private func updateBuffers() {

        var arrowVertexData = [Float]()

        lines = [DrawableLine]()

        for (i, axisConfig) in axisConfigs.enumerated() {

            let mainAxisLine = DrawableLine(
                
                start: axisConfig.direction * axisConfig.positiveLength,
                
                end: -axisConfig.direction * axisConfig.negativeLength,

                thickness: mainAxisLineThickness,

                color: axisConfig.color)
            
            lines.append(mainAxisLine)

            let triangleAxisConfig = GLCoordinateSystem.getPredictableAxisConfig(from: axisConfig.direction)

            let triangleApex = axisConfig.direction * axisConfig.positiveLength

            let triangleBasePoint1 = triangleApex - triangleAxisConfig.forward * 2 - triangleAxisConfig.right * 0.5

            let triangleBasePoint2 = triangleApex - triangleAxisConfig.forward * 2 + triangleAxisConfig.right * 0.5

            arrowVertexData.append(contentsOf: triangleApex.elements.map(Float.init))
            arrowVertexData.append(contentsOf: axisConfig.color.gl)
            arrowVertexData.append(contentsOf: triangleBasePoint1.elements.map(Float.init))
            arrowVertexData.append(contentsOf: axisConfig.color.gl)
            arrowVertexData.append(contentsOf: triangleBasePoint2.elements.map(Float.init))
            arrowVertexData.append(contentsOf: axisConfig.color.gl)

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

        arrowVertexBuffer.bind(GLMap.ARRAY_BUFFER)

        arrowVertexBuffer.store(arrowVertexData)
    }

    public func render(scene: Scene, context: GLRenderContext) {

        lineRenderer.render(context: context)

        arrowShaderProgram.use()

        arrowShaderProgram.setUniform("viewProjectionTransformation", context.viewTransformation, transpose: true)

        arrowVertexArray.bind()

        glDisable(GLMap.DEPTH_TEST)

        glDrawArrays(GLMap.TRIANGLES, 0, 3 * 3)
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

    private static var arrowVertexShader = """
    #version 330 core

    layout (location = 0) in vec3 positionIn;
    layout (location = 1) in vec4 colorIn;

    uniform mat4 viewProjectionTransformation;

    out vec4 color;

    void main() {

        gl_Position = viewProjectionTransformation * vec4(positionIn, 1);

        color = colorIn;
    }
    """

    private static var arrowFragmentShader = """
    #version 330 core

    in vec4 color;

    out vec4 FragColor;

    void main() {

        FragColor = color;
    }
    """
}