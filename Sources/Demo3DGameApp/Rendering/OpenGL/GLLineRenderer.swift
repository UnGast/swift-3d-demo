import GL

import CustomGraphicsMath

public class GLLineRenderer {

    private var shaderProgram = ShaderProgram(

        vertex: vertexSource,
        
        fragment: fragmentSource
    )

    private static let vertices: [Float] = [

        -0.5, 0, 0.5,

        0.5, 0, 0.5,

        0.5, 0, -0.5,

        -0.5, 0, 0.5,

        0.5, 0, -0.5,

        -0.5, 0, -0.5
    ]

    lazy private var vertexArray = buildVertexArray()

    private var vertexBuffer = GLBuffer()

    private var instanceBuffer = GLBuffer()

    private var lineCount: Int = 0

    private func buildVertexArray() -> GLVertexArray {

        vertexBuffer.setup()

        instanceBuffer.setup()

        return GLVertexArray(attributes: [

            GLVertexArray.ContiguousAttributes(buffer: vertexBuffer, attributes: [

                GLVertexAttribute(location: 0, dataType: Float.self, length: 3)
            ]),

            GLVertexArray.ContiguousAttributes(buffer: instanceBuffer, attributes: [

                GLVertexAttribute(location: 1, dataType: Float.self, length: 4, divisor: 1),

                GLVertexAttribute(location: 2, dataType: Float.self, length: 4, divisor: 1),

                GLVertexAttribute(location: 3, dataType: Float.self, length: 4, divisor: 1),

                GLVertexAttribute(location: 4, dataType: Float.self, length: 4, divisor: 1),
                
                GLVertexAttribute(location: 5, dataType: Float.self, length: 4, divisor: 1)
            ])
        ])
    }

    public func setup() throws {

        try shaderProgram.compile()

        vertexArray.setup()

        vertexBuffer.bind(GLMap.ARRAY_BUFFER)

        vertexBuffer.store(Self.vertices)
    }

    public func updateBuffers(lines: [DrawableLine]) {

        var instanceData: [Float] = []

        for line in lines {

            var direction = line.end - line.start

            let length = direction.magnitude

            direction = direction.normalized()

            var nonZeroComponent = 0

            for i in 0..<direction.count {

                if direction[i] != 0 {

                    nonZeroComponent = i

                    break
                }
            }

            let otherComponents = [0, 1, 2].filter { $0 != nonZeroComponent }

            //print("NON ZERO COMPONENT", direction, nonZeroComponent, otherComponents)

            var crossDirection = DVec3(1, 1, 1)

            crossDirection[nonZeroComponent] = otherComponents.reduce(into: 0, {

                $0 -= direction[$1]

            }) / direction[nonZeroComponent]

            crossDirection = crossDirection.normalized()

            print("DIRECTION", direction)

            print("CROSS DIRECTION", crossDirection.elements)

            let thirdDirection = crossDirection.cross(direction).normalized()

            print("THIRD DIRECTION", thirdDirection.elements)

            var transformation = Matrix4([

                Float(length), 0, 0, 0,

                0, 1, 0, 0,

                0, 0, Float(line.thickness), 0,

                0, 0, 0, 1

            ])

            transformation = Matrix4([

                direction.x, thirdDirection.x, crossDirection.x, 0,

                direction.y, thirdDirection.y, crossDirection.y, 0, 

                direction.z, thirdDirection.z, crossDirection.z, 0,

                0, 0, 0, 1
                
            ].map(Float.init)).matmul(transformation)

            /*transformation = Matrix4([

                0, 0, 20, 0,

                -0.7, 0.7, 0, 0,

                0.7, 0.7, 0, 0,

                0, 0, 0, 1

            ]).transposed().matmul(transformation)*/

            print("GOT TRANSFORMATION MATRIX", transformation.elements, direction.elements)

            //print("WOULD RESULT IN", transformation.matmul(FVec4(-1, 0, -1, 1)).elements)

            let transformationResultStart = DVec3(transformation.matmul(FVec4(0.5, 0, 0, 1)).elements[0..<3].map(Double.init))
            
            let transformationResultEnd = DVec3(transformation.matmul(FVec4(-0.5, 0, 0, 1)).elements[0..<3].map(Double.init))

            let transformationResultDirection = (transformationResultEnd - transformationResultStart).normalized()

            let lineTranslation: DVec3

            if transformationResultDirection.dot(direction) > 0 {

                lineTranslation = line.start - transformationResultStart

            } else {

                lineTranslation = line.start - transformationResultEnd
            }

            transformation = Matrix4([

                1, 0, 0, lineTranslation.x,

                0, 1, 0, lineTranslation.y,

                0, 0, 1, lineTranslation.z,

                0, 0, 0, 1

            ].map(Float.init)).matmul(transformation)

            // print("THE TRANSFORMATION MATIRXI OIS:", transformation.elements)

            instanceData.append(contentsOf: transformation.transposed().elements)

            instanceData.append(contentsOf: line.color.gl)
        }

        instanceBuffer.bind(GLMap.ARRAY_BUFFER)

        instanceBuffer.store(instanceData)

        lineCount = lines.count
    }

    public func render(context: GLRenderContext) {
        
        shaderProgram.use()

        vertexArray.bind()

        glUniformMatrix4fv(glGetUniformLocation(shaderProgram.id, "viewProjectionTransformation"), 1, true, context.viewTransformation.elements)
        
        glLineWidth(20.0)

        glEnable(GLMap.DEPTH_TEST)

        glDrawArraysInstanced(GLMap.TRIANGLES, 0, GLMap.Int(Self.vertices.count), GLMap.Size(lineCount))

        glBindVertexArray(0)
    }
}

extension GLLineRenderer {

    private static let vertexSource = """
    #version 330 core

    layout (location = 0) in vec3 positionIn;

    layout (location = 1) in mat4 lineTransformation;

    layout (location = 5) in vec4 colorIn;

    uniform mat4 viewProjectionTransformation;

    out VERTEX_OUT {
        
        vec4 color;

    } vs_out;

    void main() {

        gl_Position = viewProjectionTransformation * lineTransformation * vec4(positionIn, 1);

        vs_out.color = colorIn;
    }
    """

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