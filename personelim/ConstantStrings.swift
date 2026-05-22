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
    static let tabManagmentTitle = "Yönetim"
    
    // MARK: - Department Specific
    static let addDepartmentTitle = "Departman Ekle"
    static let selectSectorHeader = "Departman Sektörü Seçin"
    static let sectorLabel = "Sektör"
    static let departmentToCreateLabel = "Oluşturulacak Departman: "
    
    // MARK: - Add Member Specific
    static let addMemberNavTitle = "Yeni Personel Ekle"
    static let personalInfoSectionHeader = "Kişisel Bilgiler"
    static let jobInfoSectionHeader = "İş Bilgileri"
    static let positionLabel = "Pozisyon / Unvan"
    static let tcNoLabel = "TC Kimlik No (Opsiyonel)"
    static let salaryPlaceholder = "Maaş örneği: 45000"
    
    // MARK: - Personnel Detail
    static let personnelTitlePrefix = "Ünvan:"
    static let incomePrefix = "Gelir:"
    static let identityLabel = "Kimlik"
    static let resumeLabel = "CV"
    static let documentsSectionLabel = "Belgeler"
    static let remainingLeaveDays = "Kalan izin günü"
    static let querySectionTitle = "Sorgu"
    static let noReportTitle = "Henüz rapor yok"
    static let noReportDescription = "Tarih aralığı seçip sorgu oluştur."
    
    // MARK: - General Actions
    static let cancelButton = "İptal"
    static let editButton = "Düzenle"
    static let deleteButton = "Sil"
    static let loadingText = "Yükleniyor..."
    static let noDataFound = "Veri bulunamadı."
    
    // MARK: - Department Card
    static let memberCountSuffix = "Çalışan"
    
    // MARK: - Department Detail
    static let employeesHeader = "Çalışanlar"
    static let noEmployeesInDepartment = "Bu departmanda henüz çalışan bulunmuyor."
    static let addMemberAction = "Personel Ekle"
    static let editDepartmentAction = "Departmanı Düzenle"
    static let deleteDepartmentAction = "Departmanı Sil"
    static let deleteDepartmentConfirmation = "Bu departmanı silmek istediğinize emin misiniz?"
    static let defaultPosition = "Personel"
    
    // MARK: - Department List
    static let departmentsNavTitle = "Departmanlar"
    static let noDepartmentsFound = "Henüz bir departman bulunmuyor."
    
    // MARK: - Edit Department
    static let editCategoryTitle = "Kategori Düzenle"
    static let currentDepartmentPrefix = "Departman: "
    static let selectNewCategory = "Yeni Kategori Seçin"
    static let categoriesLoading = "Kategoriler Yükleniyor..."
    static let updateButton = "Güncelle"
    
    // MARK: - Personnel Detail
    static let positionPrefix = "Ünvan: "
    static let remainingLeaveLabel = "Kalan izin günü"
    static let noReportsAvailable = "Henüz rapor yok"
    static let createQueryInstruction = "Tarih aralığı seçip sorgu oluştur."
    static let queryRangeLabel = "Sorgu Aralığı"

    // MARK: - Performance Levels
    static let performanceWeak = "Zayıf"
    static let performanceMedium = "Orta"
    static let performanceGood = "İyi"
    static let performanceExcellent = "Mükemmel"
    
    // MARK: - Add Employee
    static let addEmployeeTitle = "Çalışan ekle"
    
    // MARK: - Performance Bulk Query
    static let bulkQueryTitle = "Toplu Sorgu"
    static let calendarInstruction = "Takvimden bir tarih aralığı seçin."
    static let startDatePrefix = "Başlangıç: "
    static let endDatePrefix = "Bitiş: "
    static let weekdaysShort = ["Pzt","Sal","Çar","Per","Cum","Cmt","Paz"]
    
    static let performanceQueryTitle = "Sorgu"
    static let performanceQuerySubtitle = "Takvimden bir tarih aralığı seçin."
    static let startTitle = "Başlangıç"
    static let endTitle = "Bitiş"
    
    // MARK: - Performance Report Detail
    static let performanceScoreTitle = "Performans Skoru"
    static let summaryTitle = "Özet"
    static let detailTitle = "Detay"
    static let levelPoor = "Zayıf"
    static let levelAverage = "Orta"
    static let levelGood = "İyi"
    static let levelExcellent = "Mükemmel"
    
    // MARK: - Personnel Edit
    static let editPersonnelTitle = "Personel Düzenle"
    static let positionField = "Ünvan"
    static let salaryField = "Gelir"
    static let deletePersonnelButton = "Personeli Sil"
    static let deleteAlertTitle = "Personeli silmek istiyor musun?"
    static let deleteAlertMessage = "Bu işlem geri alınamaz."
    static let cancel = "İptal"
    static let delete = "Sil"
    
    // MARK: - Personnel List
    static let addLabel = "Ekle"
    static let myPersonnelTitle = "Personellerim"
    static let loading = "Yükleniyor..."

    // MARK: - Sort Options
    static let sortNameAZ = "Ad (A → Z)"
    static let sortNameZA = "Ad (Z → A)"
    static let sortSalaryHighLow = "Maaş (Yüksek → Düşük)"
    static let sortSalaryLowHigh = "Maaş (Düşük → Yüksek)"
    
    // MARK: - Add Employee
    static let addEmployeeSubtitle = "Çalışanınızı e-posta adresiyle davet edin."
    static let sendInvitation = "Davet Gönder"
    static let invalidEmailError = "Geçerli bir email gir."
    static let invitationSuccess = "Davet başarıyla gönderildi."
    
    // MARK: - Department Management
    static let businessInfoNotFoundError = "İşletme bilgisi bulunamadı."
    static let departmentNameEmptyError = "Departman adı boş olamaz."
    static let departmentFetchError = "Departmanlar yüklenemedi."
    static let categoryFetchError = "Kategoriler yüklenemedi."
    
    // MARK: - Job Titles
    static let jobTitlesFetchError = "Unvanlar yüklenirken hata oluştu."

    // MARK: - Premium Subscription
    static let premiumTitle = "Personelim Premium"
    static let premiumCardDescription = "Gelişmiş rol ve ekip yönetimi gibi daha birçok özelliğe erişin"
    static let premiumFeatureAIChatbot = "Kişiye özel AI chatbot desteği"
    static let premiumFeaturePerformance = "Gelişmiş performans analizleri ve grafikler"
    static let premiumFeaturePDF = "PDF rapor oluşturma ve paylaşma"
    static let premiumFeatureCalendar = "Kişisel takvim & iş yükü takibi"
    static let premiumFeatureRoleManagement = "Gelişmiş rol & ekip yönetimi"
    static let premiumPlansEmptyTitle = "Henüz paket bulunamadı"
    static let premiumPlansEmptyDescription = "Paketler yüklendiğinde burada görünecek."
    static let premiumPurchaseAlertTitle = "Abonelik Satın Al"
    static let premiumPurchaseAlertMessageFormat = "%@ paketi %@ fiyatıyla aktif edilecek."
    static let premiumPurchaseButton = "Satın Al"
    static let premiumSubscribeFailed = "Abonelik başlatılamadı"
    static let premiumSubscribeSuccess = "Personelim Premium aktif edildi."
    static let premiumMockBadge = "Sana özel yüzde 50% indirim"
    static let premiumPlanYearly = "Yıllık"
    static let premiumPlanMonthly = "Aylık"
    static let premiumPlanLifetime = "Tek seferlik"
    static let premiumPlanAllFeatures = "Tüm Premium özellikler"
    static let premiumPlanLifetimeSubtitle = "Tüm Premium özelliklere ömür boyu sahip ol"
    static let premiumPlanFallbackTitle = "Premium Paket"

    // MARK: - Slack Integration
    static let slackIntegrationTitle = "Slack Entegrasyonu"
    static let slackIntegrationFormTitle = "Slack entegrasyon"
    static let slackAddTitle = "Slack Ekle"
    static let slackDetailTitle = "Slack Detay"
    static let slackEditTitle = "Slack Düzenle"
    static let slackChannelNameLabel = "Kanal adı"
    static let slackChannelNamePlaceholder = "Slack Kanalı"
    static let slackWebhookURLLabel = "Webhook url"
    static let slackWebhookURLPlaceholder = "Genel Kanalının url"
    static let slackActivityTypesLabel = "Aktivite tipleri"
    static let slackActivitySubtitle = "Bildirim gönderilecek"
    static let slackActivityMeeting = "Toplantı"
    static let slackActivityTask = "Görev"
    static let slackActivityEvent = "Etkinlik"
    static let slackEmptyText = "Henüz Slack kanalı eklenmedi."
    static let slackChannelNameRequired = "Kanal adı boş olamaz."
    static let slackWebhookURLRequired = "Webhook URL boş olamaz."
    static let slackActivityTypeRequired = "En az bir aktivite tipi seçmelisin."
    
    // MARK: - Home View
    static let calendarTitle = "Takvim"
    static let allActivities = "Tüm aktiviteleri gör"
    static let dailyActivitiesTitle = "Günün Aktiviteleri"
    static let noActivityFound = "Bu güne ait bir aktivite bulunmuyor."
}
