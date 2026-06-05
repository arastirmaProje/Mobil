//
//  DepartmentResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

// MARK: - Department Response
struct DepartmentResponseDTO: Codable, Hashable {
    let id: String
    let businessId: String
    let categoryId: Int
    let name: String
    let memberCount: Int
    let createdAt: String
}

// MARK: - Department Performance Request
struct DepartmentPerformanceRequestDTO: Encodable {
    let businessId: String
    let departmentId: String
    let startDate: String
    let endDate: String
}

// MARK: - Department Performance Response
struct DepartmentPerformanceResponseDTO: Decodable {
    let departmanId: String
    let departmanAdi: String
    let departmanSkoru: Double
    let toplamCalisan: Int
    let raporOzeti: String
    let detayliRapor: String
    let calisanSkorlari: [CalisanSkorDTO]
    let grafikVerisi: GrafikVerisiDTO

    enum CodingKeys: String, CodingKey {
        case departmanId = "departman_id"
        case departmanAdi = "departman_adi"
        case departmanSkoru = "departman_skoru"
        case toplamCalisan = "toplam_calisan"
        case raporOzeti = "rapor_ozeti"
        case detayliRapor = "detayli_rapor"
        case calisanSkorlari = "calisan_skorlari"
        case grafikVerisi = "grafik_verisi"
    }
}

// MARK: - Performance Sub Models
struct CalisanSkorDTO: Decodable, Identifiable {
    var id: String { calisanId }
    let calisanId: String
    let adSoyad: String
    let performansSkoru: Double

    enum CodingKeys: String, CodingKey {
        case calisanId = "calisan_id"
        case adSoyad = "ad_soyad"
        case performansSkoru = "performans_skoru"
    }
}

// MARK: - Grafik Verisi DTO
struct GrafikVerisiDTO: Decodable {
    let calisanPerformansKarsilastirma: [CalisanPerformansDTO]
    let calisanMesaiKarsilastirma: [CalisanMesaiDTO]
    let calisanDetayliMetrikler: [CalisanDetayliMetrikDTO]
    let departmanMesaiOzeti: DepartmanMesaiOzetiDTO
    let departmanMetrikleri: DepartmanMetrikleriDTO
    let skorOzeti: SkorOzetiDTO
    let gorevDagilimi: GorevDagilimiDTO
    let calisanTamamlanmaOraniKarsilastirma: [CalisanTamamlanmaOraniDTO]
    let calisanVerimlilikKarsilastirma: [CalisanVerimlilikDTO]
    let calisanZorlukBasariKarsilastirma: [CalisanZorlukBasariDTO]
    let calisanDeadlineUyumuKarsilastirma: [CalisanDeadlineUyumuDTO]
    let calisanGorevDagilimiKarsilastirma: [CalisanGorevDagilimiKarsilastirmaDTO]

    enum CodingKeys: String, CodingKey {
        case calisanPerformansKarsilastirma = "calisan_performans_karsilastirma"
        case calisanMesaiKarsilastirma = "calisan_mesai_karsilastirma"
        case calisanDetayliMetrikler = "calisan_detayli_metrikler"
        case departmanMesaiOzeti = "departman_mesai_ozeti"
        case departmanMetrikleri = "departman_metrikleri"
        case skorOzeti = "skor_ozeti"
        case gorevDagilimi = "gorev_dagilimi"
        case calisanTamamlanmaOraniKarsilastirma = "calisan_tamamlanma_orani_karsilastirma"
        case calisanVerimlilikKarsilastirma = "calisan_verimlilik_karsilastirma"
        case calisanZorlukBasariKarsilastirma = "calisan_zorluk_basari_karsilastirma"
        case calisanDeadlineUyumuKarsilastirma = "calisan_deadline_uyumu_karsilastirma"
        case calisanGorevDagilimiKarsilastirma = "calisan_gorev_dagilimi_karsilastirma"
    }
}

struct CalisanPerformansDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let skor: Double

    enum CodingKeys: String, CodingKey {
        case adSoyad = "ad_soyad"
        case skor = "skor"
    }
}

struct CalisanMesaiDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let hedeflenen: Double
    let gerceklesen: Double
    let mesaiKullanimOrani: Double

    enum CodingKeys: String, CodingKey {
        case adSoyad = "ad_soyad"
        case hedeflenen = "hedeflenen"
        case gerceklesen = "gerceklesen"
        case mesaiKullanimOrani = "mesai_kullanim_orani"
    }
}

struct CalisanDetayliMetrikDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let performansSkoru: Double
    let tamamlananGorev: Int
    let tamamlanamayanGorev: Int
    let tamamlanmaOrani: Double
    let verimlilikSkoru: Double
    let deadlineUyumSkoru: Double?
    let zorlukBasariDengesi: Double
    let mesaiKullanimOrani: Double

    enum CodingKeys: String, CodingKey {
        case adSoyad = "ad_soyad"
        case performansSkoru = "performans_skoru"
        case tamamlananGorev = "tamamlanan_gorev"
        case tamamlanamayanGorev = "tamamlanamayan_gorev"
        case tamamlanmaOrani = "tamamlanma_orani"
        case verimlilikSkoru = "verimlilik_skoru"
        case deadlineUyumSkoru = "deadline_uyum_skoru"
        case zorlukBasariDengesi = "zorluk_basari_dengesi"
        case mesaiKullanimOrani = "mesai_kullanim_orani"
    }
}

struct DepartmanMesaiOzetiDTO: Decodable {
    let toplamHedeflenen: Double
    let toplamGerceklesen: Double
    let mesaiKullanimOrani: Double

    enum CodingKeys: String, CodingKey {
        case toplamHedeflenen = "toplam_hedeflenen"
        case toplamGerceklesen = "toplam_gerceklesen"
        case mesaiKullanimOrani = "mesai_kullanim_orani"
    }
}

struct DepartmanMetrikleriDTO: Decodable {
    let ortalamaTamamlanmaOrani: Double
    let ortalamaVerimlilik: Double
    let ortalamaDeadlineUyumu: Double?
    let ortalamaZorlukBasari: Double
    let ortalamaMesaiKullanimi: Double

    enum CodingKeys: String, CodingKey {
        case ortalamaTamamlanmaOrani = "ortalama_tamamlanma_orani"
        case ortalamaVerimlilik = "ortalama_verimlilik"
        case ortalamaDeadlineUyumu = "ortalama_deadline_uyumu"
        case ortalamaZorlukBasari = "ortalama_zorluk_basari"
        case ortalamaMesaiKullanimi = "ortalama_mesai_kullanimi"
    }
}

struct SkorOzetiDTO: Decodable {
    let departmanSkoru: Double
    let enYuksek: Double
    let enDusuk: Double
    let ortalama: Double

    enum CodingKeys: String, CodingKey {
        case departmanSkoru = "departman_skoru"
        case enYuksek = "en_yuksek"
        case enDusuk = "en_dusuk"
        case ortalama
    }
}

struct GorevDagilimiDTO: Decodable {
    let toplamTamamlanan: Int
    let toplamTamamlanamayan: Int
    let toplamGorev: Int

    enum CodingKeys: String, CodingKey {
        case toplamTamamlanan = "toplam_tamamlanan"
        case toplamTamamlanamayan = "toplam_tamamlanamayan"
        case toplamGorev = "toplam_gorev"
    }
}

struct CalisanTamamlanmaOraniDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let oran: Double
    enum CodingKeys: String, CodingKey { case adSoyad = "ad_soyad"; case oran }
}

struct CalisanVerimlilikDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let verimlilik: Double
    enum CodingKeys: String, CodingKey { case adSoyad = "ad_soyad"; case verimlilik }
}

struct CalisanZorlukBasariDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let zorlukBasari: Double
    enum CodingKeys: String, CodingKey { case adSoyad = "ad_soyad"; case zorlukBasari = "zorluk_basari" }
}

struct CalisanDeadlineUyumuDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let deadlineUyumu: Double
    enum CodingKeys: String, CodingKey { case adSoyad = "ad_soyad"; case deadlineUyumu = "deadline_uyumu" }
}

struct CalisanGorevDagilimiKarsilastirmaDTO: Decodable, Identifiable {
    var id: String { adSoyad }
    let adSoyad: String
    let tamamlanan: Int
    let tamamlanamayan: Int
    let toplam: Int
    enum CodingKeys: String, CodingKey { case adSoyad = "ad_soyad"; case tamamlanan; case tamamlanamayan; case toplam }
}

// MARK: - Department Charts Request
struct DepartmentChartsRequestDTO: Encodable {
    let businessId: String
    let startDate: String
    let endDate: String
}

// MARK: - Department Charts Item Response
struct DepartmentChartItemDTO: Decodable, Identifiable {
    var id: String { departmentId }
    let departmentId: String
    let departmentName: String
    let scores: [Double]
}

// MARK: - Business Department Charts Response Root Object
struct BusinessDepartmentChartsResponseDTO: Decodable {
    let toplamDepartman: Int
    let grafikVerisi: BusinessGrafikVerisiDTO

    enum CodingKeys: String, CodingKey {
        case toplamDepartman = "toplam_departman"
        case grafikVerisi = "grafik_verisi"
    }
}

