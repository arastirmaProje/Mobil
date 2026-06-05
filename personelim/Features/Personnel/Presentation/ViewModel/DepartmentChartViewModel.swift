import Foundation
import SwiftUI

@MainActor
final class DepartmentChartViewModel: ObservableObject {

    // MARK: - UI STATE

    @Published var selectedMetric: MetricTab = .skor

    @Published var chartStartDate: Date = Date().addingTimeInterval(-604800)
    @Published var chartEndDate: Date = Date()

    @Published var departmentLimit: Int = 5
    @Published var showingCustomDatePicker: Bool = false

    @Published var selectedDepartmentName: String? = nil

    // MARK: - DATA

    @Published var businessGraph: BusinessGrafikVerisiDTO?

    // MARK: - ACTIONS

    func setMetric(_ metric: MetricTab) {
        selectedMetric = metric
        selectedDepartmentName = nil
    }

    func setCustomDate(start: Date, end: Date) {
        chartStartDate = start
        chartEndDate = end
    }

    func selectDepartment(_ name: String?) {
        selectedDepartmentName = name
    }

    func setBusinessGraph(_ data: BusinessGrafikVerisiDTO) {
        businessGraph = data
    }

    // MARK: - SAFE

    private func safeDouble(_ value: Double?) -> Double {
        guard let value, value.isFinite else { return 0 }
        return value
    }

    private func safeInt(_ value: Int?) -> Double {
        guard let value else { return 0 }
        return Double(value)
    }

    // MARK: - VALUE RESOLVER

    private func valueFor(dept: String) -> Double {
        guard let data = businessGraph else { return 0 }

        switch selectedMetric {

        case .skor:
            let value = data.departmanPuanKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .skor

            return safeDouble(value)

        case .mesai:
            let value = data.mesaiKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .mesaiKullanimOrani

            return safeDouble(value)

        case .gorev:
            let value = data.gorevDagilimiKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .toplam

            return safeInt(value)

        case .verimlilik:
            let value = data.verimlilikKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .verimlilik

            return safeDouble(value)

        case .tamamlanma:
            let value = data.tamamlanmaOraniKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .oran

            return safeDouble(value)

        case .zorluk:
            let value = data.zorlukBasariKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .zorlukBasari

            return safeDouble(value)

        case .calisan:
            let value = data.calisanSayisiDagilimi
                .first(where: { $0.departmanAdi == dept })?
                .calisanSayisi

            return safeInt(value)

        case .mesaiKullanim:
            let value = data.mesaiKullanimKarsilastirma
                .first(where: { $0.departmanAdi == dept })?
                .mesaiKullanimi

            return safeDouble(value)
        }
    }

    // MARK: - DEPARTMENTS

    private var allDepartments: [String] {
        guard let data = businessGraph else { return [] }

        var set = Set<String>()

        data.departmanPuanKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.mesaiKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.gorevDagilimiKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.verimlilikKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.tamamlanmaOraniKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.zorlukBasariKarsilastirma.forEach { set.insert($0.departmanAdi) }
        data.calisanSayisiDagilimi.forEach { set.insert($0.departmanAdi) }
        data.mesaiKullanimKarsilastirma.forEach { set.insert($0.departmanAdi) }

        return Array(set).sorted()
    }

    var chartData: [DepartmentMetricBundle] {
        allDepartments.map { dept in
            DepartmentMetricBundle(
                name: dept,
                value: valueFor(dept: dept)
            )
        }
    }

    var limitedChartData: [DepartmentMetricBundle] {
        let sorted = chartData.sorted { $0.value > $1.value }
        return Array(sorted.prefix(departmentLimit))
    }

    var averageValue: Double {
        let values = limitedChartData.map(\.value)
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    var maxValue: Double {
        limitedChartData.map(\.value).max() ?? 0
    }

    var selectedItem: DepartmentMetricBundle? {
        guard let selectedDepartmentName else { return nil }
        return chartData.first { $0.name == selectedDepartmentName }
    }

    var topItem: DepartmentMetricBundle? {
        chartData.max { $0.value < $1.value }
    }

    var bottomItem: DepartmentMetricBundle? {
        chartData.min { $0.value < $1.value }
    }

    var metricSuffix: String {
        switch selectedMetric {
        case .mesai, .tamamlanma, .verimlilik, .zorluk, .mesaiKullanim:
            return "%"
        case .gorev, .calisan, .skor:
            return ""
        }
    }

    var resolvedChartType: ChartTypeOption {
        switch selectedMetric {
        case .skor:
            return .bar
        case .mesai:
            return .pie
        case .gorev:
            return .horizontalBar
        case .verimlilik:
            return .line
        case .tamamlanma:
            return .area
        case .zorluk:
            return .bar
        case .calisan:
            return .donut
        case .mesaiKullanim:
            return .bar
        }
    }

    func formattedValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))\(metricSuffix)"
        } else {
            return "\(String(format: "%.1f", value))\(metricSuffix)"
        }
    }
}
