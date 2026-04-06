# PROJE ANA TALİMAT DOSYASI
# macOS Premium Dynamic Island Benzeri İş ve Verimlilik Merkezi
# Copilot / Antigravity için Uygulama Geliştirme Promptu
# BU DOSYADAKİ TÜM KURALLAR ZORUNLUDUR

---

## 1. TEMEL AMAÇ

macOS üzerinde, ekranın üst orta alanında çalışan, Dynamic Island hissi veren, premium görünümlü, yüksek performanslı, iş insanlarına ve yoğun üretkenlik kullanan profesyonellere yönelik bir uygulama geliştir.

Bu uygulama:
- oyuncak demo olmayacak
- sadece görsel efekt uygulaması olmayacak
- gerçek iş akışına katkı sağlayacak
- kullanıcının kendi iPhone’u ile entegre çalışacak
- profesyonel kullanım senaryolarına uygun widget’lar içerecek
- modern, premium, hızlı ve güvenilir olacak
- App Store mantığına uygun, mümkün olduğunca güvenli ve sürdürülebilir teknolojilerle geliştirilecek
- private API kullanmayacak
- sistemin gerçek Dynamic Island alanını hacklemeye çalışmayacak

Amaç:
macOS’ta üst alanda yaşayan, toplantılar, görevler, telefon senkronizasyonu, hızlı durum takibi, odak modu, takvim, hızlı not, cihaz sürekliliği, akıllı kısa aksiyonlar ve iPhone bağlantısı ile çalışan bir “iş komuta merkezi” üretmek.

---

## 2. ÜRÜN VİZYONU

Bu ürün bir “üst çubuk uygulaması” değildir.
Bu ürün bir “iş verimliliği merkezi”dir.

Şöyle hissettirmeli:
- Apple kalitesinde sade ve rafine
- premium ve kurumsal
- hızlı ve akıcı
- dikkat dağıtmayan
- minimal ama güçlü
- kullanıcıyı yormayan
- her şey tek bakışta anlaşılır
- gereksiz karmaşa yok
- düşük kaynak tüketimi
- yüksek stabilite

Bu ürün şu hissi vermeli:
- “Bu uygulama boş efekt yapmıyor, gerçekten iş görüyor.”
- “Her gün açıp kullanmak istiyorum.”
- “Telefonum ve Mac’im arasında akıcı bir köprü kuruyor.”
- “Yönetici, kurucu, freelancer, satışçı, recruiter, geliştirici ve öğrenci için değer üretiyor.”

---

## 3. HEDEF KULLANICI KİTLESİ

Ana hedef kitle:
- girişimciler
- yöneticiler
- freelancer’lar
- danışmanlar
- recruiter’lar
- satış ekipleri
- ajans sahipleri
- uzaktan çalışan profesyoneller
- geliştiriciler
- tasarımcılar
- yoğun takvim kullanan öğrenciler

Bu kişilerin ortak ihtiyaçları:
- toplantıları kaçırmamak
- gün akışını tek yerde görmek
- odak süresini yönetmek
- hızlı not almak
- Mac ile iPhone arasında bilgi akışı sağlamak
- cihaz değiştirmeden durumu görmek
- küçük ama güçlü aksiyonlar almak
- pencereler arasında boğulmamak

---

## 4. ZORUNLU GELİŞTİRME DİLİ VE CEVAP DİLİ

Bu proje boyunca:
- tüm açıklamalar Türkçe olacak
- tüm yorumlar mümkün olduğunca Türkçe olacak
- ajan kullanıcıya Türkçe cevap verecek
- üretilen README, teknik açıklamalar, görev listeleri, yapılacaklar, notlar ve çıktı metinleri Türkçe olacak
- değişken ve fonksiyon isimleri İngilizce olabilir, fakat açıklama dili Türkçe olacak
- commit açıklamaları da tercihen Türkçe üretilecek

Ajan asla İngilizce uzun açıklama moduna geçmesin.
Varsayılan dil her zaman Türkçe olsun.

---

## 5. TEKNOLOJİ KARARI

