import CustomGraphicsMath

public struct Camera {

    public var position: DVec3

    public var fov: Double

    public var pitch: Double = 0

    public var yaw: Double = 0

    public var forward: DVec3 {

        DVec3(x: cos(yaw) * cos(pitch), y: sin(pitch), z: sin(yaw) * cos(pitch)).normalized()
    }

    public var right: DVec3 {

        DVec3(0, 1, 0).cross(forward).normalized()
    }

    public var up: DVec3 {

        forward.cross(right).normalized()
    }
}