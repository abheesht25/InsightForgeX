//
//  ProfileView.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 04/03/24.
//

import SwiftUI
import UIKit
import MobileCoreServices
import Charts
import Network


struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var searchText = ""
    @State private var selectedURL: URL?
    @State private var showSheet = false
    @State private var importing = false
    @State private var csvContent = ""
    @State private var rows: [[String]] = []
    @State private var chartData: [ChartData] = []
    @State private var isConnected: Bool = true
    @State private var selectedCategoryColumn: Int = 0
    @State private var selectedValueColumn: Int = 1
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
    
    
    var body: some View {
        if let user = viewModel.currentUser {
            List{
                Section{
                    HStack{
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width:72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                    }
                    Text("Dashboard...")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    
                }
                Section{
                    ZStack(alignment: .leading) {
                        TextField("Search", text: $searchText)
                            .padding(.leading, 36)
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                }
                .navigationBarTitle("Search")
                
                
                
                Section("General"){
                    HStack{
                        SettingRowView(imagename: "gear",
                                       title: "Version",
                                       tincolor: Color(.systemGray))
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                }
                // Import CSV Section
                Section("Import CSV") {
                                   if isConnected {
                                       Button {
                                           importing = true
                                       } label: {
                                           SettingRowView(imagename: "doc.text", title: "Import CSV", tincolor: .blue)
                                       }
                                       .fileImporter(
                                           isPresented: $importing,
                                           allowedContentTypes: [.commaSeparatedText],
                                           allowsMultipleSelection: false
                                       ) { result in
                                           handleFileImport(result: result)
                                       }
                                   } else {
                                       Text("No network connection available")
                                           .foregroundColor(.red)
                                   }
                               }

                               if !rows.isEmpty {
                                   ColumnSelectionView(rows: $rows, selectedCategoryColumn: $selectedCategoryColumn, selectedValueColumn: $selectedValueColumn, chartData: $chartData)
                               }

                               // Display the pie chart
                               if !chartData.isEmpty {
                                   Section(header: Text("Pie Chart")) {
                                       PieChartView(data: chartData)
                                           .frame(height: 300)
                                   }
                               } else {
                                   Text("No data available to display")
                                       .foregroundColor(.gray)
                               }


                            
                //Account management section
                Section("Account"){
                    Button
                    {
                        viewModel.signout()
                    }
                label: {
                    SettingRowView(imagename: "arrow.left.circle.fill", title: "SignOut", tincolor: .red)
                }
                    
                    Button
                    {
                        print("Delete Account..")
                    }
                label: {
                    SettingRowView(imagename: "xmark.circle.fill", title: "Delete Account", tincolor: .red)
                }
                }
                
                
                
            }
        }
    }
    private func handleFileImport(result: Result<[URL], Error>) {
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    do {
                        let content = try String(contentsOf: url)
                        print("CSV Content: \(content)")
                        self.csvContent = content
                        self.rows = parseCSV(content: content)
                        printCSVContent(rows: self.rows)
                        print("Parsed rows: \(self.rows)")
                    } catch {
                        print("Error reading CSV file: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error importing file: \(error.localizedDescription)")
            }
        }
    
    private func parseCSV(content: String) -> [[String]] {
            var rows: [[String]] = []
            let lines = content.components(separatedBy: "\n")
            
            for line in lines {
                let columns = line.components(separatedBy: ",")
                rows.append(columns)
            }
            
            return rows
        }
    
        
        private func printCSVContent(rows: [[String]]) {
            for row in rows {
                print(row.joined(separator: ", "))
                print ("\n")
            }
        }
    
    }
// MARK: - AnalyticsDashboardView

struct AnalyticsDashboardView: View {
    @Binding var rows: [[String]]
    @Binding var selectedCategoryColumn: Int
    @Binding var selectedValueColumn: Int
    @Binding var chartData: [ChartData]

    var body: some View {
        VStack {
            NavigationLink(destination: ColumnSelectionView(rows: $rows, selectedCategoryColumn: $selectedCategoryColumn, selectedValueColumn: $selectedValueColumn, chartData: $chartData)) {
                Text("Column Selection")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            NavigationLink(destination: DataSummaryView(rows: rows, selectedValueColumn: selectedValueColumn)) {
                Text("Data Summary")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            NavigationLink(destination: CorrelationView(rows: rows, selectedColumn1: selectedCategoryColumn, selectedColumn2: selectedValueColumn)) {
                Text("Correlation Analysis")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if !chartData.isEmpty {
                PieChartView(data: chartData)
                    .padding()
            }
        }
        .navigationTitle("Data Analytics Platform")
    }
}


// MARK: - PieChartView

struct PieChartView: View {
    let data: [ChartData]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(data) { item in
                    PieSlice(startAngle: .degrees(item.startAngle), endAngle: .degrees(item.endAngle))
                        .fill(Color.random)

                    // Only show label if segment is large enough
                    if (item.endAngle - item.startAngle) > 10 {
                        Text(item.displayCategory)
                            .position(labelPosition(for: item, in: geometry.size))
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
    }

    private func labelPosition(for item: ChartData, in size: CGSize) -> CGPoint {
        let angle = (item.startAngle + item.endAngle) / 2
        let radius = size.width / 2.5
        let x = size.width / 2 + radius * cos(angle * .pi / 180)
        let y = size.height / 2 + radius * sin(angle * .pi / 180)
        return CGPoint(x: x, y: y)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// MARK: - ColumnSelectionView

struct ColumnSelectionView: View {
    @Binding var rows: [[String]]
    @Binding var selectedCategoryColumn: Int
    @Binding var selectedValueColumn: Int
    @Binding var chartData: [ChartData]

    var body: some View {
        VStack {
            if rows.isEmpty {
                Text("No CSV data available")
            } else {
                Picker("Select Category Column", selection: $selectedCategoryColumn) {
                    ForEach(0..<rows[0].count, id: \.self) { index in
                        Text(rows[0][index].prefix(10) + (rows[0][index].count > 10 ? "..." : ""))
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Select Value Column", selection: $selectedValueColumn) {
                    ForEach(0..<rows[0].count, id: \.self) { index in
                        Text(rows[0][index].prefix(10) + (rows[0][index].count > 10 ? "..." : ""))
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Button("Generate Chart") {
                    generateChartData()
                }
            }
        }
    }

    private func generateChartData() {
        var data: [ChartData] = []
        for row in rows.dropFirst() {
            if row.count > max(selectedCategoryColumn, selectedValueColumn),
               let value = Double(row[selectedValueColumn].trimmingCharacters(in: .whitespacesAndNewlines)) {
                let category = row[selectedCategoryColumn].trimmingCharacters(in: .whitespacesAndNewlines)
                data.append(ChartData(category: category, value: value))
            }
        }
        chartData = data
        calculateAngles()
    }

    private func calculateAngles() {
        let total = chartData.reduce(0) { $0 + $1.value }
        var startAngle: Double = 0

        for i in 0..<chartData.count {
            let endAngle = startAngle + (chartData[i].value / total) * 360
            chartData[i].startAngle = startAngle
            chartData[i].endAngle = endAngle
            startAngle = endAngle
        }
        print("Calculated angles: \(chartData)")
    }
}

// MARK: - DataSummaryView

struct DataSummaryView: View {
    let rows: [[String]]
    let selectedValueColumn: Int

    var body: some View {
        VStack {
            Text("Data Summary")
                .font(.headline)
            List {
                Text("Average value of the data set: \(calculateMean())")
                Text("Middle value of the data set: \(calculateMedian())")
                Text("Most frequent value: \(calculateMode())")
                Text("Standard Deviation: \(calculateStandardDeviation())")
            }
        }
    }

    private func calculateMean() -> Double {
        let values = rows.dropFirst().compactMap { Double($0[selectedValueColumn]) }
        return values.reduce(0, +) / Double(values.count)
    }

    private func calculateMedian() -> Double {
        let values = rows.dropFirst().compactMap { Double($0[selectedValueColumn]) }.sorted()
        let middle = values.count / 2
        if values.count % 2 == 0 {
            return (values[middle - 1] + values[middle]) / 2
        } else {
            return values[middle]
        }
    }

    private func calculateMode() -> Double {
        let values = rows.dropFirst().compactMap { Double($0[selectedValueColumn]) }
        let frequency = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
        return frequency.max(by: { $0.value < $1.value })?.key ?? 0.0
    }

    private func calculateStandardDeviation() -> Double {
        let values = rows.dropFirst().compactMap { Double($0[selectedValueColumn]) }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(values.count)
        return sqrt(variance)
    }
}

// MARK: - CorrelationView

struct CorrelationView: View {
    var rows: [[String]]
    var selectedColumn1: Int
    var selectedColumn2: Int

    var body: some View {
        if rows.count > 1 {
            let values1 = rows.dropFirst().compactMap { Double($0[selectedColumn1].trimmingCharacters(in: .whitespacesAndNewlines)) }
            let values2 = rows.dropFirst().compactMap { Double($0[selectedColumn2].trimmingCharacters(in: .whitespacesAndNewlines)) }
            if values1.count == values2.count {
                let correlation = calculateCorrelation(values1: values1, values2: values2)
                Text("Correlation: \(correlation)")
            } else {
                Text("Columns have unequal number of values")
            }
        } else {
            Text("No data available")
        }
    }

    private func calculateCorrelation(values1: [Double], values2: [Double]) -> Double {
        let mean1 = values1.reduce(0, +) / Double(values1.count)
        let mean2 = values2.reduce(0, +) / Double(values2.count)
        let numerator = zip(values1, values2).reduce(0) { $0 + ($1.0 - mean1) * ($1.1 - mean2) }
        let denominator = sqrt(values1.reduce(0) { $0 + pow($1 - mean1, 2) }) * sqrt(values2.reduce(0) { $0 + pow($1 - mean2, 2) })
        return numerator / denominator
    }
}

// MARK: - ChartData

struct ChartData: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
    var startAngle: Double = 0.0
    var endAngle: Double = 0.0

    var displayCategory: String {
        return category.count > 10 ? String(category.prefix(10)) + "..." : category
    }

    var displayValue: String {
        let valueString = String(format: "%.2f", value)
        return valueString.count > 10 ? String(valueString.prefix(10)) + "..." : valueString
    }
}

    struct ProfileView_preview: PreviewProvider{
        static var previews: some View{
            let authViewModel = AuthViewModel()
            
            // Provide AuthViewModel as an environment object
            return ProfileView()
                .environmentObject(authViewModel)
        }
    }