Bu projede kullanılacak ana teknoloji:

### macOS uygulaması:
- Swift
- SwiftUI
- gerektiği yerde AppKit
- Combine veya Swift Concurrency
- Observation / modern state yönetimi
- MenuBarExtra gerekiyorsa destek amaçlı kullanılabilir
- üst alanda özel pencere / panel mimarisi kurulabilir
- performans kritik yerlerde AppKit tercih edilebilir

### iPhone companion uygulaması:
- Swift
- SwiftUI
- aynı tasarım dili
- güvenilir senkronizasyon
- kullanıcının kendi cihazı ile bağlantı

### Ortak katman:
- Shared models
- ortak veri yapıları
- güvenli senkronizasyon protokolü
- açık ve modüler mimari

### İzin verilen Apple teknolojileri:
- Handoff
- Universal Links
- App Groups uygun yerde
- CloudKit uygun senaryoda
- UserDefaults / Keychain / local persistence
- Push gerekiyorsa güvenli tasarım
- Widget mantığı uygunsa resmi Apple çerçeveleri
- Network katmanı düzgün soyutlanmış olacak

### Yasaklar:
- private API yok
- sistem alanını yasa dışı hacklemek yok
- rastgele kırılgan çözümler yok
- geçici ve kötü mimarili “sonra düzeltiriz” yaklaşımı yok

---

## 6. ÜRÜNÜN ANA ÖZELLİĞİ

macOS üzerinde ekranın üst orta alanında, notch çevresine veya notch olmayan cihazlarda estetik şekilde merkezlenmiş yaşayan bir akıllı ada / iş paneli geliştir.

Bu yapı:
- pasif görünümde kompakt olacak
- gerektiğinde akıcı şekilde genişleyecek
- hover, click, keyboard shortcut ve bağlama göre durum değiştirecek
- mini widget’lar gösterecek
- gün akışını ve kritik bilgileri tek noktada sunacak
- iPhone ile veri paylaşımı yapabilecek
- gerektiğinde derin ekrana geçiş yapmadan mini aksiyon sunacak

---

## 7. PREMİUM WIDGET SİSTEMİ

Uygulama boş süs değil, güçlü widget sistemi ile çalışmalı.

Aşağıdaki widget’lar mutlaka düşünülmeli ve uygulanmalı:

### 7.1 Bugünün Akışı Widget’ı
Gösterilecekler:
- bugünkü toplantı sayısı
- sıradaki toplantı
- boş zaman aralığı
- günün kritik görevi
- kalan odak bloğu

Hızlı aksiyonlar:
- toplantıya hazırlan
- toplantı notu aç
- rahatsız etme moduna geç
- görev görünümünü aç

---

### 7.2 Toplantı Widget’ı
Özellikler:
- sıradaki toplantı geri sayımı
- toplantı başlığı
- saat
- platform rozeti
- katılımcı sayısı
- toplantı notu alanı
- toplantıya geç kalma uyarısı
- toplantı öncesi hazırlanılacak maddeler

Hızlı aksiyonlar:
- bağlantıyı aç
- not aç
- toplantı moduna geç
- süre takibini başlat

---

### 7.3 Odak / Focus Widget’ı
Özellikler:
- pomodoro / derin çalışma
- odak başlangıç ve bitiş süresi
- bugünkü toplam odak süresi
- dikkat dağıtıcıları susturma
- odak modunda sadeleşmiş görünüm

Hızlı aksiyonlar:
- 25 dk başlat
- 50 dk başlat
- mola başlat
- tüm bildirimleri sadeleştir

---

### 7.4 Görev ve Öncelik Widget’ı
Özellikler:
- en kritik 3 görev
- bugüne ait kalan görevler
- tamamlanan görev sayısı
- geciken görev uyarısı
- tek tıkla tamamla
- öncelik değiştir

Hedef:
kullanıcı tam uygulamaya girmeden görev akışını yönetebilsin.

---

### 7.5 Hızlı Not Widget’ı
Özellikler:
- tek satır hızlı not
- toplantı notu
- telefonla paylaşılan notu gösterme
- panoya kopyala
- sabitleme
- son notlar

