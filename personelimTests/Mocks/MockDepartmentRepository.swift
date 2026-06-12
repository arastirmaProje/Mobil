//
//  MockDepartmentRepository.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation
@testable import personelim

enum DepartmentViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}

final class MockDepartmentRepository: DepartmentRepositoryProtocol {

    var departmentsToReturn: [DepartmentResponseDTO] = []
    var categoriesToReturn: [JobCategoryDTO] = []
    var performanceToReturn: DepartmentPerformanceResponseDTO?
    var businessChartsToReturn: BusinessDepartmentChartsResponseDTO?

    var errorToThrow: Error?

    var didCallFetchDepartments = false
    var receivedBusinessId: String?

    var didCallFetchCategories = false
    var fetchCategoriesCallCount = 0

    var didCallCreateDepartment = false
    var receivedCreateRequest: CreateDepartmentRequestDTO?

    var didCallUpdateDepartment = false
    var receivedUpdateId: String?
    var receivedUpdateName: String?
    var receivedUpdateCategoryId: Int?

    var didCallDeleteDepartment = false
    var receivedDeleteId: String?

    var didCallQueryDepartmentPerformance = false
    var receivedPerformanceRequest: DepartmentPerformanceRequestDTO?

    var didCallFetchDepartmentCharts = false
    var receivedChartsBusinessId: String?
    var receivedChartsStartDate: String?
    var receivedChartsEndDate: String?

    func fetchDepartments(
        businessId: String
    ) async throws -> [DepartmentResponseDTO] {
        didCallFetchDepartments = true
        receivedBusinessId = businessId

        if let errorToThrow {
            throw errorToThrow
        }

        return departmentsToReturn
    }

    func fetchCategories() async throws -> [JobCategoryDTO] {
        didCallFetchCategories = true
        fetchCategoriesCallCount += 1

        if let errorToThrow {
            throw errorToThrow
        }

        return categoriesToReturn
    }

    func createDepartment(
        request: CreateDepartmentRequestDTO
    ) async throws {
        didCallCreateDepartment = true
        receivedCreateRequest = request

        if let errorToThrow {
            throw errorToThrow
        }
    }

    func updateDepartment(
        id: String,
        name: String,
        categoryId: Int
    ) async throws {
        didCallUpdateDepartment = true
        receivedUpdateId = id
        receivedUpdateName = name
        receivedUpdateCategoryId = categoryId

        if let errorToThrow {
            throw errorToThrow
        }
    }

    func deleteDepartment(
        id: String
    ) async throws {
        didCallDeleteDepartment = true
        receivedDeleteId = id

        if let errorToThrow {
            throw errorToThrow
        }
    }

    func queryDepartmentPerformance(
        request: DepartmentPerformanceRequestDTO
    ) async throws -> DepartmentPerformanceResponseDTO {
        didCallQueryDepartmentPerformance = true
        receivedPerformanceRequest = request

        if let errorToThrow {
            throw errorToThrow
        }

        return performanceToReturn ?? makeMockDepartmentPerformance()
    }

    func fetchDepartmentCharts(
        businessId: String,
        startDate: String,
        endDate: String
    ) async throws -> BusinessDepartmentChartsResponseDTO {
        didCallFetchDepartmentCharts = true
        receivedChartsBusinessId = businessId
        receivedChartsStartDate = startDate
        receivedChartsEndDate = endDate

        if let errorToThrow {
            throw errorToThrow
        }

        return businessChartsToReturn ?? makeMockBusinessCharts()
    }
}

// MARK: - Mock Data

func makeMockDepartmentPerformance() -> DepartmentPerformanceResponseDTO {
    DepartmentPerformanceResponseDTO(
        departmanId: "dept-1",
        departmanAdi: "Yazılım",
        departmanSkoru: 85,
        toplamCalisan: 3,
        raporOzeti: "Özet",
        detayliRapor: "Detay",
        calisanSkorlari: [
            CalisanSkorDTO(
                calisanId: "user-1",
                adSoyad: "Test User",
                performansSkoru: 80
            )
        ],
        grafikVerisi: makeMockGrafikVerisi()
    )
}

