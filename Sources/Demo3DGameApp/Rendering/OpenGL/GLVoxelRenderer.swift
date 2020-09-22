import Foundation
import GL
import CustomGraphicsMath

public class GLVoxelRenderer {

    private let shaderProgram = ShaderProgram(

        vertex: GLVoxelRenderer.vertexSource,
        
        fragment: GLVoxelRenderer.fragmentSource
    )

    private var vao: GLMap.UInt = 0

    private var vertexBuffer = GLBuffer()

    private var indexBuffer = GLBuffer()

    private var instanceBuffer = GLBuffer()

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

            
            vertexBuffer.setup()
            vertexBuffer.bind(GLMap.ARRAY_BUFFER)
            let vertexBufferData = GLVoxelRenderer.vertices.flatMap { $0.position.elements.map(Float.init) + $0.normal.elements.map(Float.init) }
            vertexBuffer.store(vertexBufferData)

            indexBuffer.setup()
            indexBuffer.bind(GLMap.ELEMENT_ARRAY_BUFFER)
            indexBuffer.store(GLVoxelRenderer.indices)


            let stride = GLMap.Size(MemoryLayout<GLMap.Float>.size * 6)

            glVertexAttribPointer(0, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(0)

            glVertexAttribPointer(1, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLMap.Float>.size * 3))
            glEnableVertexAttribArray(1)


            instanceBuffer.setup()
            instanceBuffer.bind(GLMap.ARRAY_BUFFER)

            let instanceDataStride = GLMap.Size(MemoryLayout<GLMap.Float>.size * 4)

            glVertexAttribPointer(2, 3, GLMap.FLOAT, false, instanceDataStride, UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(2)
            glVertexAttribDivisor(2, 1)

            glVertexAttribPointer(3, 1, GLMap.FLOAT, false, instanceDataStride, UnsafeRawPointer(bitPattern: 3))
            glEnableVertexAttribArray(3)
            glVertexAttribDivisor(3, 1)


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


        let instanceData = voxels.flatMap {

            $0.position.elements.map(Float.init) + [$0.highlighted ? Float(1) : Float(0)]
        }

        for voxel in voxels {

            if voxel.highlighted {

                print("HAVE HIGHLIGHTED VOXEL")
            }
        }

        instanceBuffer.bind(GLMap.ARRAY_BUFFER)

        instanceBuffer.store(instanceData)

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

    layout (location = 3) in float highlighted;

    uniform mat4 viewTransformation;

    out VERTEXOUT {

        vec3 normal;

        float highlighted;

    } vertexOut;

    void main() {
        
        gl_Position = viewTransformation * vec4(vertexPosition + translation, 1);

        vertexOut.normal = vertexNormal;

        vertexOut.highlighted = highlighted;
    }
    """

    private static let fragmentSource = """
    #version 330 core

    in VERTEXOUT{

        vec3 normal;

        float highlighted;

    } vertexOut;

    //in float Highlighted;

    out vec4 FragColor;

    void main() {

        if (vertexOut.highlighted > 0) {

            FragColor = vec4(0, 1,  0, 1);

        } else {

            FragColor = vec4((max(0, dot(vertexOut.normal, vec3(1, 1, 0))) * 0.6 + 0.3) * vec3(1.0, 1.0, 1.0), 1.0);
        }
    }
    """
}