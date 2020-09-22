import GL

public struct GLVertexArray {

    public internal(set) var handle = GLMap.UInt()

    public var attributes: [ContiguousAttributes]

    mutating public func setup() {

        glGenVertexArrays(1, &handle)

        glBindVertexArray(handle)

        for var attributes in attributes {

            attributes.setup()
        }
    }

    public func bind() {

        glBindVertexArray(handle)
    }
}

extension GLVertexArray {

    public struct ContiguousAttributes {

        public var buffer: GLBuffer

        public var attributes: [GLVertexAttributeProtocol]

        mutating public func setup() {

            buffer.bind(GLMap.ARRAY_BUFFER)

            let stride = attributes.reduce(into: 0) {

                $0 += $1.dataSize
            }

            var offset: Int = 0

            for attribute in attributes {

                attribute.setup(stride: stride, offset: offset)

                offset += attribute.dataSize
            }
        }
    }
}