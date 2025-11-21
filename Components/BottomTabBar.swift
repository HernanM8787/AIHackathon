import SwiftUI

enum DashboardTab: Hashable {
    case assistant
    case chat
    case home
    case calendar
    case profile
}

struct BottomTabBar: View {
    @Binding var selected: DashboardTab

    var body: some View {
        HStack(spacing: 18) {
            tabButton(icon: "sparkles", title: "Assistant", tab: .assistant)
            tabButton(icon: "bubble.left.and.bubble.right.fill", title: "Chat", tab: .chat)
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "calendar", title: "Calendar", tab: .calendar)
            tabButton(icon: "person.crop.circle.fill", title: "Profile", tab: .profile)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 22)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
    }

    private func tabButton(icon: String, title: String, tab: DashboardTab) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(selected == tab ? Color.accentColor : Color.primary.opacity(0.6))
            .padding(.horizontal, 4)
        }
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(DashboardTab.home) { binding in
        BottomTabBar(selected: binding)
            .padding()
            .background(Color.black.opacity(0.1))
    }
}

struct StatefulPreviewWrapper<Value: Hashable, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
#endif

