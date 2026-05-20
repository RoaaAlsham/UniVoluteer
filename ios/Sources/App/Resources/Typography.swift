import SwiftUI

struct LargeTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.largeTitle, design: .default, weight: .bold))
    }
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.title2, design: .default, weight: .semibold))
    }
}

struct HeadlineStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.headline, design: .default, weight: .medium))
    }
}

struct BodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.body, design: .default, weight: .regular))
    }
}

struct CaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(.caption, design: .default, weight: .regular))
            .foregroundStyle(.secondary)
    }
}

extension View {
    func largeTitleStyle() -> some View { modifier(LargeTitleStyle()) }
    func titleStyle() -> some View { modifier(TitleStyle()) }
    func headlineStyle() -> some View { modifier(HeadlineStyle()) }
    func bodyStyle() -> some View { modifier(BodyStyle()) }
    func captionStyle() -> some View { modifier(CaptionStyle()) }
}
