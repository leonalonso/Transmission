//
// Copyright (c) Nathan Tannar
//

#if os(iOS)

import SwiftUI

class ViewControllerReader: UIView {

    let onDidMoveToWindow: (UIViewController?) -> Void

    init(onDidMoveToWindow: @escaping (UIViewController?) -> Void) {
        self.onDidMoveToWindow = onDidMoveToWindow
        super.init(frame: .zero)
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onDidMoveToWindow(viewController)
    }
}

class TransitionSourceView<Content: View>: ViewControllerReader {

    var hostingView: HostingView<Content>?
    
    // NEW: Static property to force a fixed width
    static var forcedWidth: CGFloat? = nil

    init(
        onDidMoveToWindow: @escaping (UIViewController?) -> Void,
        content: Content
    ) {
        super.init(onDidMoveToWindow: onDidMoveToWindow)
        if Content.self != EmptyView.self {
            isHidden = false
            let hostingView = HostingView(content: content)
            addSubview(hostingView)
            hostingView.disablesSafeArea = true
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            self.hostingView = hostingView
        }
        clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Use forced width if set, falls back to normal sizing
        if let forcedWidth = Self.forcedWidth {
            var fixedSize = hostingView?.sizeThatFits(CGSize(width: forcedWidth, height: size.height)) ?? super.sizeThatFits(size)
            fixedSize.width = forcedWidth
            return fixedSize
        }
        return hostingView?.sizeThatFits(size) ?? super.sizeThatFits(size)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let forcedWidth = Self.forcedWidth {
            // Center horizontally if the bounds are wider than forcedWidth
            let h = bounds.height
            let y: CGFloat = 0
            let x: CGFloat = (bounds.width - forcedWidth) / 2
            hostingView?.frame = CGRect(x: x, y: y, width: forcedWidth, height: h)
        } else {
            hostingView?.frame = bounds
        }
    }
}

#endif
