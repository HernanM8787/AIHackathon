import SwiftUI

enum DashboardTab: Hashable {
    case dashboard
    case stats
    case add
    case calendar
    case profile
}

struct BottomTabBar: View {
    @Binding var selected: DashboardTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", title: "Home", tab: .dashboard)
            tabButton(icon: "chart.bar.fill", title: "Stats", tab: .stats)
            
            // Center + button
            Button {
                selected = .add
            } label: {
                Circle()
                    .fill(Color(white: 0.2))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
            }
            .padding(.horizontal, 20)
            
            tabButton(icon: "calendar", title: "Calendar", tab: .calendar)
            tabButton(icon: "person.fill", title: "Profile", tab: .profile)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(white: 0.1))
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

