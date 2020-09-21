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


    public init() {}


    public func setup() {

        do {

            try shaderProgram.compile()

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

        /*glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        var vertices = [DVec3]()

        let gridSize = 0.5

        let axisWidth = 0.01

        let gridWidth = 0.001

        let axisConfigs = [

            (direction: DVec3(1, 0, 0), positiveLength: 20.0, negativeLength: 20.0, color: Color.Red),

            (direction: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0, color: .Green),

            (direction: DVec3(0, 0, 1), positiveLength: 20.0, negativeLength: 20.0, color: .Blue)
        ]

        

        let bufferData = vertices.flatMap { $0.elements.map(Float.init) }

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * bufferData.count, bufferData, GLMap.DYNAMIC_DRAW)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)*/
    }

    /*public func getLineVertices(from start: DVec3, to end: DVec3, orthogonalTo orthogonalDirection: DVec3, width: Double) -> [DVec3] {

        let mainDirection = (start - end).normalized()

        let crossDirection = mainDirection.cross(orthogonalDirection).normalized()

        let vertices: [DVec3] = [

            start - crossDirection * width,

            end - crossDirection * width,

            end + crossDirection * width,

            start - crossDirection * width,

            end + crossDirection * width,

            start + crossDirection * width
        ]

        return vertices
    }*/

    public func render(scene: Scene, context: GLRenderContext) {

        shaderProgram.use()

        glUniformMatrix4fv(

            glGetUniformLocation(shaderProgram.id, "viewTransformation"),

            1,

            true,

            context.viewTransformation.elements) /*context.projectionTransformation.matmul(context.cameraTransformation/*Matrix4([

                1, 0, 0, scene.camera.position.x,

                0, 1, 0, scene.camera.position.y,

                0, 0, 1, scene.camera.position.z,

                0, 0, 0, 1

            ].map(Float.init))*/).elements)*/
        
        /*let orientationTransformation = Matrix4<Float>([

            scene.camera.forward.x, 0, 0, 0,

            scene.camera.forward.y, 1, 0, 0,

            scene.camera.forward.z, 0, 1, 0,

            0, 0, 0, 1

        ].map(Float.init))

        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "orientationTransformation"), 1, true, orientationTransformation.elements)*/


        glBindVertexArray(vao)

        

        glDrawArraysInstanced(GLMap.TRIANGLES, 0, GLMap.Size(vertices.count), GLMap.Size(lineCount))


        glBindVertexArray(0)
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