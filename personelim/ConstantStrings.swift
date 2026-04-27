//
//  ConstantStrings.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation

public enum ConstantStrings {

    // MARK: - Auth / General Errors
    static let failText = "Giriş işlemi başarısız oldu"
    static let registerFail = "Kayıt işlemi başarısız oldu"
    static let unknownError = "Bilinmeyen bir hata oluştu"
    static let getProfileFail = "Profil bilgileri alınamadı"
    static let profileNotRetrivied = "Profil bilgileri getirilemedi"
    static let profileUpdateFail = "Profil güncellenemedi"
    static let deleteAccountFail = "Hesap silinemedi"
    static let sendResetFail = "Şifre sıfırlama kodu gönderilemedi"

    // MARK: - Generic
    static let dashPlaceholder = "—"
    static let okButton = "Tamam"
    static let addButton = "Ekle"

    // MARK: - AppState / Bootstrap
    static let membersLoadFailed = "Üyeler yüklenemedi"
    static let refreshMembersFailed = "Üye listesi yenilenemedi"

    // MARK: - Business Member
    static let membersFetchFail = "Üye listesi alınamadı"
    static let memberDetailFail = "Üye detayı alınamadı"
    static let memberUpdateFail = "Üye güncellenemedi"
    static let memberDocumentUploadFail = "Belge yüklenemedi"
    static let memberDocumentDeleteFail = "Belge silinemedi"

    // MARK: - Business
    static let businessCreateFail = "Şirket oluşturulamadı"
    static let businessFetchFail = "Şirket bilgisi alınamadı"
    static let businessesFetchFail = "Şirketler alınamadı"
    static let businessNotFound = "Şirket bulunamadı"
    static let businessDocumentUploadFail = "Şirket belgesi yüklenemedi"
    static let businessDocumentDeleteFail = "Şirket belgesi silinemedi"

    // MARK: - Performance
    static let performanceReportCreateFail = "Performans raporu oluşturulamadı"
    static let performanceReportDetailFail = "Performans raporu detayı alınamadı"

    // MARK: - Shift
    static let createShiftFail = "Mesai kaydı oluşturulamadı"

    // MARK: - Common Form Labels
    static let emailLabel = "E-posta"
    static let emailPlaceholder = "ornek@gmail.com"
    static let passwordLabel = "Şifre"
    static let phoneLabel = "Telefon"
    static let phonePlaceholder = "555 555 55 55"

    // MARK: - Forgot Password
    static let forgotPasswordTitle = "Şifremi Unuttum"
    static let enterCode = "Kodu Gir"
    static let sendCode = "Kod Gönder"
    static let resendCode = "Tekrar Gönder"

    // MARK: - Login
    static let loginTitle = "Giriş Yapalım"
    static let passwordPlaceholderLogin = "••••••"
    static let rememberMe = "Beni hatırla"
    static let forgotPasswordAction = "Şifremi unuttum"
    static let loginButton = "Giriş Yap"

    // MARK: - Reset Password
    static let resetPasswordTitle = "Şifre Yenile"
    static let newPasswordLabel = "Yeni Şifre"
    static let newPasswordPlaceholder = "Yeni şifre"
    static let confirmPasswordLabel = "Yeni Şifre Tekrar"
    static let confirmPasswordPlaceholder = "Yeni şifreyi tekrar girin"
    static let confirmButton = "Onayla"

    // MARK: - Signup
    static let signupTitle = "Kayıt Ol"
    static let firstNameLabel = "Ad"
    static let firstNamePlaceholder = "Adınız"
    static let lastNameLabel = "Soyad"
    static let lastNamePlaceholder = "Soyadınız"
    static let passwordPlaceholderSignup = "••••••"
    static let continueButton = "Devam Et"

    // MARK: - Home
    static let welcome = "Hoş geldin"
    static let shiftHours = "Mesai saatleri"
    static let endDay = "Günü sonlandır"
    static let start = "Başlat"
    static let resume = "Devam et"
    static let pause = "Duraklat"
    static let activeDayTable = "Aktif gün tablosu"
    static let seeDetails = "Detayları gör"
    static let activeTasks = "Aktif aktiviteler"
    static let noActiveTasks = "Aktif aktiviten yok"
    static let seeAllTasks = "Tüm aktiviteleri gör"
    static let businessIdNotFound = "BusinessId bulunamadı."

    // MARK: - Shift Day Detail
    static let totalWorkPrefix = "Toplam çalışma"
    static let noShiftForDay = "Bu güne ait mesai kaydı yok."
    static let durationPrefix = "Süre"

    // MARK: - Location / Office
    static let locationLabel = "Lokasyon"
    static let homeLocation = "Ev"
    static let addLocation = "Lokasyon ekle"
    static let officesTitle = "Ofisler"
    static let officePrefix = "Ofis"
    static let officeNamePlaceholder = "Ofis adı (örn: Ofis 1)"
    static let addressPlaceholder = "Adres"
    static let pickFromMap = "Haritadan seç"
    static let selectedLocation = "Seçilen Konum"
    static let locationNotSelected = "Konum seçilmedi"

    // MARK: - Province / District
    static let provinceLabel = "İl"
    static let provincePickerPlaceholder = "İl seç"
    static let districtLabel = "İlçe"
    static let districtPickerPlaceholder = "İlçe seç"
    static let pickerSelect = "Seçiniz"