iPhone entegrasyonu:
- iPhone’dan gönderilen not burada görünebilmeli
- Mac’te yazılan not iPhone companion app içinde görülebilmeli

---

### 7.6 iPhone Durum Widget’ı
Bu proje için çok önemli.

Kullanıcının kendi iPhone’u ile bağlantılı çalışacak özel alan:
- iPhone pil seviyesi
- şarj durumu
- bağlantı durumu
- son senkronizasyon zamanı
- iPhone odak modu bilgisi
- iPhone sessiz mod / rahatsız etmeyin durumu mümkün olan resmi çerçeveler kapsamında
- iPhone’dan gelen seçilmiş olaylar

Amaç:
kullanıcı Mac üst alanından telefon durumunu anlayabilsin.

---

### 7.7 Cihazlar Arası Devamlılık Widget’ı
Özellikler:
- iPhone’da kopyalanan not / link / görev
- Mac’te devam et
- son açılan iş bağlantıları
- devam eden iş akışı
- “telefonda başlattım, Mac’te devam ediyorum” mantığı

Buna çok önem ver.
Bu ürünün en premium farklarından biri bu olmalı.

---

### 7.8 Takvim ve Zaman Boşluğu Widget’ı
Özellikler:
- sıradaki boş zaman dilimi
- günün yoğunluk seviyesi
- öğleden sonra uygun slot
- hızlı toplantı ekleme
- 15 dk / 30 dk / 1 saat bloklama

---

### 7.9 Hızlı İletişim Widget’ı
Özellikler:
- sık iletişim kurulan kişiler
- son konuşulan kişiler
- tek tıkla kısa not / toplantı planı / hatırlatma
- business kullanıma uygun sade iletişim aksiyonları

---

### 7.10 Gün Sonu Özeti Widget’ı
Özellikler:
- bugün tamamlanan görevler
- toplam odak süresi
- kaç toplantı yapıldı
- cevaplanmayan notlar
- ertesi gün için önerilen hazırlık

Bu alan ürünün premium hissini çok artırır.

---

## 8. iPHONE ENTEGRASYONU

Bu proje sıradan macOS paneli olmayacak.
Kullanıcının kendi iPhone’u ile entegre çalışan güçlü bir yapı olacak.

Aşağıdaki mimari düşünülmeli:

### 8.1 Companion iPhone Uygulaması
iPhone tarafında ayrı bir companion app geliştir.

Amaçları:
- cihaz kimliği ve kullanıcı bağlama
- telefon durumu paylaşımı
- hızlı not gönderme
- görev / odak / toplantı bağlamı paylaşma
- cihazlar arası süreklilik
- premium senkronizasyon deneyimi

### 8.2 Senkronize Edilecek Veri Türleri
- hızlı notlar
- odak durumu
- seçili görevler
- toplantı hazırlık notları
- iPhone pil ve bağlantı durumu
- son aktif iş içeriği
- favori kısa aksiyonlar
- kullanıcı tercihleri
- tema ve davranış tercihleri

### 8.3 Senkronizasyon İlkeleri
- hızlı olacak
- güvenilir olacak
- veri kaybı olmayacak
- çevrimdışı toleranslı olacak
- state çakışmalarını yönetecek
- açık log yapısı olacak
- modüler servis katmanında ilerleyecek

### 8.4 Gizlilik ve Güvenlik
- minimum veri toplansın
- gereksiz izin isteme
- cihaz içi saklama öncelikli olsun
- Keychain uygun yerde kullanılsın
- kullanıcı verisi şeffaf şekilde işlensin
- debug logları hassas veri sızdırmasın

---

## 9. TASARIM DİLİ

Tasarım şu özellikleri taşımalı:
- Apple tarzı premium sadelik
- yarı saydam, kaliteli, modern yüzeyler
- hafif cam etkisi olabilir ama abartılmayacak
- çok iyi boşluk kullanımı
- yumuşak ama profesyonel animasyon
- karanlık mod öncelikli ama açık mod da kusursuz
- dikkat dağıtmayan, odaklı renk sistemi
- kurumsal ve pahalı his
- çocuk oyuncağı gibi görünmeyecek
- ikonlar net ve minimal olacak
- bilgi yoğunluğu akıllıca yönetilecek

