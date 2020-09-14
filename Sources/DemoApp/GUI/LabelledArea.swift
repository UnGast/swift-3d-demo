import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class LabelledArea: SingleChildWidget {

    private let label: String

    private let childBuilder: () -> Widget

    public init(label: String, @WidgetBuilder child childBuilder: @escaping () -> Widget) {

        self.label = label

        self.childBuilder = childBuilder
    }

    override public func buildChild() -> Widget {

        Border(all: 1, color: .White) { [unowned self] in

            Padding(all: 16) {
                
                TextConfigProvider(fontSize: 16, fontWeight: .Regular) {

                    Column {

                        Text(label)

                        childBuilder()
                    }
                }
            }
        }
    }
}