import CustomGraphicsMath

public struct Camera {

    public var position: DVec3

    public var fov: Double

    public var pitch: Double = 0

    public var yaw: Double = 0

    public var forward: DVec3 {

        DVec3(x: tan(yaw), y: tan(pitch), z: 1).normalized()
    }

    public var right: DVec3 {

        forward.cross(DVec3(0, 1, 0)).normalized()
    }

    public var up: DVec3 {

        forward.cross(right).normalized()
    }
}