### Tasarım hataları kesinlikle yapılmayacak:
- fazla renk
- ucuz gradient kullanımı
- aşırı parlak efekt
- gereksiz bounce animasyonları
- okunmayan küçük yazılar
- aşırı sıkışık widget düzeni
- her yere border koymak
- amatör görünüm

---

## 10. EKRAN VE DAVRANIŞ KURGUSU

### 10.1 Durumlar
Uygulama şu durumlara sahip olabilir:
- kapalı / pasif görünüm
- mini görünüm
- genişletilmiş görünüm
- bağlamsal görünüm
- tam detay paneli
- focus görünümü
- toplantı görünümü
- hızlı not görünümü

### 10.2 Tetikleyiciler
Durum değişimleri şu yollarla olabilir:
- hover
- click
- keyboard shortcut
- toplantı yaklaşması
- odak modu başlaması
- iPhone’dan olay gelmesi
- kullanıcının widget sabitlemesi

### 10.3 Davranış Kuralları
- kullanıcıyı rahatsız etmemeli
- gereksiz yere açılıp kapanmamalı
- kararlı davranmalı
- animasyonlar çok hızlı ama şık olmalı
- CPU ve RAM tüketimi düşük tutulmalı
- pencere yönetimi kusursuz olmalı
- notch olmayan cihazlarda da şık görünmeli

---

## 11. MİMARİ KURALLAR

Kod mimarisi temiz, ölçeklenebilir ve sürdürülebilir olacak.

### Zorunlu katmanlar:
- App
- Core
- DesignSystem
- Features
- Services
- SharedModels
- Sync
- Persistence
- Presentation
- Utilities

### Feature bazlı yapı önerisi:
- Features/Island
- Features/Meetings
- Features/Tasks
- Features/Focus
- Features/Notes
- Features/Devices
- Features/Settings
- Features/Onboarding

### Servis katmanı:
- CalendarService
- TaskService
- NoteService
- FocusService
- DeviceSyncService
- ConnectivityService
- WindowPositionService
- IslandStateService
- PermissionsService
- AnalyticsService
- LoggingService

### Kurallar:
- View içine ağır iş mantığı gömme
- servisleri soyutla
- test edilebilir yapı kur
- bağımlılıkları kontrol altında tut
- global karmaşayı önle
- tek sorumluluk prensibine uy
- her modül açık görev tanımına sahip olsun

---

## 12. PERFORMANS KURALLARI

Bu proje performans canavarı olacak.

Zorunlu performans hedefleri:
- açılış hızlı olacak
- UI thread bloklanmayacak
- gereksiz render yok
- state güncellemeleri kontrollü olacak
- animasyonlar akıcı olacak
- idle durumda kaynak tüketimi çok düşük olacak
- sürekli polling varsa minimum maliyetli olacak
- gereksiz memory retention olmayacak
- data flow net olacak
- widget sayısı artsa bile yapı bozulmayacak

Özellikle dikkat:
- üst alanda yaşayan uygulamalar kullanıcıyı hemen bıktırır
- bu nedenle CPU tüketimi, memory kullanımı, redraw sayısı ve animasyon maliyeti dikkatle optimize edilmeli

Ajan, her aşamada performans açısından karar vermeli.

---

## 13. HATA TOLERANSI VE KALİTE

Uygulama şu senaryolarda düzgün davranmalı:
- iPhone bağlı değilse
- senkronizasyon gecikirse
- takvim verisi gelmezse
- görev kaynağı boşsa
- izin verilmemişse
- internet yoksa
- kullanıcı notch olmayan cihazdaysa
- dark/light geçişinde
- sleep/wake sonrasında
- çoklu monitör kullanımında

Asla çökme odaklı mimari kurma.
Her şey kontrollü fallback ile ilerlesin.

---

## 14. ONBOARDING

Kullanıcı ilk açılışta kafası karışmayacak.

