import CustomGraphicsMath
import GL

public class GLGridRenderer {

    private var shaderProgram = ShaderProgram(

        vertex: GLGridRenderer.vertexSource,

        fragment: GLGridRenderer.fragmentSource
    )

    private var vao = GLMap.UInt()

    private var vbo = GLMap.UInt()

    public var viewTransformation: Matrix4<Float> = .zero


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

        let stride = GLMap.Size(MemoryLayout<Float>.size * 3)

        glVertexAttribPointer(0, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: 0))
        glEnableVertexAttribArray(0)

        glBindVertexArray(0)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)
    }

    public func getLineVertices(from start: DVec3, to end: DVec3, orthogonalTo orthogonalDirection: DVec3, width: Double) -> [DVec3] {

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
    }

    public func render(scene: Scene) {

        shaderProgram.use()

        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "viewTransformation"), 1, true, viewTransformation.elements)
        
        let orientationTransformation = Matrix4<Float>([

            scene.camera.forward.x, 0, 0, 0,

            scene.camera.forward.y, 1, 0, 0,

            scene.camera.forward.z, 0, 1, 0,

            0, 0, 0, 1

        ].map(Float.init))

        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "orientationTransformation"), 1, true, orientationTransformation.elements)


        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        var vertices = [DVec3]()

        let gridSize = 0.5

        let axisWidth = 0.01

        let gridWidth = 0.001

        let axisConfigs = [

            (direction: DVec3(1, 0, 0), positiveLength: 20.0, negativeLength: 20.0),

            (direction: DVec3(0, 1, 0), positiveLength: 20.0, negativeLength: 20.0),

            (direction: DVec3(0, 0, 1), positiveLength: 20.0, negativeLength: 20.0)
        ]

        for (i, axisConfig) in axisConfigs.enumerated() {

            vertices.append(

                contentsOf: getLineVertices(

                    from: axisConfig.direction * axisConfig.positiveLength,
                    
                    to: axisConfig.direction * axisConfig.negativeLength * -1,
                    
                    orthogonalTo: DVec3(1, 0, 0),
                    
                    width: axisWidth)
            )

            for (j, otherAxisConfig) in axisConfigs.enumerated() {

                if j == i {

                    continue
                }

                let positiveCount = Int(axisConfig.positiveLength / gridSize)

                let negativeCount = Int(axisConfig.negativeLength / gridSize)

                for i in 0..<(negativeCount + positiveCount) {

                    let mainAxisPosition: DVec3

                    if i >= positiveCount {

                        mainAxisPosition = axisConfig.direction * gridSize * Double(i - positiveCount) * -1                 

                    } else {

                        mainAxisPosition = axisConfig.direction * gridSize * Double(i)

                    }


                    vertices.append(

                        contentsOf: getLineVertices(
                            
                            from: mainAxisPosition + otherAxisConfig.direction * otherAxisConfig.positiveLength,
                            
                            to: mainAxisPosition + otherAxisConfig.direction * otherAxisConfig.negativeLength * -1,
                            
                            orthogonalTo: DVec3(1, 0, 0),
                            
                            width: gridWidth)
                    )
                }
            }
        }

        let bufferData = vertices.flatMap { $0.elements.map(Float.init) }

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * bufferData.count, bufferData, GLMap.DYNAMIC_DRAW)

        glDrawArrays(GLMap.TRIANGLES, 0, GLMap.Size(vertices.count))


        glBindVertexArray(0)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)
    }
}

extension GLGridRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 vertexPosition;

    uniform mat4 viewTransformation;

    uniform mat4 orientationTransformation;

    void main() {

        gl_Position = viewTransformation * orientationTransformation * vec4(vertexPosition, 1);
    }
    """

    private static let fragmentSource = """
    #version 330 core

    out vec4 FragColor;

    void main() {

        FragColor = vec4(0, 1, 0, 1);
    }
    """
}