    // MARK: - Create / Edit Company
    static let createCompanyTitle = "Şirket oluştur"
    static let createCompanyButton = "Oluştur"
    static let editCompanyTitle = "Şirket düzenle"
    static let profileImageLabel = "Profil Resmi"
    static let companyNameLabel = "Şirket İsmi"
    static let companyEmailLabel = "Email"
    static let companyDescriptionLabel = "Açıklama"
    static let documentsLabel = "Belgeler"

    // MARK: - Email Verification
    static let emailVerificationTitle = "Email Doğrulama"
    static let emailVerificationDescriptionFormat =
        "%@ adresine gönderilen kodu giriniz"

    // MARK: - Map Picker
    static let mapPickerTitle = "Konum Seç"
    static let searchPlaceholder = "Yer ara (örn: Kadıköy)"
    static let searchButton = "Ara"
    static let closeButton = "Kapat"
    static let saveButton = "Kaydet"
    static let pickedFromMapTitle = "Haritadan seçildi"
    static let currentLocationTitle = "Mevcut Konum"
    static let searchEmptyHint = "Arama yapabilirsiniz."
    static let searchNoResult = "Sonuç bulunamadı."

    // MARK: - Leave
    static let createLeaveTitle = "İzin oluştur"
    static let createLeaveSubtitle = "Bir tarih aralığı seçin"
    static let dateRangeLabel = "Tarih aralığı"
    static let startDateLabel = "Başlangıç"
    static let endDateLabel = "Bitiş"
    static let leaveTitleLabel = "İzin başlığı"
    static let leaveTitlePlaceholder = "Başlık girin"
    static let leaveDescriptionLabel = "İzin açıklaması"
    static let leaveErrorTitle = "Hata"
    
    static let errorTitle = "Hata"
    static let shiftLocationTitle = "Hangi konumda çalışacaksın?"
    static let allTablesTitle = "Tüm tablolar"
    static let sortTitle = "Sıralama"
    static let companyNamePlaceholder = "Şirket adı"
    static let detailedAddressLabel = "Detaylı Adres"
    static let detailedAddressPlaceholder = "Adres gir"
    static let descriptionLabel = "Açıklama"
    static let descriptionPlaceholder = "Açıklama gir"
    
    // MARK: - Activities
    static let activeTasksTitle = "Aktif Aktiviteler"
    static let pastTasksTitle = "Geçmiş Aktiviteler"
    static let createTaskButton = "Yeni aktivite oluştur"

    static let emptyTasksTitle = "Henüz aktivite yok"
    static let emptyTasksDescription = "Sana atanmış veya tamamladığın bir aktivite bulunmuyor."
    static let tasksNoDownload = "Aktiviteler yüklenemedi"

    static let activitiesNavTitle = "Aktiviteler"
    static let activityCreatorTitle = "Aktivite oluşturucu"
    static let activityCreatorSubtitle = "Bir tarih aralığı seçin"
    static let activityTitleLabel = "Aktivite başlığı"
    static let activityTitlePlaceholder = "Başlık girin"
    static let activityTypeLabel = "Aktivite türü"
    static let activityDetailLabel = "Aktivite detayı"
    static let activityAssignLabel = "Aktiviteyi ata"
    static let selectEmployeePlaceholder = "Çalışan seçiniz"

    static let statusSelectLabel = "Durumu seçiniz"
    static let pendingText = "Beklemede"
    static let expiredText = "Süresi geçti"
    static let completedText = "Tamamlandı"
    static let closedText = "Kapatıldı"
    static let sentBySuffix = "tarafından gönderildi"
    static let assignedBySuffix = "tarafından atandı"
    static let noDetailText = "Detay eklenmemiş."
    static let activityDoneFooter = "Bu aktivite tamamlandı"
    static let activityClosedFooter = "Bu aktivite kapatıldı"
    static let activityExpiredFooter = "Aktivite süresi geçti"

    static let dateRangeNotSelectedError = "Tarih aralığı seçilmedi"
    static let feedbackNotSupportedError = "Bu aktivite için geri bildirim desteklenmiyor."

    // MARK: - Assignee
    static let assigneePickerTitle = "Çalışan Seç"
    static let doneButton = "Bitti"

    // MARK: - Feedback
    static let feedbackTitle = "Aktivite Geri Bildirimi"
    static let feedbackSubtitle = "Bu aktiviteyle ilgili deneyimini paylaş"
    static let feedbackThoughtsLabel = "Düşünceler"
    static let feedbackLevelLabel = "Seviye seçiniz"
    static let feedbackVeryEasy = "Çok kolay"
    static let feedbackVeryHard = "Çok zor"

    static let difficultyVeryEasy = "Çok Kolay"
    static let difficultyEasy = "Kolay"
    static let difficultyMedium = "Orta"
    static let difficultyHard = "Zor"
    static let difficultyVeryHard = "Çok Zor"

    // MARK: - Tab Bar
    static let tabHomeTitle = "Ana Sayfa"
    static let tabActivitiesTitle = "Aktiviteler"
    static let tabPersonnelTitle = "Personel"
    static let tabProfileTitle = "Profil"
}
