import CustomGraphicsMath
import GL

public class GLGridRenderer {

    private var shaderProgram = ShaderProgram(

        vertex: GLGridRenderer.vertexSource,

        fragment: GLGridRenderer.fragmentSource
    )

    private var vao = GLMap.UInt()

    private var vbo = GLMap.UInt()

    private var instancedMainBuffer = GLMap.UInt()

    private var instancedColorBuffer = GLMap.UInt()

    private let vertices: [Float] = [

        0, 0, 0,

        1, 0, 0,

        1, 0, -1,

        0, 0, 0,

        1, 0, -1,

        0, 0, -1
    ]

    public var axisConfigs = [
        
        AxisConfig(direction: DVec3(1, 0, 0), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Red),

        AxisConfig(direction: DVec3(0, 1, 0), crossDirection: DVec3(1, 0, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Green),

        AxisConfig(direction: DVec3(0, 0, 1), crossDirection: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Blue)
    ]

    private var mainAxisLineWidth = 0.005

    private var gridLineWidth = 0.001

    private var gridSize = 0.5

    private var lineCount = 0

    private var lines: [DrawableLine] = []

    private let lineRenderer: GLLineRenderer


    public init() {

        lineRenderer = GLLineRenderer()
    }


    public func setup() {

        do {

            try shaderProgram.compile()

            try lineRenderer.setup()

        } catch {

            print("Error while compiling shader program.", error)
        }

        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)


        glGenBuffers(1, &vbo)
        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)
        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * vertices.count, vertices, GLMap.STATIC_DRAW)

        let vertexStride = GLMap.Size(MemoryLayout<Float>.size * 3)

        glVertexAttribPointer(0, 3, GLMap.FLOAT, false, vertexStride, nil)
        glEnableVertexAttribArray(0)


        glGenBuffers(1, &instancedMainBuffer)
        glBindBuffer(GLMap.ARRAY_BUFFER, instancedMainBuffer)

        let instancedMainStride = GLMap.Size(MemoryLayout<Float>.size * 16)

        glVertexAttribPointer(1, 4, GLMap.FLOAT, false, instancedMainStride, nil)
        glVertexAttribDivisor(1, 1)
        glEnableVertexAttribArray(1)

        glVertexAttribPointer(2, 4, GLMap.FLOAT, false, instancedMainStride, UnsafeRawPointer(bitPattern: MemoryLayout<Float>.size * 4))
        glVertexAttribDivisor(2, 1)
        glEnableVertexAttribArray(2)
        
        glVertexAttribPointer(3, 4, GLMap.FLOAT, false, instancedMainStride, UnsafeRawPointer(bitPattern: MemoryLayout<Float>.size * 8))
        glVertexAttribDivisor(3, 1)
        glEnableVertexAttribArray(3)

        glVertexAttribPointer(4, 4, GLMap.FLOAT, false, instancedMainStride, UnsafeRawPointer(bitPattern: MemoryLayout<Float>.size * 12))
        glVertexAttribDivisor(4, 1)
        glEnableVertexAttribArray(4)

        glGenBuffers(1, &instancedColorBuffer)
        glBindBuffer(GLMap.ARRAY_BUFFER, instancedColorBuffer)

        let instancedColorStride = GLMap.Size(MemoryLayout<Float>.size * 4)

        glVertexAttribPointer(5, 3, GLMap.FLOAT, false, instancedColorStride, nil)
        glVertexAttribDivisor(5, 1)
        glEnableVertexAttribArray(5)


        glBindVertexArray(0)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        updateBuffers()
    }

    private func updateBuffers() {

        lineCount = 0

        var lineTransformations = [Float]()

        var colors = [Float]()

        lines = [DrawableLine]()

        for (i, axisConfig) in axisConfigs.enumerated() {

            let baseAxisLineTransformation = Matrix4<Float>([

                axisConfig.direction.x, 0, axisConfig.crossDirection.x, 0,

                axisConfig.direction.y, 1, axisConfig.crossDirection.y, 0,

                axisConfig.direction.z, 0, axisConfig.crossDirection.z, 0,

                0, 0, 0, 1

            ].map(Float.init)).matmul(Matrix4<Float>([

                axisConfig.positiveLength + axisConfig.negativeLength, 0, 0, -axisConfig.negativeLength,

                0, 1, 0, 0,

                0, 0, mainAxisLineWidth, 0,

                0, 0, 0, 1

            ].map(Float.init)))

            lines.append(DrawableLine(
                
                start: axisConfig.direction * axisConfig.positiveLength,
                
                end: -axisConfig.direction * axisConfig.negativeLength,

                thickness: 2,

                color: .Yellow
            ))
            
            lineTransformations.append(contentsOf: baseAxisLineTransformation.transposed().elements)

            colors.append(contentsOf: [axisConfig.color.glR, axisConfig.color.glG, axisConfig.color.glB, axisConfig.color.glA])

            lineCount += 1

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

                    let gridTransformation = Matrix4<Float>([

                        1, 0, 0, translation.x,

                        0, 1, 0, translation.y,

                        0, 0, 1, translation.z,

                        0, 0, 0, 1

                    ].map(Float.init)).matmul(baseAxisLineTransformation)

                    lineTransformations.append(contentsOf: gridTransformation.transposed().elements)

                    colors.append(contentsOf: [1.0, 1.0, 1.0, 1.0])

                    lineCount += 1
                }
            }
        }

        glBindBuffer(GLMap.ARRAY_BUFFER, instancedMainBuffer)
        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * lineTransformations.count, lineTransformations, GLMap.STATIC_DRAW)
        
        print("LINE TRANSFORMATIONs", lineTransformations.count, lineTransformations.count / 16, lineCount)

        glBindBuffer(GLMap.ARRAY_BUFFER, instancedColorBuffer)
        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * colors.count, colors, GLMap.STATIC_DRAW)
        
        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        lineRenderer.updateBuffers(lines: lines)
    }

    public func render(scene: Scene, context: GLRenderContext) {

        shaderProgram.use()

        glUniformMatrix4fv(

            glGetUniformLocation(shaderProgram.id, "viewTransformation"),

            1,

            true,

            context.viewTransformation.elements)


        glBindVertexArray(vao)

        
        // TODO: maybe abstract opengl state into a state manager and only call the functions that
        // really change the state at any given time (avoid unnecessary calls if state is set to required value anyways)
        glEnable(GLMap.DEPTH_TEST)

        glDrawArraysInstanced(GLMap.TRIANGLES, 0, GLMap.Size(vertices.count), GLMap.Size(lineCount))


        glBindVertexArray(0)


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

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 vertexPosition;
    layout (location = 1) in mat4 lineTransformation;
    layout (location = 5) in vec4 color;

    uniform mat4 viewTransformation;

    out VERTEXOUT
    {

        vec4 color;

    } vertexout;

    void main() {

        gl_Position = viewTransformation * lineTransformation * vec4(vertexPosition, 1);

        vertexout.color = color;
    }
    """

    private static let fragmentSource = """
    #version 330 core

    in VERTEXOUT
    {

        vec4 color;

    } vertexout;

    out vec4 FragColor;

    void main() {

        FragColor = vertexout.color;
    }
    """
}