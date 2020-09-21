import GL

import CustomGraphicsMath

public class GLLineRenderer {

    private var shaderProgram = ShaderProgram(
        vertex: vertexSource,
        fragment: fragmentSource
    )

    private var vao = GLMap.UInt()

    private var vbo = GLMap.UInt()

    private var lineCount: Int = 0

    public func setup() throws {

        try shaderProgram.compile()

        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)

        glGenBuffers(1, &vbo)
        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        glVertexAttribPointer(0, 3, GLMap.FLOAT, false, GLMap.Size(MemoryLayout<Float>.size * 3), nil)
        glEnableVertexAttribArray(0)

        glBindVertexArray(0)
        glBindBuffer(GLMap.ARRAY_BUFFER, 0)        
    }

    public func updateBuffers(lines: [DrawableLine]) {

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)
        
        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<GLMap.Float>.size * 3 * lines.count * 2, lines.flatMap { $0.start.elements + $0.end.elements }.map(Float.init), GLMap.STATIC_DRAW)

        glBindBuffer(GLMap.ARRAY_BUFFER, 0)

        lineCount = lines.count
    }

    public func render(context: GLRenderContext) {
        
        shaderProgram.use()

        glBindVertexArray(vao)

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

    uniform mat4 viewProjectionTransformation;

    void main() {

        gl_Position = viewProjectionTransformation * vec4(positionIn, 1);
    }
    """

    private static let fragmentSource = """
    #version 330 core

    out vec4 FragColor;

    void main() {

        FragColor = vec4(1, 1, 1, 1);
    }
    """
}