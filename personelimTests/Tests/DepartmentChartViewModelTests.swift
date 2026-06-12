import XCTest
@testable import personelim

@MainActor
final class DepartmentChartViewModelTests: XCTestCase {

    private var vm: DepartmentChartViewModel!

    override func setUp() {
        super.setUp()
        vm = DepartmentChartViewModel()
    }

    override func tearDown() {
        vm = nil
        super.tearDown()
    }

    func testInitialValues() {
        XCTAssertEqual(vm.selectedMetric, .skor)
        XCTAssertEqual(vm.departmentLimit, 5)
        XCTAssertFalse(vm.showingCustomDatePicker)
        XCTAssertNil(vm.selectedDepartmentName)
        XCTAssertNil(vm.businessGraph)
        XCTAssertTrue(vm.chartData.isEmpty)
        XCTAssertEqual(vm.averageValue, 0)
        XCTAssertEqual(vm.maxValue, 0)
        XCTAssertNil(vm.selectedItem)
        XCTAssertNil(vm.topItem)
        XCTAssertNil(vm.bottomItem)
    }

    func testSetMetricChangesMetricAndClearsSelectedDepartment() {
        vm.selectDepartment("Muhasebe")
        vm.setMetric(.mesai)

        XCTAssertEqual(vm.selectedMetric, .mesai)
        XCTAssertNil(vm.selectedDepartmentName)
    }

    func testSetCustomDateUpdatesDates() {
        let start = Date(timeIntervalSince1970: 1000)
        let end = Date(timeIntervalSince1970: 5000)

        vm.setCustomDate(start: start, end: end)

        XCTAssertEqual(vm.chartStartDate, start)
        XCTAssertEqual(vm.chartEndDate, end)
    }

    func testSelectDepartmentUpdatesSelectedDepartmentName() {
        vm.selectDepartment("İnsan Kaynakları")

        XCTAssertEqual(vm.selectedDepartmentName, "İnsan Kaynakları")
    }

