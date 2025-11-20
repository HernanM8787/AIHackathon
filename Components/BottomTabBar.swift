import SwiftUI

enum DashboardTab: Hashable {
    case matcher
    case dashboard
    case assistant
}

struct BottomTabBar: View {
    @Binding var selected: DashboardTab

    var body: some View {
        HStack {
            tabButton(icon: "person.3.fill", title: "Matcher", tab: .matcher)
            tabButton(icon: "house.fill", title: "Home", tab: .dashboard)
            tabButton(icon: "sparkles", title: "Assistant", tab: .assistant)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal)
        .shadow(radius: 4, y: 2)
    }

    private func tabButton(icon: String, title: String, tab: DashboardTab) -> some View {
        Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
                    .font(.footnote)
            }
            .foregroundStyle(selected == tab ? Color.accentColor : Color.primary.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(DashboardTab.dashboard) { binding in
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

