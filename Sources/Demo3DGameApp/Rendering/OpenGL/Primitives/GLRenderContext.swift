import CustomGraphicsMath

/** CURRENTLY UNUSED */
public struct GLRenderContext {

    public var cameraTransformation: Matrix4<Float> = .zero

    public var projectionTransformation: Matrix4<Float> = .zero

    // TODO: maybe rename camera to viewTransformation and viewTransformation to viewProjectionTransformation
    public var viewTransformation: Matrix4<Float> = .zero
}