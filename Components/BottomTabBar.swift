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
        HStack(spacing: 18) {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "sparkles", title: "Assistant", tab: .assistant)
            addButton
            tabButton(icon: "calendar", title: "Calendar", tab: .calendar)
            tabButton(icon: "person.3.fill", title: "Forum", tab: .forum)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            Capsule()
                .fill(Color(white: 0.1))
                .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
        )
    }

    private func tabButton(icon: String, title: String, tab: DashboardTab) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(selected == tab ? .white : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    private var addButton: some View {
        Button {
            selected = .add
        } label: {
            Circle()
                .fill(Color.white)
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
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

