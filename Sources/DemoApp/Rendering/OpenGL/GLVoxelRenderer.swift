import Foundation
import GL
import CustomGraphicsMath

public class GLVoxelRenderer {

    private let shaderProgram = ShaderProgram(

        vertex: GLVoxelRenderer.vertexSource,
        
        fragment: GLVoxelRenderer.fragmentSource
    )

    private var vao: GLMap.UInt = 0

    private var vbo: GLMap.UInt = 0

    private var ebo: GLMap.UInt = 0

    private var instanceDataBuffer: GLMap.UInt = 0

    private static var vertices: [Vertex] = [

        // top
        Vertex(DVec3(-0.5, 0.5, 0.5), DVec3(0, 1, 0)),

        Vertex(DVec3(0.5, 0.5, 0.5), DVec3(0, 1, 0)),

        Vertex(DVec3(0.5, 0.5, -0.5), DVec3(0, 1, 0)),
        
        Vertex(DVec3(-0.5, 0.5, -0.5), DVec3(0, 1, 0)),

        // front
        Vertex(DVec3(-0.5, -0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(0.5, -0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(0.5, 0.5, 0.5), DVec3(0, 0, 1)),

        Vertex(DVec3(-0.5, 0.5, 0.5), DVec3(0, 0, 1)),

        // right
        Vertex(DVec3(0.5, -0.5, 0.5), DVec3(1, 0, 0)),

        Vertex(DVec3(0.5, -0.5, -0.5), DVec3(1, 0, 0)),
        
        Vertex(DVec3(0.5, 0.5, -0.5), DVec3(1, 0, 0)),

        Vertex(DVec3(0.5, 0.5, 0.5), DVec3(1, 0, 0)),

        // bottom
        Vertex(DVec3(-0.5, -0.5, -0.5), DVec3(0, -1, 0)),

        Vertex(DVec3(0.5, -0.5, -0.5), DVec3(0, -1, 0)),

        Vertex(DVec3(0.5, -0.5, 0.5), DVec3(0, -1, 0)),

        Vertex(DVec3(-0.5, -0.5, 0.5), DVec3(0, -1, 0)),

        // left
        Vertex(DVec3(-0.5, -0.5, -0.5), DVec3(-1, 0, 0)),
        
        Vertex(DVec3(-0.5, -0.5, 0.5), DVec3(-1, 0, 0)),

        Vertex(DVec3(-0.5, 0.5, 0.5), DVec3(-1, 0, 0)),

        Vertex(DVec3(-0.5, 0.5, -0.5), DVec3(-1, 0, 0)),

        // back
        Vertex(DVec3(0.5, -0.5, -0.5), DVec3(0, 0, -1)),

        Vertex(DVec3(-0.5, -0.5, -0.5), DVec3(0, 0, -1)),

        Vertex(DVec3(-0.5, 0.5, -0.5), DVec3(0, 0, -1)),

        Vertex(DVec3(0.5, 0.5, -0.5), DVec3(0, 0, -1))
    ]

    private static var indices: [GLMap.UInt] = [

        // top
        0, 1, 2,

        0, 2, 3,

        // front
        4, 5, 6,

        4, 6, 7,

        // right
        8, 9, 10,

        8, 10, 11,

        // bottom
        12, 13, 14,

        12, 14, 15,
        
        // left
        16, 17, 18,

        16, 18, 19,

        // back
        20, 21, 22,

        20, 22, 23
    ]

    public var viewTransformation: Matrix4<Float> = .zero


    public func setup() {

        do {
            
            try shaderProgram.compile()


            glGenVertexArrays(1, &vao)
            glBindVertexArray(vao)


            glGenBuffers(1, &vbo)
            glBindBuffer(GLMap.ARRAY_BUFFER, vbo)
            let vertexBufferData = GLVoxelRenderer.vertices.flatMap { $0.position.elements.map(Float.init) + $0.normal.elements.map(Float.init) }
            glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<GLMap.Float>.size * vertexBufferData.count, vertexBufferData, GLMap.STATIC_DRAW)

            glGenBuffers(1, &ebo)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, ebo)
            glBufferData(GLMap.ELEMENT_ARRAY_BUFFER, MemoryLayout<GLMap.UInt>.size * GLVoxelRenderer.indices.count, GLVoxelRenderer.indices, GLMap.STATIC_DRAW)

            let stride = GLMap.Size(MemoryLayout<GLMap.Float>.size * 6)

            glVertexAttribPointer(0, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(0)

            glVertexAttribPointer(1, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLMap.Float>.size * 3))
            glEnableVertexAttribArray(1)


            glGenBuffers(1, &instanceDataBuffer)
            glBindBuffer(GLMap.ARRAY_BUFFER, instanceDataBuffer)

            let instanceDataStride = GLMap.Size(MemoryLayout<GLMap.Float>.size * 3)

            glVertexAttribPointer(2, 3, GLMap.FLOAT, false, instanceDataStride, UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(2)
            glVertexAttribDivisor(2, 1)


            glBindVertexArray(0)

            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, 0)

            glBindBuffer(GLMap.ARRAY_BUFFER, 0)


        } catch {

            print("Error in setup", error)
        }
    }

    public func render(voxels: [Voxel], camera: Camera) {

        shaderProgram.use()

        glBindVertexArray(vao)


        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "viewTransformation"), 1, true, viewTransformation.elements)


        glBindBuffer(GLMap.ARRAY_BUFFER, instanceDataBuffer)

        let instanceData = voxels.flatMap { $0.position.elements.map(Float.init) }

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<GLMap.Float>.size * instanceData.count, instanceData, GLMap.DYNAMIC_DRAW)

        /*let testData: [GLMap.Float] = [

            0, 0, 0, 0, 0, 0,

            1, 0, 0, 0, 0, 0,

            0, 1, 0, 0, 0, 0
        ]

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * testData.count, testData, GLMap.STATIC_DRAW)

        glDrawArrays(GLMap.TRIANGLES, 0, GLMap.Size(3))*/


        glDrawElementsInstanced(GLMap.TRIANGLES, GLMap.Size(GLVoxelRenderer.indices.count), GLMap.UNSIGNED_INT, nil, GLMap.Size(voxels.count))

        glBindVertexArray(0)
    }
}

extension GLVoxelRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 vertexPosition;

    layout (location = 1) in vec3 vertexNormal;

    layout (location = 2) in vec3 translation;

    uniform mat4 viewTransformation;

    out vec3 Normal;

    void main() {
        
        gl_Position = viewTransformation * vec4(vertexPosition + translation, 1);

        Normal = vertexNormal;
    }
    """

    private static let fragmentSource = """
    #version 330 core

    in vec3 Normal;

    //in float Highlighted;

    out vec4 FragColor;

    void main() {

        FragColor = vec4((dot(Normal, vec3(1, 1, 0)) + 0.2) * vec3(1.0, 1.0, 1.0), 1.0);
    }
    """
}