// MARK: - Business Grafik Verisi DTO
struct BusinessGrafikVerisiDTO: Decodable {
    let departmanPuanKarsilastirma: [DepartmanPuanKarsilastirmaDTO]
    let mesaiKarsilastirma: [DepartmanMesaiKarsilastirmaDTO]
    let tamamlanmaOraniKarsilastirma: [DepartmanTamamlanmaOraniDTO]
    let verimlilikKarsilastirma: [DepartmanVerimlilikDTO]
    let zorlukBasariKarsilastirma: [DepartmanZorlukBasariDTO]
    let calisanSayisiDagilimi: [DepartmanCalisanSayisiDTO]
    let gorevDagilimiKarsilastirma: [DepartmanGorevDagilimiDTO]
    let deadlineUyumuKarsilastirma: [DepartmanDeadlineUyumuDTO]
    let mesaiKullanimKarsilastirma: [DepartmanMesaiKullanimDTO]
    let genelOzet: BusinessGenelOzetDTO

    enum CodingKeys: String, CodingKey {
        case departmanPuanKarsilastirma = "departman_puan_karsilastirma"
        case mesaiKarsilastirma = "mesai_karsilastirma"
        case tamamlanmaOraniKarsilastirma = "tamamlanma_orani_karsilastirma"
        case verimlilikKarsilastirma = "verimlilik_karsilastirma"
        case zorlukBasariKarsilastirma = "zorluk_basari_karsilastirma"
        case calisanSayisiDagilimi = "calisan_sayisi_dagilimi"
        case gorevDagilimiKarsilastirma = "gorev_dagilimi_karsilastirma"
        case deadlineUyumuKarsilastirma = "deadline_uyumu_karsilastirma"
        case mesaiKullanimKarsilastirma = "mesai_kullanim_karsilastirma"
        case genelOzet = "genel_ozet"
    }
}

// MARK: - Business Sub Models (Departman Kırılımları)
struct DepartmanPuanKarsilastirmaDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let skor: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case skor }
}

struct DepartmanMesaiKarsilastirmaDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let hedeflenenToplam: Double
    let gerceklesenToplam: Double
    let mesaiKullanimOrani: Double
    enum CodingKeys: String, CodingKey {
        case departmanAdi = "departman_adi"
        case hedeflenenToplam = "hedeflenen_toplam"
        case gerceklesenToplam = "gerceklesen_toplam"
        case mesaiKullanimOrani = "mesai_kullanim_orani"
    }
}

struct DepartmanTamamlanmaOraniDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let oran: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case oran }
}

struct DepartmanVerimlilikDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let verimlilik: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case verimlilik }
}

struct DepartmanZorlukBasariDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let zorlukBasari: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case zorlukBasari = "zorluk_basari" }
}

struct DepartmanCalisanSayisiDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let calisanSayisi: Int
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case calisanSayisi = "calisan_sayisi" }
}

struct DepartmanGorevDagilimiDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let tamamlanan: Int
    let tamamlanamayan: Int
    let toplam: Int
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case tamamlanan; case tamamlanamayan; case toplam }
}

struct DepartmanDeadlineUyumuDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let deadlineUyumu: Double? // Backend'den null gelebildiği için opsiyonel yaptık
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case deadlineUyumu = "deadline_uyumu" }
}

struct DepartmanMesaiKullanimDTO: Decodable, Identifiable {
    var id: String { departmanAdi }
    let departmanAdi: String
    let mesaiKullanimi: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case mesaiKullanimi = "mesai_kullanimi" }
}

// MARK: - Business Genel Ozet DTO
struct BusinessGenelOzetDTO: Decodable {
    let toplamDepartman: Int
    let toplamCalisan: Int
    let ortalamaDepartmanSkoru: Double
    let enYuksekDepartman: DepartmanUçDeğerDTO
    let enDusukDepartman: DepartmanUçDeğerDTO
    let toplamHedeflenenMesai: Double
    let toplamGerceklesenMesai: Double
    let toplamTamamlananGorev: Int
    let toplamTamamlanamayanGorev: Int

    enum CodingKeys: String, CodingKey {
        case toplamDepartman = "toplam_departman"
        case toplamCalisan = "toplam_calisan"
        case ortalamaDepartmanSkoru = "ortalama_departman_skoru"
        case enYuksekDepartman = "en_yuksek_departman"
        case enDusukDepartman = "en_dusuk_departman"
        case toplamHedeflenenMesai = "toplam_hedeflenen_mesai"
        case toplamGerceklesenMesai = "toplam_gerceklesen_mesai"
        case toplamTamamlananGorev = "toplam_tamamlanan_gorev"
        case toplamTamamlanamayanGorev = "toplam_tamamlanamayan_gorev"
    }
}

struct DepartmanUçDeğerDTO: Decodable {
    let departmanAdi: String
    let skor: Double
    enum CodingKeys: String, CodingKey { case departmanAdi = "departman_adi"; case skor }
}

struct DepartmentMetricBundle {
    let name: String
    let value: Double
}
