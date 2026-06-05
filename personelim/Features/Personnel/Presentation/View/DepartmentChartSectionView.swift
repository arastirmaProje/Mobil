import SwiftUI
import Charts

struct DepartmentChartSectionView: View {

    @ObservedObject var viewModel: DepartmentChartViewModel
    let reloadChartData: () async -> Void

    @State private var animateIn = false

    private let radius: CGFloat = 22

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            header
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : -8)

            metricPicker
                .opacity(animateIn ? 1 : 0)

            summaryCards
                .opacity(animateIn ? 1 : 0)

            divider

            customDateButton
                .opacity(animateIn ? 1 : 0)

            limitPicker
                .opacity(animateIn ? 1 : 0)

            chartContainer
                .opacity(animateIn ? 1 : 0)
                .scaleEffect(animateIn ? 1 : 0.98)

            legend
                .opacity(animateIn ? 1 : 0)

            selectedHint
                .opacity(animateIn ? 1 : 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
    }

    // MARK: - HEADER

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Departman Analitiği")
                    .font(.title3.weight(.semibold))

                HStack(spacing: 6) {
                    Image(systemName: viewModel.selectedMetric.icon)
                        .foregroundStyle(viewModel.selectedMetric.color)

                    Text(viewModel.selectedMetric.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            chartTypeBadge
        }
    }

    private var chartTypeBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: viewModel.resolvedChartType.icon)
            Text(viewModel.resolvedChartType.rawValue)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(viewModel.selectedMetric.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(viewModel.selectedMetric.color.opacity(0.12))
        )
    }

    // MARK: - SUMMARY

    private var summaryCards: some View {
        HStack(spacing: 10) {
            summaryCard(
                title: "Ortalama",
                value: viewModel.formattedValue(viewModel.averageValue),
                icon: "chart.line.uptrend.xyaxis"
            )

            summaryCard(
                title: "En Yüksek",
                value: viewModel.topItem.map { viewModel.formattedValue($0.value) } ?? "-",
                icon: "arrow.up.circle.fill"
            )

            summaryCard(
                title: "En Düşük",
                value: viewModel.bottomItem.map { viewModel.formattedValue($0.value) } ?? "-",
                icon: "arrow.down.circle.fill"
            )
        }
    }

    private func summaryCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)

                Text(title)
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - DIVIDER

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.12))
            .frame(height: 1)
            .padding(.vertical, 2)
    }

    // MARK: - DATE

    private var customDateButton: some View {
        Button {
            haptic()
            viewModel.showingCustomDatePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .foregroundStyle(viewModel.selectedMetric.color)

                Text("Tarih Seç")
                    .font(.caption.weight(.semibold))

                Spacer()

                Text(dateRangeText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }

    private var dateRangeText: String {
        let start = viewModel.chartStartDate.formatted(date: .abbreviated, time: .omitted)
        let end = viewModel.chartEndDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) - \(end)"
    }

    // MARK: - METRIC PICKER

    private var metricPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MetricTab.allCases, id: \.self) { tab in
                    Button {
                        haptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            viewModel.setMetric(tab)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.caption)

                            Text(tab.rawValue)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(viewModel.selectedMetric == tab ? .white : .primary.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedMetric == tab ? tab.color : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - LIMIT PICKER

    private var limitPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gösterilecek Departman")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach([3, 5, 10, 100], id: \.self) { value in
                    Button {
                        haptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            viewModel.departmentLimit = value
                        }
                    } label: {
                        Text(value == 100 ? "Hepsi" : "\(value)")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        viewModel.departmentLimit == value
                                        ? viewModel.selectedMetric.color
                                        : Color(.systemGray6)
                                    )
                            )
                            .foregroundStyle(viewModel.departmentLimit == value ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - CHART CONTAINER

    private var chartContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            if viewModel.limitedChartData.isEmpty {
                emptyChartView
            } else {
                chart
                    .padding(12)
            }
        }
        .frame(height: 340)
    }

    private var emptyChartView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Bu tarih aralığında grafik verisi yok")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - CHART SWITCH

    @ViewBuilder
    private var chart: some View {
        switch viewModel.resolvedChartType {
        case .bar:
            barChart

        case .horizontalBar:
            horizontalBarChart

        case .line:
            lineChart

        case .pie:
            pieChart

        case .donut:
            donutChart

        case .area:
            areaChart
        }
    }

    // MARK: - BAR

    private var barChart: some View {
        Chart {
            RuleMark(y: .value("Ortalama", viewModel.averageValue))
                .foregroundStyle(.gray.opacity(0.28))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))

            ForEach(viewModel.limitedChartData, id: \.name) { item in
                BarMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(DepartmentColorService.color(for: item.name))
                .annotation(position: .top) {
                    Text(viewModel.formattedValue(item.value))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    // MARK: - HORIZONTAL BAR

    private var horizontalBarChart: some View {
        Chart {
            ForEach(viewModel.limitedChartData, id: \.name) { item in
                BarMark(
                    x: .value(viewModel.selectedMetric.rawValue, item.value),
                    y: .value("Departman", item.name)
                )
                .foregroundStyle(DepartmentColorService.color(for: item.name))
                .annotation(position: .trailing) {
                    Text(viewModel.formattedValue(item.value))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    // MARK: - LINE

    private var lineChart: some View {
        Chart {
            ForEach(viewModel.limitedChartData, id: \.name) { item in
                LineMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(viewModel.selectedMetric.color)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(DepartmentColorService.color(for: item.name))
                .annotation(position: .top) {
                    Text(viewModel.formattedValue(item.value))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }

    // MARK: - AREA

    private var areaChart: some View {
        Chart {
            ForEach(viewModel.limitedChartData, id: \.name) { item in
                AreaMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(viewModel.selectedMetric.color.opacity(0.35))

                LineMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(viewModel.selectedMetric.color)

                PointMark(
                    x: .value("Departman", item.name),
                    y: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(DepartmentColorService.color(for: item.name))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }

    // MARK: - PIE

    private var pieChart: some View {
        Chart {
            ForEach(viewModel.limitedChartData, id: \.name) { item in
                SectorMark(
                    angle: .value(viewModel.selectedMetric.rawValue, item.value)
                )
                .foregroundStyle(DepartmentColorService.color(for: item.name))
                .annotation(position: .overlay) {
                    if item.value > 0 {
                        Text(viewModel.formattedValue(item.value))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    // MARK: - DONUT

    private var donutChart: some View {
        Chart {
            ForEach(viewModel.limitedChartData, id: \.name) { item in
                SectorMark(
                    angle: .value(viewModel.selectedMetric.rawValue, item.value),
                    innerRadius: .ratio(0.58),
                    angularInset: 2
                )
                .cornerRadius(5)
                .foregroundStyle(DepartmentColorService.color(for: item.name))
                .annotation(position: .overlay) {
                    if item.value > 0 {
                        Text(viewModel.formattedValue(item.value))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .chartBackground { _ in
            VStack(spacing: 2) {
                Text("Toplam")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(viewModel.formattedValue(viewModel.limitedChartData.map(\.value).reduce(0, +)))
                    .font(.headline.weight(.bold))
            }
        }
    }

    // MARK: - LEGEND

    private var legend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.limitedChartData, id: \.name) { item in
                    Button {
                        haptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            viewModel.selectDepartment(item.name)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(DepartmentColorService.color(for: item.name))
                                .frame(width: 8, height: 8)

                            Text(item.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(
                                    viewModel.selectedDepartmentName == item.name
                                    ? DepartmentColorService.color(for: item.name).opacity(0.15)
                                    : Color(.systemGray6)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - SELECTED HINT

    @ViewBuilder
    private var selectedHint: some View {
        if let item = viewModel.selectedItem {
            HStack {
                Text(item.name)
                    .font(.footnote.weight(.semibold))

                Spacer()

                Text(viewModel.formattedValue(item.value))
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(DepartmentColorService.color(for: item.name))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DepartmentColorService.color(for: item.name).opacity(0.12))
            )
        }
    }

    // MARK: - HAPTIC

    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
