import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.35), radius: 15)
            
            VStack(spacing: 12) {
                Text("IslandMac'e Hoş Geldiniz")
                    .font(.system(size: 28, weight: .bold))
                
                Text("macOS'ta verimliliği yeniden tanımlayın.\nDynamic Island, artık iş akışınızın kalbinde.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "video.fill", title: "Toplantı Akışı", description: "Toplantılarınızı kaçırmayın, tek tıkla katılın.")
                FeatureRow(icon: "timer", title: "Derin Odaklanma", description: "Pomodoro modları ile üretkenliğinizi zirveye çıkarın.")
                FeatureRow(icon: "iphone.gen3", title: "iPhone Entegrasyonu", description: "Telefon durumunuzu ve kopyaladığınız içerikleri anında görün.")
            }
            .padding(.top, 10)
            
            Spacer()
            
            Button(action: { showOnboarding = false }) {
                Text("Başlayalım")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
        .padding(40)
        .frame(width: 450, height: 600)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 32)
                
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
    }
}