Onboarding akışı:
1. Hoş geldin ekranı
2. Uygulamanın ne işe yaradığı
3. iPhone companion bağlantısı
4. Gerekli izinler
5. Hangi widget’ları istediği
6. görünüm tercihi
7. başlangıç kısayolları
8. ilk kullanım rehberi

Amaç:
ilk 2 dakika içinde kullanıcı değer görsün.

---

## 15. AYARLAR EKRANI

Ayarlar ekranı çok güçlü ama sade olmalı.

İçermesi gerekenler:
- tema ayarı
- widget görünürlük seçimi
- animasyon yoğunluğu
- klavye kısayolları
- iPhone bağlantı durumu
- senkronizasyon tercihleri
- bildirim tercihleri
- toplantı davranışları
- odak davranışları
- gizlilik seçenekleri
- veri temizleme
- debug modu
- log görüntüleme

---

## 16. KOD YAZIM KURALLARI

Ajan aşağıdaki kurallara sıkı sıkıya uysun:

- eksik dosya bırakma
- yarım iş yapma
- mock ile sonsuza kadar kalma
- geçici çözümleri üretim çözümü gibi sunma
- açıklamasız büyük karar verme
- dosya organizasyonunu bozma
- aynı işi yapan kopya servisler yazma
- View içinde networking yapma
- gereksiz singleton kullanma
- magic number kullanma
- anlamsız isimlendirme yapma
- TODO çöplüğü bırakma

Kod:
- temiz
- okunaklı
- modüler
- genişletilebilir
- test edilebilir
- üretim mantığına uygun olacak

---

## 17. GELİŞTİRME ŞEKLİ

Ajan işi tek seferde karmakarışık yapmasın.
Aşağıdaki sırayla ilerlesin:

Ajan her faz sonunda kısa Türkçe özet sunsun.

---

## 18. DOSYA ÇIKTISI BEKLENTİSİ

Ajan aşağıdakileri düzenli üretmeli:
- doğru klasör yapısı
- tüm temel dosyalar
- çalışır başlangıç yapısı
- açık servis katmanı
- reusable component’lar
- temiz state akışı
- örnek ama mantıklı veri modelleri
- açıklamalı ama gereksiz uzun olmayan dosyalar
- Türkçe teknik notlar

---

## 19. TEST STRATEJİSİ

Aşağıdaki test alanları düşünülmeli:
- state yönetimi
- senkronizasyon mantığı
- bağlantı kopması
- widget durum değişimleri
- toplantı zamanlayıcıları
- odak süresi mantığı
- veri kaybı senaryosu
- pencere davranışı
- çoklu ekran davranışı
- sleep/wake sonrası toparlanma

Minimum hedef:
kritik iş mantıkları test edilebilir şekilde yazılsın.

---

## 20. BAŞARI KRİTERLERİ

Bu proje ancak şu şartlarda başarılı kabul edilir:

- gerçekten premium görünmeli
- gerçekten hızlı çalışmalı
- gerçekten business kullanıcı için anlamlı olmalı
- iPhone entegrasyonu göstermelik olmamalı
- widget’lar işe yarar olmalı
- üst alan deneyimi doğal hissettirmeli
- kod tabanı düzenli ve sürdürülebilir olmalı
- her şey düzenli klasörlenmiş olmalı
- kullanıcı 1 gün sonra silmek istememeli
- uygulama günlük kullanımda değer üretmeli

---

## 21. AJANIN ÇALIŞMA BİÇİMİ

Ajan her zaman:
- Türkçe cevap versin
- ne yaptığını kısa ve net anlatsın
- dosya dosya ilerlesin
- kritik mimari kararları kısa gerekçeyle açıklasın
- eksik kalan yerleri net yazsın
- bozuk / yarım kod bırakmasın
- temiz ve düzenli ilerlesin

Ajan asla:
- gereksiz İngilizce açıklama üretmesin
- kullanıcıyı kafa karışıklığına sürüklemesin
- ne yaptığını saklamasın
- büyük parçaları açıklamasız yapıştırmasın

---
