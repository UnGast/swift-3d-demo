import Foundation
import GL
import CustomGraphicsMath

public class GLVoxelRenderer {

    private let shaderProgram = ShaderProgram(

        vertex: GLVoxelRenderer.vertexSource,
        
        fragment: GLVoxelRenderer.fragmentSource
    )

    lazy private var vertexArray = setupVertexArray()

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


    private func setupVertexArray() -> GLVertexArray {

        vertexBuffer.setup()

        indexBuffer.setup()

        instanceBuffer.setup()

        return GLVertexArray(attributes: [

            GLVertexArray.ContiguousAttributes(buffer: vertexBuffer, indexBuffer: indexBuffer, attributes: [

                GLVertexAttribute(

                    location: 0,

                    dataType: Float.self,

                    length: 3
                ),

                GLVertexAttribute(

                    location: 1,

                    dataType: Float.self,

                    length: 3
                ),
            ]),

            GLVertexArray.ContiguousAttributes(buffer: instanceBuffer, attributes: [

                GLVertexAttribute(

                    location: 2,

                    dataType: Float.self,

                    length: 3,

                    divisor: 1
                ),

                GLVertexAttribute(

                    location: 3,

                    dataType: Float.self,

                    length: 1,

                    divisor: 1
                ),
            ])
        ])
    }

    public func setup() {

        do {
            
            try shaderProgram.compile()


            vertexArray.setup()

            
            vertexBuffer.bind(GLMap.ARRAY_BUFFER)
            let vertexBufferData = GLVoxelRenderer.vertices.flatMap { $0.position.elements.map(Float.init) + $0.normal.elements.map(Float.init) }
            vertexBuffer.store(vertexBufferData)

            indexBuffer.bind(GLMap.ELEMENT_ARRAY_BUFFER)
            indexBuffer.store(GLVoxelRenderer.indices)

        } catch {

            print("Error in setup", error)
        }
    }

    public func render(voxels: [Voxel], camera: Camera) {

        shaderProgram.use()

        vertexArray.bind()


        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "viewTransformation"), 1, true, viewTransformation.elements)

        var normalVoxelCount = 0

        var normalInstanceData = [Float]()

        var highlightedVoxelCount = 0

        var highlightedInstanceData = [Float]()

        for voxel in voxels {

            if voxel.highlighted {

                highlightedInstanceData.append(contentsOf: voxel.position.elements.map(Float.init) + [1])

                highlightedVoxelCount += 1

            } else {

                normalInstanceData.append(contentsOf: voxel.position.elements.map(Float.init) + [0])

                normalVoxelCount += 1
            }
        }

        instanceBuffer.bind(GLMap.ARRAY_BUFFER)

        instanceBuffer.store(normalInstanceData)

        glEnable(GLMap.DEPTH_TEST)

        glDrawElementsInstanced(GLMap.TRIANGLES, GLMap.Size(GLVoxelRenderer.indices.count), GLMap.UNSIGNED_INT, nil, GLMap.Size(normalVoxelCount))

        instanceBuffer.store(highlightedInstanceData)

        glDisable(GLMap.DEPTH_TEST)

        glDrawElementsInstanced(GLMap.TRIANGLES, GLMap.Size(GLVoxelRenderer.indices.count), GLMap.UNSIGNED_INT, nil, GLMap.Size(highlightedVoxelCount))

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