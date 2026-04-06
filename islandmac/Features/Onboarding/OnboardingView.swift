import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appModel: AppModel
    @State private var selectedModules: Set<IslandModule> = Set(IslandModule.allCases)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "060816"), Color(hex: "10172D"), Color(hex: "1B1035")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("IslandMac")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))

                    Text("Üst çubuk değil,\niş akışı merkezi.")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Medya, toplantı, odak, görev, not ve iPhone köprüsünü tek yüzeyde toplayan dinamik ada. İlk kurulumu bitir, uygulama geri kalanını canlı veriyle yönetsin.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.68))
                        .frame(maxWidth: 520, alignment: .leading)
                }

                HStack(spacing: 18) {
                    onboardingCard(
                        icon: "music.note.tv",
                        title: "Canlı medya",
                        description: "Spotify, Apple Music ve Chrome sekmeleri otomatik algılanır."
                    )
                    onboardingCard(
                        icon: "calendar.badge.clock",
                        title: "Takvim farkındalığı",
                        description: "Sıradaki toplantı, boş pencere ve günlük yoğunluk sürekli güncellenir."
                    )
                    onboardingCard(
                        icon: "iphone.gen3.radiowaves.left.and.right",
                        title: "Companion hattı",
                        description: "iPhone ya da harici istemci bağlandığında üst alan anında senkron olur."
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Başlangıçta açık modüller")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    LazyVGrid(columns: [.init(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                        ForEach(IslandModule.allCases) { module in
                            Button {
                                if selectedModules.contains(module) {
                                    selectedModules.remove(module)
                                } else {
                                    selectedModules.insert(module)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: module.icon)
                                    Text(module.title)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(selectedModules.contains(module) ? .white.opacity(0.16) : .white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(.white.opacity(selectedModules.contains(module) ? 0.25 : 0.08), lineWidth: 1)
                                )
                                .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Takvim izni ve Automation erişimi ilk kullanımla birlikte istenir.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.58))
                        Text("Sahte örnek veri yüklenmez. Ada yalnızca gerçek zamanlı veya kullanıcının girdiği veriyi gösterir.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.44))
                    }

                    Spacer()

                    Button("Kurulumu Tamamla") {
                        let ordered = IslandModule.allCases.filter { selectedModules.contains($0) }
                        appModel.islandState.visibleModules = ordered.isEmpty ? [.overview] : ordered
                        appModel.islandState.compactAccentModule = ordered.first ?? .overview
                        appModel.islandState.completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(36)
        }
        .frame(minWidth: 700, minHeight: 720)
    }

    private func onboardingCard(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
