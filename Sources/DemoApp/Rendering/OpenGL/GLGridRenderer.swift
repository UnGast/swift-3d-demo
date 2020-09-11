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


        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        var vertices = [DVec3]()

        let axes = [

            DVec3(1, 0, 0),

            DVec3(0, 1, 0),

            DVec3(0, 0, 1)
        ]

        let lineLength = 20.0

        for axis in axes {

            vertices.append(

                contentsOf: getLineVertices(

                    from: axis * lineLength / 2,
                    
                    to: -axis * lineLength / 2,
                    
                    orthogonalTo: scene.camera.forward,
                    
                    width: 0.01)
            )
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

    void main() {

        gl_Position = viewTransformation * vec4(vertexPosition, 1);
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