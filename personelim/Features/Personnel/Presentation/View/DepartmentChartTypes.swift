import SwiftUI

enum MetricTab: CaseIterable {

    case skor
    case mesai
    case gorev
    case verimlilik
    case tamamlanma
    case zorluk
    case calisan
    case mesaiKullanim

    var title: String {
        switch self {
        case .skor:
            return ConstantStrings.metricScore

        case .mesai:
            return ConstantStrings.metricOvertime

        case .gorev:
            return ConstantStrings.metricTask

        case .verimlilik:
            return ConstantStrings.metricProductivity

        case .tamamlanma:
            return ConstantStrings.metricCompletion

        case .zorluk:
            return ConstantStrings.metricDifficultySuccess

        case .calisan:
            return ConstantStrings.metricEmployeeCount

        case .mesaiKullanim:
            return ConstantStrings.metricOvertimeUsage
        }
    }

    var icon: String {
        switch self {
        case .skor:
            return "star.circle.fill"

        case .mesai:
            return "clock.badge.checkmark.fill"

        case .gorev:
            return "doc.text.fill"

        case .verimlilik:
            return "bolt.shield.fill"

        case .tamamlanma:
            return "checkmark.circle.fill"

        case .zorluk:
            return "target"

        case .calisan:
            return "person.3.fill"

        case .mesaiKullanim:
            return "timer"
        }
    }

    var color: Color {
        switch self {
        case .skor:
            return .blue

        case .mesai:
            return .orange

        case .gorev:
            return .green

        case .verimlilik:
            return .purple

        case .tamamlanma:
            return .mint

        case .zorluk:
            return .red

        case .calisan:
            return .indigo

        case .mesaiKullanim:
            return .teal
        }
    }
}

enum ChartTypeOption: CaseIterable {

    case bar
    case line
    case horizontalBar
    case pie
    case donut
    case area

    var title: String {
        switch self {
        case .bar:
            return ConstantStrings.chartTypeBar

        case .line:
            return ConstantStrings.chartTypeLine

        case .horizontalBar:
            return ConstantStrings.chartTypeHorizontalBar

        case .pie:
            return ConstantStrings.chartTypePie

        case .donut:
            return ConstantStrings.chartTypeDonut

        case .area:
            return ConstantStrings.chartTypeArea
        }
    }

    var icon: String {
        switch self {
        case .bar:
            return "chart.bar.fill"

        case .line:
            return "chart.line.uptrend.xyaxis"

        case .horizontalBar:
            return "align.horizontal.left.fill"

        case .pie:
            return "chart.pie.fill"

        case .donut:
            return "circle.dashed"

        case .area:
            return "chart.xyaxis.line"
        }
    }
}