    func testSetBusinessGraphCreatesScoreChartData() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)

        let data = vm.chartData

        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data.first(where: { $0.name == "İnsan Kaynakları" })?.value, 90)
        XCTAssertEqual(data.first(where: { $0.name == "Muhasebe" })?.value, 70)
        XCTAssertEqual(data.first(where: { $0.name == "Yazılım" })?.value, 50)
    }

    func testLimitedChartDataSortsDescendingAndLimits() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)
        vm.departmentLimit = 2

        let data = vm.limitedChartData

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].name, "İnsan Kaynakları")
        XCTAssertEqual(data[0].value, 90)
        XCTAssertEqual(data[1].name, "Muhasebe")
        XCTAssertEqual(data[1].value, 70)
    }

    func testAverageValueUsesLimitedChartData() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)
        vm.departmentLimit = 2

        XCTAssertEqual(vm.averageValue, 80)
    }

    func testMaxValueUsesLimitedChartData() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)
        vm.departmentLimit = 2

        XCTAssertEqual(vm.maxValue, 90)
    }

    func testTopAndBottomItemUseAllChartData() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)

        XCTAssertEqual(vm.topItem?.name, "İnsan Kaynakları")
        XCTAssertEqual(vm.topItem?.value, 90)

        XCTAssertEqual(vm.bottomItem?.name, "Yazılım")
        XCTAssertEqual(vm.bottomItem?.value, 50)
    }

    func testSelectedItemReturnsSelectedDepartment() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.skor)
        vm.selectDepartment("Muhasebe")

        XCTAssertEqual(vm.selectedItem?.name, "Muhasebe")
        XCTAssertEqual(vm.selectedItem?.value, 70)
    }

    func testMesaiMetricUsesPercentSuffixAndCorrectValues() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.mesai)

        XCTAssertEqual(vm.metricSuffix, "%")
        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 80)
        XCTAssertEqual(vm.formattedValue(80), "80%")
    }

    func testGorevMetricUsesTotalTaskCount() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.gorev)

        XCTAssertEqual(vm.metricSuffix, "")
        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 12)
        XCTAssertEqual(vm.chartData.first(where: { $0.name == "Muhasebe" })?.value, 8)
    }

    func testVerimlilikMetricUsesPercentSuffix() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.verimlilik)

        XCTAssertEqual(vm.metricSuffix, "%")
        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 75)
        XCTAssertEqual(vm.formattedValue(75.5), "75.5%")
    }

    func testTamamlanmaMetricUsesCorrectValues() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.tamamlanma)

        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 95)
        XCTAssertEqual(vm.metricSuffix, "%")
    }

    func testZorlukMetricUsesCorrectValues() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.zorluk)

        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 60)
        XCTAssertEqual(vm.metricSuffix, "%")
    }

    func testCalisanMetricUsesEmployeeCount() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.calisan)

        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 5)
        XCTAssertEqual(vm.metricSuffix, "")
    }

    func testMesaiKullanimMetricUsesCorrectValues() {
        vm.setBusinessGraph(makeGraph())
        vm.setMetric(.mesaiKullanim)

        XCTAssertEqual(vm.chartData.first(where: { $0.name == "İnsan Kaynakları" })?.value, 82)
        XCTAssertEqual(vm.metricSuffix, "%")
    }

    func testFormattedValueWithoutSuffix() {
        vm.setMetric(.skor)

        XCTAssertEqual(vm.formattedValue(10), "10")
        XCTAssertEqual(vm.formattedValue(10.5), "10.5")
    }

    func testFormattedValueWithPercentSuffix() {
        vm.setMetric(.mesai)

        XCTAssertEqual(vm.formattedValue(75), "75%")
        XCTAssertEqual(vm.formattedValue(75.4), "75.4%")
    }

    func testResolvedChartTypes() {
        vm.setMetric(.skor)
        XCTAssertEqual(vm.resolvedChartType, .bar)

        vm.setMetric(.mesai)
        XCTAssertEqual(vm.resolvedChartType, .pie)

        vm.setMetric(.gorev)
        XCTAssertEqual(vm.resolvedChartType, .horizontalBar)

        vm.setMetric(.verimlilik)
        XCTAssertEqual(vm.resolvedChartType, .line)

        vm.setMetric(.tamamlanma)
        XCTAssertEqual(vm.resolvedChartType, .area)

        vm.setMetric(.zorluk)
        XCTAssertEqual(vm.resolvedChartType, .bar)

        vm.setMetric(.calisan)
        XCTAssertEqual(vm.resolvedChartType, .donut)

        vm.setMetric(.mesaiKullanim)
        XCTAssertEqual(vm.resolvedChartType, .bar)
    }

    func testSafeValuesConvertNaNAndInfinityToZero() throws {
        let graph = try decodeGraph(
            """
            {
              "departman_puan_karsilastirma": [
                { "departman_adi": "A", "skor": 90 }
              ],
              "mesai_karsilastirma": [],
              "tamamlanma_orani_karsilastirma": [],
              "verimlilik_karsilastirma": [],
              "zorluk_basari_karsilastirma": [],
              "calisan_sayisi_dagilimi": [],
              "gorev_dagilimi_karsilastirma": [],
              "deadline_uyumu_karsilastirma": [],
              "mesai_kullanim_karsilastirma": [],
              "genel_ozet": {
                "toplam_departman": 1,
                "toplam_calisan": 0,
                "ortalama_departman_skoru": 90,
                "en_yuksek_departman": { "departman_adi": "A", "skor": 90 },
                "en_dusuk_departman": { "departman_adi": "A", "skor": 90 },
                "toplam_hedeflenen_mesai": 0,
                "toplam_gerceklesen_mesai": 0,
                "toplam_tamamlanan_gorev": 0,
                "toplam_tamamlanamayan_gorev": 0
              }
            }
            """
        )

        vm.setBusinessGraph(graph)
        vm.setMetric(.mesai)

        XCTAssertEqual(vm.chartData.first(where: { $0.name == "A" })?.value, 0)
    }
}

// MARK: - Mock Data

private extension DepartmentChartViewModelTests {