func makeMockGrafikVerisi() -> GrafikVerisiDTO {
    GrafikVerisiDTO(
        calisanPerformansKarsilastirma: [],
        calisanMesaiKarsilastirma: [],
        calisanDetayliMetrikler: [],
        departmanMesaiOzeti: DepartmanMesaiOzetiDTO(
            toplamHedeflenen: 100,
            toplamGerceklesen: 80,
            mesaiKullanimOrani: 80
        ),
        departmanMetrikleri: DepartmanMetrikleriDTO(
            ortalamaTamamlanmaOrani: 90,
            ortalamaVerimlilik: 75,
            ortalamaDeadlineUyumu: nil,
            ortalamaZorlukBasari: 65,
            ortalamaMesaiKullanimi: 80
        ),
        skorOzeti: SkorOzetiDTO(
            departmanSkoru: 85,
            enYuksek: 90,
            enDusuk: 70,
            ortalama: 80
        ),
        gorevDagilimi: GorevDagilimiDTO(
            toplamTamamlanan: 8,
            toplamTamamlanamayan: 2,
            toplamGorev: 10
        ),
        calisanTamamlanmaOraniKarsilastirma: [],
        calisanVerimlilikKarsilastirma: [],
        calisanZorlukBasariKarsilastirma: [],
        calisanDeadlineUyumuKarsilastirma: [],
        calisanGorevDagilimiKarsilastirma: []
    )
}

func makeMockBusinessCharts() -> BusinessDepartmentChartsResponseDTO {
    BusinessDepartmentChartsResponseDTO(
        toplamDepartman: 1,
        grafikVerisi: BusinessGrafikVerisiDTO(
            departmanPuanKarsilastirma: [
                DepartmanPuanKarsilastirmaDTO(
                    departmanAdi: "Yazılım",
                    skor: 85
                )
            ],
            mesaiKarsilastirma: [
                DepartmanMesaiKarsilastirmaDTO(
                    departmanAdi: "Yazılım",
                    hedeflenenToplam: 100,
                    gerceklesenToplam: 80,
                    mesaiKullanimOrani: 80
                )
            ],
            tamamlanmaOraniKarsilastirma: [
                DepartmanTamamlanmaOraniDTO(
                    departmanAdi: "Yazılım",
                    oran: 90
                )
            ],
            verimlilikKarsilastirma: [
                DepartmanVerimlilikDTO(
                    departmanAdi: "Yazılım",
                    verimlilik: 75
                )
            ],
            zorlukBasariKarsilastirma: [
                DepartmanZorlukBasariDTO(
                    departmanAdi: "Yazılım",
                    zorlukBasari: 65
                )
            ],
            calisanSayisiDagilimi: [
                DepartmanCalisanSayisiDTO(
                    departmanAdi: "Yazılım",
                    calisanSayisi: 3
                )
            ],
            gorevDagilimiKarsilastirma: [
                DepartmanGorevDagilimiDTO(
                    departmanAdi: "Yazılım",
                    tamamlanan: 8,
                    tamamlanamayan: 2,
                    toplam: 10
                )
            ],
            deadlineUyumuKarsilastirma: [
                DepartmanDeadlineUyumuDTO(
                    departmanAdi: "Yazılım",
                    deadlineUyumu: nil
                )
            ],
            mesaiKullanimKarsilastirma: [
                DepartmanMesaiKullanimDTO(
                    departmanAdi: "Yazılım",
                    mesaiKullanimi: 80
                )
            ],
            genelOzet: BusinessGenelOzetDTO(
                toplamDepartman: 1,
                toplamCalisan: 3,
                ortalamaDepartmanSkoru: 85,
                enYuksekDepartman: DepartmanUçDeğerDTO(
                    departmanAdi: "Yazılım",
                    skor: 85
                ),
                enDusukDepartman: DepartmanUçDeğerDTO(
                    departmanAdi: "Yazılım",
                    skor: 85
                ),
                toplamHedeflenenMesai: 100,
                toplamGerceklesenMesai: 80,
                toplamTamamlananGorev: 8,
                toplamTamamlanamayanGorev: 2
            )
        )
    )
}
