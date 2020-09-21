import CustomGraphicsMath

public struct Vertex {

    public var position: DVec3

    public var normal: DVec3

    public init(_ position: DVec3, _ normal: DVec3) {

        self.position = position

        self.normal = normal
    }
}