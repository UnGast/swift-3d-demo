import GL

import CustomGraphicsMath

public class GLLineRenderer {

    private var shaderProgram = ShaderProgram(

        vertex: vertexSource,
        
        fragment: fragmentSource
    )

    lazy private var vertexArray = buildVertexArray()

    lazy private var vertexBuffer = GLBuffer()

    /*private var vao = GLMap.UInt()

    private var vbo = GLMap.UInt()*/

    private var lineCount: Int = 0

    private func buildVertexArray() -> GLVertexArray {

        vertexBuffer.setup()

        return GLVertexArray(attributes: [

            GLVertexArray.ContiguousAttributes(buffer: vertexBuffer, attributes: [

                GLVertexAttribute(
                    
                    location: 0, 

                    dataType: Float.self,

                    length: 3
                ),

                GLVertexAttribute(

                    location: 1,

                    dataType: Float.self,

                    length: 4
                )
            ])
        ])
    }

    public func setup() throws {

        try shaderProgram.compile()

        vertexArray.setup()
    }

    public func updateBuffers(lines: [DrawableLine]) {

        var vertexData: [Float] = []

        for line in lines {

            vertexData.append(contentsOf: line.start.elements.map(Float.init))

            vertexData.append(contentsOf: line.color.gl)

            vertexData.append(contentsOf: line.end.elements.map(Float.init))

            vertexData.append(contentsOf: line.color.gl)
        }

        vertexBuffer.bind(GLMap.ARRAY_BUFFER)

        vertexBuffer.store(vertexData)

        lineCount = lines.count
    }

    public func render(context: GLRenderContext) {
        
        shaderProgram.use()

        vertexArray.bind()

        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "viewProjectionTransformation"), 1, true, context.viewTransformation.elements)
        
        glLineWidth(20.0)

        glDrawArrays(GLMap.LINES, 0, GLMap.Int(lineCount * 2))

        glBindVertexArray(0)
    }
}

extension GLLineRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 positionIn;

    layout (location = 1) in vec4 colorIn;

    uniform mat4 viewProjectionTransformation;

    out VERTEX_OUT {
        
        vec4 color;

    } vs_out;

    void main() {

        gl_Position = viewProjectionTransformation * vec4(positionIn, 1);

        vs_out.color = colorIn;
    }
    """

    /*private static let geometrySource = """
    #version 330 core

    layout (lines) in;

    in VERTEX_OUT {

        vec4 color;

    } gs_in[];

    layout (line_strip, max_vertices = 2) out;

    out vec4 color;

    void main() {

        gl_Position = gl_in[0].gl_Position;
        color = gs_in[0].color;
        EmitVertex();

        gl_Position = gl_in[1].gl_Position;
        color = gs_in[1].color;
        EmitVertex();

        EndPrimitive();
    }
    """*/

    private static let fragmentSource = """
    #version 330 core

    in VERTEX_OUT {

        vec4 color;

    } fs_in;

    out vec4 FragColor;

    void main() {

        FragColor = fs_in.color;
    }
    """
}