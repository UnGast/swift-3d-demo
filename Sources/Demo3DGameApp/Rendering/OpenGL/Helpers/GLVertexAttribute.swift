import GL

public protocol GLVertexAttributeProtocol {

    var dataSize: Int { get }

    func setup(stride: Int, offset: Int)        
}

public struct GLVertexAttribute<DataType>: GLVertexAttributeProtocol {

    public var location: UInt

    public var dataType: DataType.Type

    private var glEnumDataType: GLMap.Int {

        switch dataType.self {

        case is Float.Type:

            return GLMap.FLOAT

        default:

            fatalError("Unsupported data type in vertex attribute: \(DataType.self)")
        }
    }

    public var length: Int

    public var dataSize: Int {

        MemoryLayout<DataType>.size * length
    }

    public func setup(stride: Int, offset: Int) {

        glVertexAttribPointer(
            
            index: GLMap.UInt(location),
            
            size: GLMap.Int(length),
            
            type: glEnumDataType,
            
            normalized: false,
            
            stride: GLMap.Size(stride),
            
            pointer: UnsafeRawPointer(bitPattern: offset))

        glEnableVertexAttribArray(GLMap.UInt(location))
    } 
}