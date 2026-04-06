import SwiftUI
import EventKit
import Combine

struct IslandView: View {
    @Bindable var islandState: IslandState
    
    // Servisler
    @StateObject private var calendarService = CalendarService()
    @StateObject private var focusService = FocusService()
    @StateObject private var deviceService = DeviceSyncService()
    @StateObject private var noteService = NoteService()
    @StateObject private var continuityService = ContinuityService()
    @StateObject private var mediaService = MediaService()
    
    // UI Local States
    @State private var isHovering: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // PREMIUM GLASS BACKGROUND
                backgroundGlass
                
                // DYNAMIC CONTENT
                mainContent
            }
            .frame(width: dynamicWidth, height: dynamicHeight)
            .scaleEffect(isHovering && !islandState.isExpanded ? 1.04 : 1.0)
            .onHover { hovering in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isHovering = hovering
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                    islandState.isExpanded.toggle()
                }
            }
        }
        .padding(.top, 2)
    }
    
    // MARK: - Premium UI Components
    private var backgroundGlass: some View {
        RoundedRectangle(cornerRadius: islandState.isExpanded ? 40 : 22, style: .continuous)
            .fill(Color.black.opacity(0.85))
            .background(
                RoundedRectangle(cornerRadius: islandState.isExpanded ? 40 : 22, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .blur(radius: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: islandState.isExpanded ? 40 : 22, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(isHovering ? 0.8 : 0.5), radius: isHovering ? 40 : 25, x: 0, y: 15)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if islandState.isExpanded {
                expandedPanel.transition(.asymmetric(insertion: .push(from: .bottom).combined(with: .opacity), removal: .opacity))
            } else {
                collapsedView.transition(.opacity)
            }
        }
    }
    
    private var collapsedView: some View {
        HStack(spacing: 15) {
            if let media = mediaService.currentMedia {
                HStack(spacing: 8) {
                    Image(systemName: platformIcon(for: media.platform))
                        .foregroundColor(IslandColor.accentBlue).font(.system(size: 14))
                    Text(media.title).font(.system(size: 13, weight: .bold)).foregroundColor(.white).lineLimit(1)
                }
            } else if focusService.currentState == .work {
                HStack(spacing: 8) {
                    Image(systemName: "timer").foregroundColor(IslandColor.focusOrange).font(.system(size: 13))
                    Text(focusService.formatTime()).font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(.white)
                }
            } else {
                Text("IslandMac").font(.system(size: 13, weight: .black)).foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if let device = deviceService.linkediPhone {
                    Text("%\(Int(device.batteryLevel * 100))").font(.system(size: 11, weight: .bold)).foregroundColor(IslandColor.successGreen)
                    Image(systemName: device.isCharging ? "battery.100.bolt" : "battery.75").foregroundColor(IslandColor.successGreen).font(.system(size: 12))
                }
            }
        }
        .padding(.horizontal, 22)
    }
    
    private var expandedPanel: some View {
        HStack(spacing: 4) {
            // LEFT CARD: PRECISE MEDIA OR FOCUS
            ExpandedCard(title: mediaService.currentMedia != nil ? mediaService.currentMedia!.platform.rawValue : "FOCUS", 
                         icon: mediaService.currentMedia != nil ? platformIcon(for: mediaService.currentMedia!.platform) : "timer") {
                if let media = mediaService.currentMedia {
                    mediaContent(media)
                } else {
                    focusContent
                }
            }
            
            // RIGHT CARDS: SLIM STACKS
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    MiniCard(title: "AJANDA", icon: "calendar", value: calendarService.upcomingEvents.first?.title ?? "Boş", color: .white)
                    MiniCard(title: "CİHAZ", icon: "iphone", value: "%\(Int((deviceService.linkediPhone?.batteryLevel ?? 0) * 100))", color: IslandColor.successGreen)
                }
                HStack(spacing: 4) {
                    MiniCard(title: "PANO", icon: "doc.on.clipboard", value: continuityService.lastClipboardContent ?? "Empty", color: .gray)
                    MiniCard(title: "NOTLAR", icon: "note.text", value: "\(noteService.notes.count) Not", color: IslandColor.noteYellow)
                }
            }
        }
        .padding(12)
    }
    
    // MARK: - Subviews
    private func mediaContent(_ media: MediaInfo) -> some View {
        VStack(spacing: 10) {
            Text(media.title).font(.system(size: 16, weight: .black)).foregroundColor(.white).lineLimit(1)
            Text(media.artist).font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
            
            HStack(spacing: 30) {
                Button(action: { mediaService.togglePlayPause() }) {
                    Image(systemName: "backward.fill").font(.system(size: 16)).foregroundColor(.white.opacity(0.3))
                }.buttonStyle(.plain)
                
                Button(action: { mediaService.togglePlayPause() }) {
                    Image(systemName: media.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24)).foregroundColor(.white)
                }.buttonStyle(.plain)
                
                Button(action: { mediaService.togglePlayPause() }) {
                    Image(systemName: "forward.fill").font(.system(size: 16)).foregroundColor(.white.opacity(0.3))
                }.buttonStyle(.plain)
            }
            .padding(.top, 5)
        }
    }
    
    private var focusContent: some View {
        VStack(spacing: 8) {
            Text(focusService.formatTime()).font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(IslandColor.focusOrange)
                .shadow(color: IslandColor.focusOrange.opacity(0.4), radius: 10)
            
            HStack(spacing: 20) {
                Button(action: { focusService.startFocus(minutes: 25) }) {
                    Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundColor(.white.opacity(0.8))
                }.buttonStyle(.plain)
                
                Button(action: { focusService.startBreak(minutes: 5) }) {
                    Image(systemName: "cup.and.saucer.fill").font(.system(size: 20)).foregroundColor(.white.opacity(0.4))
                }.buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Dynamic Props
    private var dynamicWidth: CGFloat {
        if islandState.isExpanded { return 760 }
        return isHovering ? 280 : 240
    }
    
    private var dynamicHeight: CGFloat {
        if islandState.isExpanded { return 200 }
        return isHovering ? 52 : 46
    }
    
    private var borderColor: Color {
        if mediaService.currentMedia != nil { return IslandColor.accentBlue.opacity(0.6) }
        if focusService.currentState == .work { return IslandColor.focusOrange.opacity(0.6) }
        return isHovering ? .white.opacity(0.4) : .white.opacity(0.1)
    }
    
    private func platformIcon(for platform: MediaPlatform) -> String {
        switch platform {
        case .music: return "apple.logo"
        case .spotify: return "dot.radiowaves.left.and.right"
        case .youtube, .youtubeMusic: return "play.rectangle.fill"
        default: return "play.fill"
        }
    }
}

// MARK: - Premium Elements
struct ExpandedCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(.gray)
                Text(title).font(.system(size: 9, weight: .black)).foregroundColor(.gray).kerning(1.2)
            }
            Spacer()
            content
            Spacer()
        }
        .frame(width: 320)
        .padding(25)
        .background(Color.white.opacity(0.03))
        .cornerRadius(32)
    }
}

struct MiniCard: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 9)).foregroundColor(.gray)
                Text(title).font(.system(size: 8, weight: .bold)).foregroundColor(.gray)
            }
            Text(value).font(.system(size: 12, weight: .bold)).foregroundColor(color).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.white.opacity(0.04))
        .cornerRadius(24)
    }
}
