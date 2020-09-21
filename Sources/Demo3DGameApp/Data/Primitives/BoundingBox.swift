import CustomGraphicsMath

public struct BoundingBox<Vector: Vector3Protocol> {

    public var min: Vector

    public var max: Vector
}

public typealias DBoundingBox = BoundingBox<DVec3>