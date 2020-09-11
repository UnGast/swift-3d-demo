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

   // private 

    private static var baseVertices: [Vertex] = [

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

    /*
    private let worldTransformation = Matrix4<GLMap.Float>([
        
        0.4, 0, 0.9, 0,

        0, 1, 0, 0,

        0, 0, 1, 0,

        0, 0, 0, 1
    ])

    private let cameraToWorldTransformation = Matrix4<GLMap.Float>([

        1, 0, 0, 0,

        0, 1, 0, 0,

        0, 0, 1, 0,

        0, 0, 0, 1
    ])*/

    public func setup() {

        do {
            
            try shaderProgram.compile()

            glGenVertexArrays(1, &vao)
            glBindVertexArray(vao)

            glGenBuffers(1, &vbo)
            glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

            glGenBuffers(1, &ebo)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, ebo)
            glBufferData(GLMap.ELEMENT_ARRAY_BUFFER, MemoryLayout<GLMap.UInt>.size * GLVoxelRenderer.indices.count, GLVoxelRenderer.indices, GLMap.STATIC_DRAW)

            let stride = GLMap.Size(MemoryLayout<GLMap.Float>.size * 7)

            glVertexAttribPointer(0, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: 0))
            glEnableVertexAttribArray(0)

            glVertexAttribPointer(1, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLMap.Float>.size * 3))
            glEnableVertexAttribArray(1)

            glVertexAttribPointer(2, 1, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern: MemoryLayout<GLMap.Float>.size * 6))
            glEnableVertexAttribArray(2)



            //glVertexAttribPointer(0, 3, GLMap.FLOAT, false, stride, UnsafeRawPointer(bitPattern))

            glBindVertexArray(0)
            glBindBuffer(GLMap.ARRAY_BUFFER, 0)
            glBindBuffer(GLMap.ELEMENT_ARRAY_BUFFER, 0)

        } catch {

            print("Error in setup", error)
        }
    }

    public func render(voxels: [Voxel], camera: Camera) {

        shaderProgram.use()

        glBindVertexArray(vao)

        glBindBuffer(GLMap.ARRAY_BUFFER, vbo)

        let transformation = Matrix4<GLMap.Float>([

            camera.right.x, camera.up.x, camera.forward.x, camera.position.x,

            camera.right.y, camera.up.y, camera.forward.y, camera.position.y,

            camera.right.z, camera.up.z, camera.forward.z, camera.position.z,

            0, 0, 0, 1

        ].map(Float.init))

        let near = 0.1

        let far = 100.0

        let fov = camera.fov

        let scale = 1 / (tan(fov / 2.0 * Double.pi / 180.0))

        let projection = Matrix4<GLMap.Float>([

            Float(scale), 0, 0, 0,

            0, Float(scale), 0, 0,

            0, 0, Float(-far/(far - near)), Float(-(far * near)/(far - near)),

            0, 0, -1, 0
        ])

        // let compundTransformation = cameraToWorldTransformation.matmul(worldTransformation)

        var bufferData = [GLMap.Float]()

        for voxel in voxels {

            for vertex in GLVoxelRenderer.baseVertices {

                var position = Vector4<Float>((vertex.position + voxel.position).elements.map(Float.init) + [1])

                position = Vector4(projection.matmul(transformation.matmul(position)).elements)

                position /= position.w

                let normal = transformation.matmul(Vector4<Float>(vertex.normal.elements.map(Float.init) + [1]))

                bufferData.append(contentsOf: position.elements[..<3])

                bufferData.append(contentsOf: normal.elements[..<3])

                bufferData.append(voxel.highlighted ? 1 : 0)
            }
        }

        //print("BUFFER DATA", bufferData.count, indices.count * voxels.count)

        /*let vertices = voxels.flatMap { voxel in

            baseVertices.flatMap { vertex -> [Float] in

                let vertex4 = Vector4<Float>((vertex + voxel.position).elements.map(Float.init) + [1])

                return (worldTransformation * vertex4).elements[..<3].map { Float($0) } }
        }*/

        glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * bufferData.count, bufferData, GLMap.STATIC_DRAW)

        /*let testData: [GLMap.Float] = [

            0, 0, 0, 0, 0, 0,

            1, 0, 0, 0, 0, 0,

            0, 1, 0, 0, 0, 0
        ]*/

        //glBufferData(GLMap.ARRAY_BUFFER, MemoryLayout<Float>.size * testData.count, testData, GLMap.STATIC_DRAW)

        // CONTINUE READING: https://www.scratchapixel.com/lessons/3d-basic-rendering/computing-pixel-coordinates-of-3d-point/mathematics-computing-2d-coordinates-of-3d-points

        // glDrawElementsInstanced(GLMap.TRIANGLES, GLMap.Size(indices.count), GLMap.UNSIGNED_INT, indices, GLMap.Size(1))

        //glDrawArrays(GLMap.TRIANGLES, 0, GLMap.Size(voxels.count * baseVertices.count))

        glBindVertexArray(0)
    }
}

extension GLVoxelRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 inPos;

    layout (location = 1) in vec3 inNormal;

    layout (location = 2) in float inHighlighted;

    out vec3 Normal;

    out float Highlighted;

    void main() {
        
        gl_Position = vec4(inPos, 1);

        Normal = inNormal;

        Highlighted = inHighlighted;
    }
    """

    private static let fragmentSource = """
    #version 330 core

    in vec3 Normal;

    in float Highlighted;

    out vec4 FragColor;

    void main() {

        FragColor = vec4((dot(Normal, vec3(0, 1, 0)) + (Highlighted > 0 ? 1 : 0)) * vec3(1.0, 1.0, 1.0), 1.0);
    }
    """
}