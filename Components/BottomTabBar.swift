import SwiftUI

enum DashboardTab: Hashable {
    case home
    case assistant
    case add
    case calendar
    case forum
}

struct BottomTabBar: View {
    @Binding var selected: DashboardTab

    var body: some View {
        HStack(spacing: 12) {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "sparkles", title: "Assistant", tab: .assistant)
            addButton
            tabButton(icon: "calendar", title: "Calendar", tab: .calendar)
            tabButton(icon: "person.3.fill", title: "Forum", tab: .forum)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .background(
            Capsule()
                .fill(Theme.surface)
                .overlay(
                    Capsule()
                        .stroke(Theme.outline, lineWidth: 1)
                )
                .shadow(color: Theme.accent.opacity(0.25), radius: 18, y: 10)
        )
    }

    private func tabButton(icon: String, title: String, tab: DashboardTab) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 19))
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(selected == tab ? Theme.accent : Theme.subtitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(selected == tab ? Theme.accent.opacity(0.15) : .clear)
            )
        }
    }

    private var addButton: some View {
        Button {
            selected = .add
        } label: {
            Circle()
                .fill(Theme.accentGradient)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: Theme.accent.opacity(0.4), radius: 8, y: 4)
        }
        .padding(.horizontal, 4)
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

