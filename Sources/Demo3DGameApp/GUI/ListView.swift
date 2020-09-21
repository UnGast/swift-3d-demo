import WidgetGUI
import CustomGraphicsMath

public class ListView<Item>: Widget {

    private var items: [Item]

    private let childBuilder: (_ item: Item) -> Widget

    public init(items: [Item], @WidgetBuilder childBuilder: @escaping (_ item: Item) -> Widget) {

        self.items = items

        self.childBuilder = childBuilder
    }

    // TODO: maybe handle children by a visit function or something like that and let subclasses handle more of the children aspects
    private func buildChildren() -> [Widget] {

        items.map(childBuilder)
    }

    override public func build() {

        children = buildChildren()
    }
    
    public func updateItems(_ items: [Item]) {

        self.items = items

        // TODO: maybe have a function like remount children or so / or simply mountChildren()
        // which does not differentiate in name between first and subsequent mounts
        self.replaceChildren(with: buildChildren())
    }

    override public func getBoxConfig() -> BoxConfig {

        let childrenConfigs = children.map(\.boxConfig)

        var resultConfig = BoxConfig(preferredSize: DSize2(100, 100))

        for childConfig in childrenConfigs {

            if childConfig.preferredSize.width > resultConfig.preferredSize.width {

                resultConfig.preferredSize.width = childConfig.preferredSize.width
            }

            resultConfig.preferredSize.height += childConfig.preferredSize.height

            if childConfig.minSize.width > resultConfig.minSize.width {

                resultConfig.minSize.width = childConfig.minSize.width
            }
            
            resultConfig.minSize.height += childConfig.minSize.height

            if childConfig.maxSize.width > resultConfig.maxSize.width {

                resultConfig.maxSize.width = childConfig.maxSize.width
            }

            resultConfig.maxSize.height += childConfig.maxSize.height
        }

        return resultConfig
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {

        var size = DSize2.zero

        for child in children {
            
            child.layout(constraints: BoxConstraints(minSize: .zero, maxSize: constraints.maxSize))

            child.bounds.min.y = size.height

            if child.bounds.size.width > size.width {

                size.width = child.bounds.size.width
            }

            size.height += child.bounds.size.height
        }

        return constraints.constrain(size)
    }
}