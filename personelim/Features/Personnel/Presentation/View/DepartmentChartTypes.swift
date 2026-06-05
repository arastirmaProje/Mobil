import SwiftUI

enum MetricTab: String, CaseIterable {
    case skor = "Skor"
    case mesai = "Mesai (%)"
    case gorev = "Görev"
    case verimlilik = "Verimlilik"
    case tamamlanma = "Tamamlanma"
    case zorluk = "Zorluk Başarısı"
    case calisan = "Çalışan Sayısı"
    case mesaiKullanim = "Mesai Kullanımı"

    var icon: String {
        switch self {
        case .skor: return "star.circle.fill"
        case .mesai: return "clock.badge.checkmark.fill"
        case .gorev: return "doc.text.fill"
        case .verimlilik: return "bolt.shield.fill"
        case .tamamlanma: return "checkmark.circle.fill"
        case .zorluk: return "target"
        case .calisan: return "person.3.fill"
        case .mesaiKullanim: return "timer"
        }
    }

    var color: Color {
        switch self {
        case .skor: return .blue
        case .mesai: return .orange
        case .gorev: return .green
        case .verimlilik: return .purple
        case .tamamlanma: return .mint
        case .zorluk: return .red
        case .calisan: return .indigo
        case .mesaiKullanim: return .teal
        }
    }
}

enum ChartTypeOption: String, CaseIterable {
    case bar = "Çubuk"
    case line = "Çizgi"
    case horizontalBar = "Yatay"
    case pie = "Pasta"
    case donut = "Donut"
    case area = "Alan"

    var icon: String {
        switch self {
        case .bar: return "chart.bar.fill"
        case .line: return "chart.line.uptrend.xyaxis"
        case .horizontalBar: return "align.horizontal.left.fill"
        case .pie: return "chart.pie.fill"
        case .donut: return "circle.dashed"
        case .area: return "chart.xyaxis.line"
        }
    }
}
