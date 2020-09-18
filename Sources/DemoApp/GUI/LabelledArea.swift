import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class LabelledArea: SingleChildWidget {

    private let label: String

    private let borderColor: Color

    private let borderThickness: Double

    private let borderRadius: Double

    private let labelSpacing: Double = 10 // spacing the label has to left and right from border

    private let contentChildBuilder: () -> Widget

    @Reference private var labelWidget: Text

    @Reference private var contentWidget: Widget

    // TODO: for the border config this should accept inputs of BorderConfig of Border Widget ( maybe )
    public init(

        label: String,

        borderColor: Color = .Blue,
        
        borderThickness: Double = 1,
        
        borderRadius: Double = 15,
        
        @WidgetBuilder child contentChildBuilder: @escaping () -> Widget) {

            self.label = label

            self.borderColor = borderColor

            self.borderThickness = borderThickness

            self.borderRadius = borderRadius

            self.contentChildBuilder = contentChildBuilder
    }

    override public func build() {

        labelWidget = Text(label, fontSize: 16, fontWeight: .Regular)

        contentWidget = Padding(all: 16) {
            
            contentChildBuilder()
        }

        children = [

            labelWidget,

            contentWidget
        ]
    }


    override public func getBoxConfig() -> BoxConfig {

        let labelConfig = labelWidget.boxConfig

        let contentConfig = contentWidget.boxConfig

        return BoxConfig(

            preferredSize: DSize2(

                contentConfig.preferredSize.width,
                
                contentConfig.preferredSize.height + labelConfig.preferredSize.height),
            
            minSize: DSize2(

                contentConfig.minSize.width,
                
                contentConfig.minSize.height + labelConfig.minSize.height),

            maxSize: DSize2(

                contentConfig.maxSize.width,
                
                contentConfig.maxSize.height + labelConfig.maxSize.height)
        )
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        labelWidget.layout(constraints: BoxConstraints(minSize: .zero, maxSize: .infinity))

        labelWidget.bounds.min.x = 40 // TODO: maybe make this a parameter, maybe allow percentage of width

        let restConstraints = BoxConstraints(

            minSize: max(constraints.minSize - DSize2(0, labelWidget.height), .zero),

            maxSize: constraints.maxSize - DSize2(0, labelWidget.height)
        )

        contentWidget.layout(constraints: restConstraints)

        contentWidget.bounds.min.y = labelWidget.bounds.size.height

        return constraints.constrain(contentWidget.bounds.size)
    }

    override public func renderContent() -> RenderObject? {

        return RenderObject.Container {

            RenderObject.RenderStyle(strokeWidth: borderThickness, strokeColor: FixedRenderValue(borderColor)) {
                
                PathRenderObject(Path([

                    .Start(globalPosition + DVec2(labelWidget.x - labelSpacing, labelWidget.height / 2)),

                    .Line(globalPosition + DVec2(borderRadius - borderThickness, labelWidget.height / 2)),

                    .Arc(

                        center: globalPosition + DVec2(-borderThickness + borderRadius, labelWidget.height / 2 + borderRadius),

                        radius: borderRadius,

                        startAngle: -Double.pi / 2,

                        endAngle: -Double.pi,

                        direction: .Counterclockwise
                    ),

                    .Line(globalPosition + DVec2(-borderThickness, height + borderThickness - borderRadius)),

                    .Arc(

                        center: globalPosition + DVec2(-borderThickness + borderRadius, height + borderThickness - borderRadius),
                        
                        radius: borderRadius,
                        
                        startAngle: -Double.pi,
                        
                        endAngle: Double.pi / 2,
                        
                        direction: .Counterclockwise),

                    .Line(globalPosition + DVec2(width + borderThickness - borderRadius, height + borderThickness)),

                    .Arc(

                        center: globalPosition + DVec2(width + borderThickness - borderRadius, height + borderThickness - borderRadius),

                        radius: borderRadius,

                        startAngle: Double.pi / 2,

                        endAngle: 0,

                        direction: .Counterclockwise
                    ),

                    .Line(globalPosition + DVec2(width + borderThickness, labelWidget.height / 2 + borderRadius)),

                    .Arc(

                        center: globalPosition + DVec2(width + borderThickness - borderRadius, labelWidget.height / 2 + borderRadius),

                        radius: borderRadius,

                        startAngle: 0,

                        endAngle: -Double.pi / 2,

                        direction: .Counterclockwise
                    ),

                    .Line(globalPosition + DVec2(labelWidget.x + labelWidget.width + labelSpacing, labelWidget.height / 2))
                ]))
            }

            labelWidget.render()            

            contentWidget.render()
        }
    }
}