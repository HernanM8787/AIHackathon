import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    private let months = Calendar.current.monthSymbols
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var years: [Int] {
        Array((currentYear - 2)...(currentYear + 2))
    }
    
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let calendar = Calendar.current
        _selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue))
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Month") {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month - 1]).tag(month)
                        }
                    }
                }
                
                Section("Year") {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        var components = DateComponents()
                        components.year = selectedYear
                        components.month = selectedMonth
                        components.day = 1
                        if let newDate = calendar.date(from: components) {
                            selectedDate = newDate
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