    func makeGraph() -> BusinessGrafikVerisiDTO {
        BusinessGrafikVerisiDTO(
            departmanPuanKarsilastirma: [
                DepartmanPuanKarsilastirmaDTO(departmanAdi: "İnsan Kaynakları", skor: 90),
                DepartmanPuanKarsilastirmaDTO(departmanAdi: "Muhasebe", skor: 70),
                DepartmanPuanKarsilastirmaDTO(departmanAdi: "Yazılım", skor: 50)
            ],
            mesaiKarsilastirma: [
                DepartmanMesaiKarsilastirmaDTO(
                    departmanAdi: "İnsan Kaynakları",
                    hedeflenenToplam: 100,
                    gerceklesenToplam: 80,
                    mesaiKullanimOrani: 80
                ),
                DepartmanMesaiKarsilastirmaDTO(
                    departmanAdi: "Muhasebe",
                    hedeflenenToplam: 100,
                    gerceklesenToplam: 60,
                    mesaiKullanimOrani: 60
                ),
                DepartmanMesaiKarsilastirmaDTO(
                    departmanAdi: "Yazılım",
                    hedeflenenToplam: 100,
                    gerceklesenToplam: 40,
                    mesaiKullanimOrani: 40
                )
            ],
            tamamlanmaOraniKarsilastirma: [
                DepartmanTamamlanmaOraniDTO(departmanAdi: "İnsan Kaynakları", oran: 95),
                DepartmanTamamlanmaOraniDTO(departmanAdi: "Muhasebe", oran: 70),
                DepartmanTamamlanmaOraniDTO(departmanAdi: "Yazılım", oran: 45)
            ],
            verimlilikKarsilastirma: [
                DepartmanVerimlilikDTO(departmanAdi: "İnsan Kaynakları", verimlilik: 75),
                DepartmanVerimlilikDTO(departmanAdi: "Muhasebe", verimlilik: 65),
                DepartmanVerimlilikDTO(departmanAdi: "Yazılım", verimlilik: 55)
            ],
            zorlukBasariKarsilastirma: [
                DepartmanZorlukBasariDTO(departmanAdi: "İnsan Kaynakları", zorlukBasari: 60),
                DepartmanZorlukBasariDTO(departmanAdi: "Muhasebe", zorlukBasari: 50),
                DepartmanZorlukBasariDTO(departmanAdi: "Yazılım", zorlukBasari: 40)
            ],
            calisanSayisiDagilimi: [
                DepartmanCalisanSayisiDTO(departmanAdi: "İnsan Kaynakları", calisanSayisi: 5),
                DepartmanCalisanSayisiDTO(departmanAdi: "Muhasebe", calisanSayisi: 3),
                DepartmanCalisanSayisiDTO(departmanAdi: "Yazılım", calisanSayisi: 2)
            ],
            gorevDagilimiKarsilastirma: [
                DepartmanGorevDagilimiDTO(
                    departmanAdi: "İnsan Kaynakları",
                    tamamlanan: 10,
                    tamamlanamayan: 2,
                    toplam: 12
                ),
                DepartmanGorevDagilimiDTO(
                    departmanAdi: "Muhasebe",
                    tamamlanan: 6,
                    tamamlanamayan: 2,
                    toplam: 8
                ),
                DepartmanGorevDagilimiDTO(
                    departmanAdi: "Yazılım",
                    tamamlanan: 3,
                    tamamlanamayan: 2,
                    toplam: 5
                )
            ],
            deadlineUyumuKarsilastirma: [
                DepartmanDeadlineUyumuDTO(departmanAdi: "İnsan Kaynakları", deadlineUyumu: nil),
                DepartmanDeadlineUyumuDTO(departmanAdi: "Muhasebe", deadlineUyumu: nil),
                DepartmanDeadlineUyumuDTO(departmanAdi: "Yazılım", deadlineUyumu: nil)
            ],
            mesaiKullanimKarsilastirma: [
                DepartmanMesaiKullanimDTO(departmanAdi: "İnsan Kaynakları", mesaiKullanimi: 82),
                DepartmanMesaiKullanimDTO(departmanAdi: "Muhasebe", mesaiKullanimi: 61),
                DepartmanMesaiKullanimDTO(departmanAdi: "Yazılım", mesaiKullanimi: 42)
            ],
            genelOzet: BusinessGenelOzetDTO(
                toplamDepartman: 3,
                toplamCalisan: 10,
                ortalamaDepartmanSkoru: 70,
                enYuksekDepartman: DepartmanUçDeğerDTO(
                    departmanAdi: "İnsan Kaynakları",
                    skor: 90
                ),
                enDusukDepartman: DepartmanUçDeğerDTO(
                    departmanAdi: "Yazılım",
                    skor: 50
                ),
                toplamHedeflenenMesai: 300,
                toplamGerceklesenMesai: 180,
                toplamTamamlananGorev: 19,
                toplamTamamlanamayanGorev: 6
            )
        )
    }

    func decodeGraph(_ json: String) throws -> BusinessGrafikVerisiDTO {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(BusinessGrafikVerisiDTO.self, from: data)
    }
}
