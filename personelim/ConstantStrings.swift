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
    static let searchPlaceholder = "Ara"
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
    static let remainingLeaveDays = "Kullanılan izin günü"
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
    static let remainingLeaveLabel = "Kullanılan izin günü"
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
    
    // MARK: - Forgot Password
    static let forgotPasswordDescription = "Şifreni sıfırlamak için e-posta adresine doğrulama kodu göndereceğiz."
    static let codeAutoVerifyHint = "Kod tamamlandığında doğrulama otomatik başlar."
    
    // MARK: - Login
    static let loginDescription = "Hesabına giriş yaparak personel yönetimine devam et."
    static let loginCredentialsTitle = "Giriş Bilgileri"
    static let passwordPlaceholderShort = "123..."
    static let loginLoading = "Giriş yapılıyor..."
    
    // MARK: - Reset Password
    static let resetPasswordDescription = "Yeni şifreni belirleyerek hesabına tekrar giriş yapabilirsin."
    static let passwordInfoTitle = "Şifre bilgisi"
    static let passwordsMatchTitle = "Şifreler eşleşiyor"
    static let passwordsNotMatchTitle = "Şifreler eşleşmiyor"
    static let passwordInfoEmptyText = "Yeni şifreni iki alana da gir."
    static let passwordInfoMatchText = "Şifreni değiştirmek için onaylayabilirsin."
    static let passwordInfoNotMatchText = "Devam etmek için iki şifre alanı aynı olmalı."
    
    // MARK: - Signup
    static let signupDescription = "Önce hesabını oluştur, ardından şirket bilgilerini tamamla."
    static let accountInfoTitle = "Hesap Bilgileri"
    static let nextStepTitle = "Sonraki adım"
    static let signupNextStepDescription = "Kayıttan sonra şirket oluşturma ekranına yönlendirileceksin."
    static let registerLoading = "Kaydediliyor..."
    
    // MARK: - All Tables
    static let monthSortNewestFirst = "Yeni → Eski"
    static let monthSortOldestFirst = "Eski → Yeni"
    static let recentShiftCalendarsFormat = "Son %d ayın mesai takvimleri"
    static let shiftTablesLoading = "Mesai tabloları yükleniyor..."
    static let shiftTableNotFoundTitle = "Mesai tablosu bulunamadı"
    static let shiftTableNotFoundDescription = "Bu işletme için gösterilecek mesai kaydı yok."
    
    // MARK: - Home
    static let shiftActiveSubtitle = "Çalışma süren aktif"
    static let shiftNotStartedSubtitle = "Mesai başlatılmadı"
    static let monthlyShiftTrackingSubtitle = "Aylık mesai takibini görüntüle"
    static let weeklyActivityViewSubtitle = "Haftalık aktivite görünümü"
    static let activityCountFormat = "%d aktivite"
    static let noActivityForSelectedDay = "Bu gün için kayıtlı aktivite bulunmuyor."
    
    // MARK: - Shift Location
    static let shiftLocationDescription = "Mesaiye nereden başlayacağını seç."
    static let selectedLocationFormat = "Seçili konum: %@"
    static let noOfficeHomeHint = "Kayıtlı ofis yoksa evden çalışma seçeneğiyle başlayabilirsin."
    static let workFromHomeSubtitle = "Evden çalışma"
    static let officeLocationSubtitle = "Şirket/ofis konumu"
    
    // MARK: - Shift Month Grid
    static let monthlyShiftSummary = "Aylık mesai özeti"
    static let weekDaysVeryShort = ["P", "S", "Ç", "P", "C", "C", "P"]
    
    // MARK: - Create Company
    static let createCompanyDescription = "Şirket bilgilerini tamamlayarak işletmeni oluştur."
    static let companyInfoSectionTitle = "Şirket Bilgileri"
    static let officeInfoCountFormat = "%d ofis bilgisi"
    static let pickOfficeLocationFromMap = "Haritadan ofis konumu seç"
    static let locationInfoSectionTitle = "Konum Bilgileri"
    static let addressDetailSectionTitle = "Adres Detayı"
    static let companyCreatingLoading = "Şirket oluşturuluyor..."
    static let createButtonLoading = "Oluşturuluyor..."
    
    // MARK: - Email Verification
    static let verificationCodeTitle = "Doğrulama kodu"
    static let verificationCodeDescription = "E-postana gelen kodu gir."
    
    // MARK: - Map Picker
    static let mapSearchInstruction = "Bir adres, işletme veya konum adı yaz."
    static let mapSelectionInstruction = "Haritaya dokunarak veya arama yaparak konum seç."
    
    // MARK: - Onboarding
    static let appName = "Personelim"
    static let onboardingDescription = "Personel, vardiya, izin ve performans yönetimini tek yerden takip et."
    static let onboardingShiftPill = "Vardiya"
    static let onboardingLeavePill = "İzin"
    static let onboardingPerformancePill = "Performans"
    
    // MARK: - Add Employee
    static let addEmployeeDescription = "Çalışana davet bağlantısı göndermek için e-posta adresini gir."
    static let invitationSendingLoading = "Davet gönderiliyor..."
    static let sendButtonLoading = "Gönderiliyor..."
    
    // MARK: - Add Member
    static let addMemberDescription = "Departmana yeni personel ekle."
    static let positionSearchPlaceholder = "Pozisyon ara"
    static let selectedPositionText = "Seçili pozisyon"
    static let positionText = "Pozisyon"
    static let selectedPositionTitle = "Seçilen pozisyon"
    static let positionNotFoundTitle = "Pozisyon bulunamadı"
    static let positionNotFoundDescription = "Bu departman için pozisyon yoksa önce pozisyon oluşturman gerekir."
    
    // MARK: - Department Analytics
    static let departmentAnalyticsTitle = "Departman Analitiği"
    static let averageTitle = "Ortalama"
    static let highestTitle = "En Yüksek"
    static let lowestTitle = "En Düşük"
    static let selectDateTitle = "Tarih Seç"
    static let departmentDisplayLimitTitle = "Gösterilecek Departman"
    static let allOption = "Hepsi"
    static let emptyChartDataTitle = "Bu tarih aralığında grafik verisi yok"
    static let totalTitle = "Toplam"
    
    // MARK: - Department Charts

    static let metricScore = "Skor"
    static let metricOvertime = "Mesai (%)"
    static let metricTask = "Görev"
    static let metricProductivity = "Verimlilik"
    static let metricCompletion = "Tamamlanma"
    static let metricDifficultySuccess = "Zorluk Başarısı"
    static let metricEmployeeCount = "Çalışan Sayısı"
    static let metricOvertimeUsage = "Mesai Kullanımı"

    static let chartTypeBar = "Çubuk"
    static let chartTypeLine = "Çizgi"
    static let chartTypeHorizontalBar = "Yatay"
    static let chartTypePie = "Pasta"
    static let chartTypeDonut = "Donut"
    static let chartTypeArea = "Alan"
    
    // MARK: - Department Detail Performance
    static let departmentEmployeeCountFormat = "%d çalışan"
    static let departmentPerformanceQueryTitle = "Departman Performans Sorgulama"
    static let startDatePickerTitle = "Başlangıç Tarihi"
    static let endDatePickerTitle = "Bitiş Tarihi"
    static let queryPerformanceButton = "Performansı Sorgula"
    static let aiPerformanceAnalysisTitle = "AI Performans Analizi"
    static let generalPerformanceScoreTitle = "Genel Performans Skoru"
    static let activeEmployeeAnalyzedFormat = "%d Aktif Çalışan Analiz Edildi"
    static let reportSummaryTitle = "Rapor Özeti"
    static let detailedAnalysisReportTitle = "Detaylı Analiz Raporu"
    static let employeePeriodScoresTitle = "Çalışan Dönem Skorları"
    static let noEmployeeScoreForPeriod = "Bu dönemde kaydedilmiş çalışan skoru bulunamadı."
    static let scorePointFormat = "%.1f Puan"
    
    // MARK: - Department List
    static let departmentSearchPrompt = "Departman ara"
    static let departmentListedCountFormat = "%d departman listeleniyor"
    static let noDepartmentYetTitle = "Henüz departman yok"
    static let departmentSearchNoResultTitle = "Sonuç bulunamadı"
    static let noDepartmentYetDescription = "Yeni departman ekleyerek listeyi oluşturmaya başlayabilirsin."
    static let departmentSearchNoResultDescription = "Arama kriterini değiştirerek tekrar deneyebilirsin."
    static let dateRangeSectionTitle = "Tarih Aralığı"
    static let customDateTitle = "Özel Tarih"
    static let cancelAction = "Vazgeç"
    static let applyAction = "Uygula"
    static let sortAZ = "A-Z"
    static let sortZA = "Z-A"
    
    // MARK: - Edit Department
    static let categorySearchPlaceholder = "Kategori ara"
    static let selectedCategoryText = "Seçili kategori"
    static let departmentCategoryText = "Departman kategorisi"
    static let categoryNotFoundTitle = "Kategori bulunamadı"
    
    // MARK: - Performance Bulk Query
    
    static let bulkQueryLoading = "Sorgulanıyor..."
    static let selectEndDateInstruction = "Bitiş tarihini seç"
    static let selectStartDateInstruction = "Başlangıç tarihini seç"
    
    // MARK: - Performance Query
    static let createQueryButton = "Sorgu Oluştur"
    
    // MARK: - Performance Report Detail
    static let performanceReportTitle = "Performans Raporu"
    static let reportLoading = "Rapor yükleniyor..."
    static let reportLoadFailed = "Rapor yüklenemedi"
    static let performanceScoreFormat = "%d/100"
    
    // MARK: - Personnel Detail
    static let personnelDetailTitle = "Personel Detayı"
    static let personnelInfoTitle = "Personel Bilgileri"
    static let reportHistoryEmpty = "Rapor geçmişi bulunmuyor"
    static let reportListedCountFormat = "%d rapor listeleniyor"
    static let reportsLoading = "Raporlar yükleniyor..."
    static let personnelInfoLoading = "Personel bilgileri yükleniyor..."
    static let resumeValue = "Resume"
    
    // MARK: - Personnel Edit
    static let selectTitlePlaceholder = "Ünvan seç"
    static let titleSearchPlaceholder = "Ünvan ara"
    static let selectedTitleText = "Seçili ünvan"
    static let titleText = "Ünvan"
    static let selectedTitleTitle = "Seçilen ünvan"
    static let titlesLoading = "Ünvanlar yükleniyor..."
    static let titleNotFoundTitle = "Ünvan bulunamadı"
    static let titleNotFoundDescription = "Bu departman için tanımlı ünvan bulunamadı."
    static let dangerousActionTitle = "Tehlikeli İşlem"
    static let processingLoading = "İşlem yapılıyor..."
    static let saveChangesButton = "Değişiklikleri Kaydet"
    
    // MARK: - Personnel List
    static let personnelListedCountFormat = "%d personel listeleniyor"
    static let personnelLoading = "Personeller yükleniyor..."
    static let personnelNotFoundTitle = "Personel bulunamadı"
    static let personnelEmptyDescription = "Yeni personel ekleyerek listeyi oluşturmaya başlayabilirsin."
    
    // MARK: - Leave
    static let selectedDayTitle = "Seçilen gün"
    static let selectedDayCountFormat = "%d gün seçildi"
    static let characterCountFormat = "%d karakter"
    static let leaveCreateButton = "İzin Oluştur"
    
    // MARK: - Document Preview
    static let pdfPreviewSubtitle = "PDF belge önizlemesi"
    static let documentLoadingTitle = "Belge yükleniyor"
    static let pdfPreviewPreparing = "PDF önizlemesi hazırlanıyor."
    static let documentOpenFailed = "Belge açılamadı"
    static let unknownErrorShort = "Bilinmeyen hata"
    static let downloadedContentNotPDFFormat = "İndirilen içerik PDF değil.\nÖrnek yanıt:\n%@"
    static let notBinaryUTF8 = "binary/utf8 değil"
    static let pdfDocumentCreateFailed = "PDFDocument oluşturulamadı."
    
    // MARK: - Edit Company
    static let changeLogoButton = "Logo Değiştir"
    static let selectPDFDocument = "PDF belge seç"
    static let addOfficeButton = "Ofis Ekle"
    static let addressInfoSectionTitle = "Adres Bilgileri"
    
    // MARK: - Edit Personal Profile
    static let editProfileTitle = "Profili Düzenle"
    static let nameLabel = "İsim"
    static let surnameLabel = "Soyisim"
    static let selectPDFCV = "PDF CV seç"
    static let deleteAccountConfirmationTitle = "Hesabınızı silmek istiyor musunuz?"
    static let deleteAccountButton = "Hesabı Sil"
    static let changePhotoButton = "Fotoğraf Değiştir"
    static let scanButton = "Tara"
    static let uploadedFileTitle = "Yüklü Dosya"
    static let dangerousActionsTitle = "Tehlikeli İşlemler"
    
    // MARK: - ID Scanner
    static let cameraPermissionDenied = "Kamera izni verilmedi."
    static let cameraPermissionDisabled = "Kamera izni kapalı. Ayarlar > Gizlilik > Kamera bölümünden açabilirsin."
    static let idScannerTitle = "Kimlik Tara"
    static let idScannerSubtitle = "11 haneli TC otomatik algılanır"
    static let idScannerHint = "Kimliğini çerçeve içine hizala.\nTC numarası göründüğünde otomatik yakalanır."
    static let visionKitFallbackMessage = "VisionKit tarama başlatılamadı, OCR moduna geçiliyor."
    static let visionKitErrorFallbackMessage = "VisionKit hata verdi, OCR moduna geçiliyor."
    static let cameraStartFailed = "Kamera başlatılamadı."
    static let cameraOutputFailed = "Kamera çıktısı eklenemedi."
    static let ocrErrorFormat = "OCR hata: %@"
    static let ocrStartFailedFormat = "OCR başlatılamadı: %@"
    
    // MARK: - Leave Section
    static let leavesTitle = "İzinler"
    static let leavesSubtitle = "İzin durumunu ve kullanımını yönet"
    static let useLeaveButton = "İzin kullan"
    static let remainingUsedLeaveTitle = "Kullanılan izin"
    static let currentLeaveSummary = "Güncel izin özeti"
    
    static let performanceQueriesTitle = "Performans Sorguları"
    static let scoreDayFormat = "%d gün"
    
    // MARK: - Profile
    static let noPositionInfo = "Ünvan bilgisi yok"
    static let incomeFormat = "Gelir: %@"
    static let companyNoDescription = "Şirket açıklaması yok"
    static let mainOfficeTitle = "Ana Ofis"
    static let cityDistrictTitle = "İl / İlçe"
    static let noRegisteredOffice = "Kayıtlı ofis bulunmuyor"
    static let officeDefaultNameFormat = "Ofis %d"
    static let openInMap = "Haritada aç"
    static let noLocationInfo = "Konum bilgisi yok"
    static let noDocumentFound = "Belge bulunmuyor"
    static let previewText = "Önizle"
    static let profileLoading = "Profil bilgileri yükleniyor..."
    
    // MARK: - Slack Integration
    static let slackIntegrationSubtitle = "Slack bildirim bağlantılarını yönet"
    static let slackLoading = "Slack entegrasyonları yükleniyor..."
    static let slackEmptyDescription = "Yeni Slack webhook bağlantısı ekleyebilirsin."
    static let slackWebhookIntegrationSubtitle = "Slack webhook entegrasyonu"
    static let slackEditSubtitle = "Webhook bilgilerini düzenle."
    static let slackDetailSubtitle = "Entegrasyon detaylarını görüntüle."
    static let slackWebhookInfoTitle = "Webhook Bilgileri"
    static let processingText = "İşlem yapılıyor..."
    static let savingText = "Kaydediliyor..."
    static let saveButtonShort = "Kaydet"
    
    static let noAssigneeSelected = "Henüz kişi seçilmedi"
    static let assigneeSelectedCountFormat = "%d kişi seçildi"
    static let employeeSearchPlaceholder = "Çalışan ara"
    static let employeeNotFound = "Çalışan bulunamadı"
    static let searchRetryHint = "Arama kriterini değiştirerek tekrar deneyebilirsin."
    
    static let createActivityTitle = "Aktivite Oluştur"
    static let dateTitle = "Tarih"
    static let selectedDateTitle = "Seçilen Tarih"
  
    static let assignedPeopleTitle = "Atanan kişiler"
    static let activityCreatingText = "Oluşturuluyor..."
    static let activityTypeTaskDateRangeSubtitle = "Başlangıç ve bitiş tarihi seçilir"
    static let activityTypeSingleDateSubtitle = "Tek tarih seçilir"
    static let activityDetailTitle = "Aktivite Detayı"
    static let selectedStatusTitle = "Seçili Durum"
    
    static let feedbackNavTitle = "Geri Bildirim"
    static let levelFormat = "Seviye %d / 5"
   
    static let activeRecordCountFormat = "%d aktif kayıt"
    static let pastRecordCountFormat = "%d geçmiş kayıt"
    static let activitiesLoading = "Aktiviteler yükleniyor..."
    
    static let departmentTitle = "Departman"
    
    static let logoutButtonTitle = "Çıkış Yap"
    static let logoutButtonDescription = "Oturumu kapat ve giriş ekranına dön"
    static let logoutFailed = "Oturum kapatılamadı"
    
    static let loginRequiredFieldsError = "Email ve şifre zorunludur."
    
    static let signupRequiredFieldsError = "Tüm alanlar gereklidir."
    static let signupInvalidEmailError = "Geçerli bir email giriniz."
    static let signupPasswordMinLengthError = "Şifre en az 6 karakter olmalıdır."
    
    static let forgotPasswordEmailRequired = "Email gereklidir."
    static let resetCodeLengthError = "Kod 6 haneli olmalıdır."
    static let resetCodeInvalid = "Kod doğrulanamadı."
    static let resetCodeVerifyFailed = "Kod doğrulanırken bir hata oluştu."
    
    static let resetPasswordFieldsRequired = "Şifre alanları boş olamaz."
    static let resetPasswordMismatch = "Şifreler eşleşmiyor."
    static let resetPasswordFailed = "Şifre değiştirilemedi. Lütfen tekrar deneyin."
    
    static let provinceLoadFailed = "İller yüklenemedi."
    static let districtLoadFailed = "İlçeler yüklenemedi."
    static let companyNameRequired = "Şirket adı zorunludur."
    static let businessVerifyFailed = "Şirket doğrulanamadı."
    
    static let slackIntegrationLoadFailed = "Slack entegrasyonları yüklenemedi."
    static let slackIntegrationCreateFailed = "Slack entegrasyonu oluşturulamadı."
    static let slackIntegrationUpdateFailed = "Slack entegrasyonu güncellenemedi."
    
    static let premiumPlansLoadFailed = "Premium paketler yüklenemedi."
   
    static let profileImageLoadFailed = "Profil fotoğrafı yüklenemedi."
    
    static let titleRequiredError = "Lütfen bir ünvan seç."
    
    static let memberDeleteFail = "Personel silinemedi."
    
    static let reportsLoadFailed = "Raporlar yüklenemedi."
    
    static let departmentCreateFailed = "Departman oluşturulamadı."
    static let departmentUpdateFailed = "Departman güncellenemedi."
    static let departmentDeleteFailed = "Departman silinemedi."
    static let departmentPerformanceLoadFailed = "Departman performansı yüklenemedi."
    static let departmentChartsLoadFailed = "Departman grafikleri yüklenemedi."
    
    static let createActivityFailed = "Aktivite oluşturulamadı."
    
    static let feedbackRequiredError = "Lütfen geri bildirim giriniz."
    static let feedbackSaveFailed = "Geri bildirim kaydedilemedi."
    
    static let activityDeleteFailed = "Aktivite silinemedi."
    
    static let leaveFormValidationError = "Lütfen gerekli alanları doldurun."
    static let invalidDateRangeError = "Geçersiz tarih aralığı."
    static let leaveCreateFailed = "İzin talebi oluşturulamadı."
    
    static let officeCoordinateNotFound = "Ofis konumu bulunamadı."
    static let notCloseEnoughToOffice = "Seçilen ofise yeterince yakın değilsin."
    static let mustEndShiftAtSameOffice = "Mesaiyi aynı ofiste bitirmelisin."
    static let shiftStartFailed = "Mesai başlatılamadı."
    static let shiftEndFailed = "Mesai sonlandırılamadı."
    static let shiftEndWithoutStart = "Mesai başlatılmadan gün sonlandırılamaz."
    
    static let invitationSendFailed =
        "Davet gönderilemedi. Lütfen tekrar deneyin."
    
    static let memberAddFailed = "Personel eklenemedi."
    
    static let performanceReportCreateFailed =
        "Performans raporu oluşturulamadı."
    
    static let performanceReportLoadFailed =
        "Performans raporu yüklenemedi."
    
    static let performanceScoresLoadFailed = "Performans skorları yüklenemedi."
    
    static let sessionLoadFailed = "Oturum bilgileri yüklenemedi."
    
    static let shiftTablesLoadFailed = "Mesai tabloları yüklenemedi."
    
    static let documentPreviewLoadFailed = "Belge önizlemesi yüklenemedi."
    static let downloadedContentNotPDF = "İndirilen belge PDF formatında değil."
    
    static let documentSelectFailed = "Belge seçilemedi."
    static let companyUpdateFail = "Şirket bilgileri güncellenemedi."
    
    static let ocrReadFailed = "Kimlik numarası okunamadı."
    static let ocrStartFailed = "Kimlik tarama işlemi başlatılamadı."
    
   
    static let departmentPerformanceTitle = "Departman Performansı"
    static let departmentScoreTitle = "Departman Skoru"
    static let employeeCountTitle = "Çalışan Sayısı"
    static let taskCompletionRateTitle = "Tamamlanma Oranı"
    static let productivityTitle = "Verimlilik"
    static let workUsageTitle = "Mesai Kullanımı"
    static let taskDistributionTitle = "Görev Dağılımı"
    static let completedTaskTitle = "Tamamlanan"
    static let failedTaskTitle = "Tamamlanamayan"
    static let totalTaskTitle = "Toplam Görev"
    
    static let detailedReportTitle = "Detaylı Rapor"
    static let employeeScoresTitle = "Çalışan Skorları"
    static let createDepartmentReportButton = "Departman Raporu Oluştur"
    
    static let noDataText = "Veri bulunamadı."
    
    static let departmentPerformanceQueriesTitle = "Departman Performans Sorguları"
    static let departmentPerformanceQueryButton = "Sorgu"
    static let departmentPerformanceListedReportsFormat = "%d rapor listeleniyor"
    static let departmentPerformanceQueryRangeTitle = "Sorgu Aralığı"
    static let departmentPerformanceNoReportsText = "Henüz departman raporu bulunmuyor."
    static let departmentPerformanceLoadingReportsText = "Departman raporları yükleniyor..."
    static let departmentPerformanceReportsLoadFailed = "Departman raporları yüklenemedi."
    static let departmentPerformanceDetailLoadFailed = "Rapor detayı yüklenemedi."
    static let departmentPerformanceWeakStatus = "Zayıf"
    static let departmentPerformanceMediumStatus = "Orta"
    static let departmentPerformanceGoodStatus = "İyi"
    static let departmentPerformanceExcellentStatus = "Çok İyi"
    
  
    static let departmentReportDetailTitle = "Departman Raporu"
    static let departmentReportLoadFailed = "Departman raporu yüklenemedi."
    static let departmentReportLoading = "Departman raporu yükleniyor..."
    
    static let departmentPerformanceQueryInstruction = "Rapor oluşturmak istediğiniz tarih aralığını seçin."
    static let departmentPerformanceCreateReportButton = "Rapor Oluştur"
    static let cancelButtonTitle = "Vazgeç"
   
    static let departmentDetailTitle = "Departman Detayı"
    
    static let chatTitle = "Aqua"
    static let chatPlaceholder = "Bir şeyler yazın..."
    static let chatWelcomeTitle = "Hoş geldiniz"
    static let chatWelcomeSubtitle = "Size hangi konularda yardımcı olmamı istersiniz?"
    static let chatSendButton = "Gönder"
    static let chatLoadingText = "Yanıt hazırlanıyor..."
    static let chatConversationsTitle = "Sohbetler"
    static let chatDeleteTitle = "Sohbeti Sil"
    static let chatDeleteMessage = "Bu sohbeti silmek istediğinize emin misiniz?"
    
    static let chatSendFailed = "Mesaj gönderilemedi."
    static let chatConversationLoadFailed = "Sohbet yüklenemedi."
    static let chatDeleteFailed = "Sohbet silinemedi."
}
