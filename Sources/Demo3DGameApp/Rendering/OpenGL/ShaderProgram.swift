import GL

open class ShaderProgram {
    
    public let vertexSource: String
    
    public let geometrySource: String?
    
    public let fragmentSource: String

    public var id: GLMap.UInt = 0

    public init(vertex vertexSource: String, geometry geometrySource: String? = nil, fragment fragmentSource: String) {

        self.vertexSource = vertexSource
        
        self.geometrySource = geometrySource

        self.fragmentSource = fragmentSource
    }

    deinit {

        glDeleteProgram(id)
    }

    /// compiles and links the shaders
    open func compile() throws {

        // TODO: maybe pass in the Shaders directly instead of the source
        var vertexShader = Shader(type: .Vertex, source: vertexSource)

        try vertexShader.compile()


        /*var geometryShader: GLMap.UInt? = nil

        if let geometrySource = geometrySource {
            
            geometryShader = glCreateShader(GLMap.GEOMETRY_SHADER)

            withUnsafePointer(to: geometrySource) { glShaderSource(geometryShader!, 1, $0, nil) }

            glCompileShader(geometryShader)


        }*/


        var fragmentShader = Shader(type: .Fragment, source: fragmentSource)

        try fragmentShader.compile()


        self.id = glCreateProgram()

        glAttachShader(self.id, vertexShader.handle)

        glAttachShader(self.id, fragmentShader.handle)

        glLinkProgram(self.id)

        let success = UnsafeMutablePointer<GLMap.Int>.allocate(capacity: 1)

        let info = UnsafeMutablePointer<GLMap.Char>.allocate(capacity: 512)

        glGetProgramiv(self.id, GLMap.LINK_STATUS, success)

        if (success.pointee == 0) {

            glGetProgramInfoLog(self.id, 512, nil, info)

            throw LinkingError(description: String(cString: info))
        }

        glDeleteShader(vertexShader.handle)

        glDeleteShader(fragmentShader.handle)
    }

    open func use() {
        
        if id == 0 {

            fatalError("Called use on shader before it was compiled.")
        }

        glUseProgram(id)
    }
}

extension ShaderProgram {

    public struct LinkingError: Error {

        public var description: String
    }
}

public struct Shader {

    public var type: ShaderType

    public var source: String

    public var handle: GLMap.UInt = 0

    mutating public func compile() throws {

        let success = UnsafeMutablePointer<GLMap.Int>.allocate(capacity: 1)

        let info = UnsafeMutablePointer<GLMap.Char>.allocate(capacity: 512)

        handle = glCreateShader(type.glEnum)

        withUnsafePointer(to: source) { ptr in GL.glShaderSource(handle, 1, ptr, nil) }

        glCompileShader(handle)

        glGetShaderiv(handle, GLMap.COMPILE_STATUS, success)

        if (success.pointee == 0) {

            glGetShaderInfoLog(handle, 512, nil, info)

            throw CompilationError(description: String(cString: info))
        }
    }
}

extension Shader {

    public enum ShaderType {

        case Vertex, Geometry, Fragment

        public var glEnum: Int32 {

            switch self {

            case .Vertex:

                return GLMap.VERTEX_SHADER

            case .Geometry:

                return GLMap.GEOMETRY_SHADER

            case .Fragment:

                return GLMap.FRAGMENT_SHADER
            }
        }
    }

    public struct CompilationError: Error {

        public var description: String
    }
}