import SwiftUI
import EventKit

// MARK: - Ana IslandView

struct IslandView: View {
    @Bindable var islandState: IslandState

    // Servisler
    @StateObject private var calendarService   = CalendarService()
    @StateObject private var focusService      = FocusService()
    @StateObject private var deviceService     = DeviceSyncService()
    @StateObject private var noteService       = NoteService()
    @StateObject private var continuityService = ContinuityService()
    @StateObject private var mediaService      = MediaService()

    @State private var isHovering = false

    var body: some View {
        ZStack {
            backgroundLayer
            contentLayer
        }
        .frame(width: targetWidth, height: targetHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(borderOverlay)
        .shadow(color: shadowColor, radius: isHovering ? 36 : 22, x: 0, y: 12)
        .scaleEffect(isHovering && !islandState.isExpanded ? 1.03 : 1.0)
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: islandState.isExpanded)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isHovering)
        .onHover { hovering in
            withAnimation { isHovering = hovering }
        }
        .padding(.top, 2)
    }

    // MARK: - Arka Plan

    private var backgroundLayer: some View {
        ZStack {
            Color.black.opacity(0.88)
            LinearGradient(
                colors: [Color.white.opacity(0.07), Color.white.opacity(0.025)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: 1.1)
    }

    // MARK: - İçerik

    private var contentLayer: some View {
        Group {
            if islandState.isExpanded {
                expandedView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.97)),
                        removal:   .opacity.combined(with: .scale(scale: 0.97))
                    ))
            } else {
                collapsedBar
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Kompakt Çubuk

    private var collapsedBar: some View {
        HStack(spacing: 0) {
            leftStatusSection
                .frame(maxWidth: .infinity, alignment: .leading)

            if let media = mediaService.currentMedia, media.duration > 0 {
                progressPill(progress: media.progress)
                    .frame(width: 60)
                    .padding(.horizontal, 6)
            }

            rightStatusSection
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .onTapGesture {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                islandState.isExpanded = true
            }
        }
    }

    private var leftStatusSection: some View {
        HStack(spacing: 8) {
            if let media = mediaService.currentMedia {
                Circle()
                    .fill(media.platform.accentColor.opacity(0.22))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: media.platform.icon)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(media.platform.accentColor)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(media.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if !media.artist.isEmpty {
                        Text(media.artist)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            } else if focusService.currentState == .work {
                Image(systemName: "timer")
                    .font(.system(size: 12))
                    .foregroundColor(IslandColor.focusOrange)
                Text(focusService.formatTime())
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(IslandColor.focusOrange)
                    .shadow(color: IslandColor.focusOrange.opacity(0.5), radius: 6)
            } else if let event = calendarService.upcomingEvents.first {
                Image(systemName: "calendar")
                    .font(.system(size: 11))
                    .foregroundColor(IslandColor.accentBlue)
                Text(event.title ?? "Toplantı")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            } else {
                Text("IslandMac")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var rightStatusSection: some View {
        HStack(spacing: 10) {
            if let media = mediaService.currentMedia {
                Button(action: { mediaService.togglePlayPause() }) {
                    Image(systemName: media.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }

            if let device = deviceService.linkediPhone {
                HStack(spacing: 3) {
                    Image(systemName: device.isCharging ? "battery.100.bolt" : batteryIcon(device.batteryLevel))
                        .font(.system(size: 11))
                        .foregroundColor(batteryColor(device.batteryLevel))
                    Text("\(Int(device.batteryLevel * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(batteryColor(device.batteryLevel))
                }
            }
        }
    }

    private func progressPill(progress: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: geo.size.width * CGFloat(max(0, min(progress, 1))))
            }
        }
        .frame(height: 3)
    }

    // MARK: - Genişletilmiş Panel

    private var expandedView: some View {
        VStack(spacing: 0) {
            topBar

            tabBar

            TabView(selection: $islandState.activeTab) {
                MediaWidgetView(mediaService: mediaService)
                    .tag(IslandTab.media)

                MeetingWidgetView(calendarService: calendarService)
                    .tag(IslandTab.meetings)

                FocusWidgetView(focusService: focusService)
                    .tag(IslandTab.focus)

                TaskWidgetView()
                    .tag(IslandTab.tasks)

                NotesWidgetView(noteService: noteService)
                    .tag(IslandTab.notes)

                DeviceWidgetView(deviceService: deviceService, continuityService: continuityService)
                    .tag(IslandTab.device)
            }
            .tabViewStyle(.automatic)
            .frame(maxHeight: .infinity)
        }
        .overlay(alignment: .topTrailing) {
            closeButton
        }
    }

    private var topBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white.opacity(0.22))
            .frame(width: 36, height: 4)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }

    private var closeButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                islandState.isExpanded = false
            }
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 22, height: 22)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .padding(.trailing, 12)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(islandState.visibleTabs) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        islandState.activeTab = tab
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 10, weight: .semibold))
                        if islandState.activeTab == tab {
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, islandState.activeTab == tab ? 10 : 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(
                            islandState.activeTab == tab
                                ? tabAccentColor(tab).opacity(0.22)
                                : Color.clear
                        )
                    )
                    .foregroundColor(
                        islandState.activeTab == tab
                            ? tabAccentColor(tab)
                            : .white.opacity(0.4)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    // MARK: - Hesaplanan Özellikler

    private var targetWidth: CGFloat {
        islandState.isExpanded ? 780 : (isHovering ? 290 : 248)
    }

    private var targetHeight: CGFloat {
        islandState.isExpanded ? 240 : (isHovering ? 52 : 46)
    }

    private var cornerRadius: CGFloat {
        islandState.isExpanded ? 38 : 23
    }

    private var borderColor: Color {
        if let media = mediaService.currentMedia {
            return media.platform.accentColor.opacity(0.5)
        }
        if focusService.currentState == .work {
            return IslandColor.focusOrange.opacity(0.55)
        }
        return isHovering ? Color.white.opacity(0.35) : Color.white.opacity(0.08)
    }

    private var shadowColor: Color {
        if let media = mediaService.currentMedia {
            return media.platform.accentColor.opacity(0.3)
        }
        if focusService.currentState == .work {
            return IslandColor.focusOrange.opacity(0.35)
        }
        return Color.black.opacity(0.55)
    }

    private func tabAccentColor(_ tab: IslandTab) -> Color {
        switch tab {
        case .media:    return IslandColor.accentBlue
        case .meetings: return Color(hex: "BF5AF2")
        case .focus:    return IslandColor.focusOrange
        case .tasks:    return IslandColor.successGreen
        case .notes:    return IslandColor.noteYellow
        case .device:   return IslandColor.accentBlue
        }
    }

    private func batteryIcon(_ level: Double) -> String {
        switch level {
        case 0.75...:  return "battery.100"
        case 0.5...:   return "battery.75"
        case 0.25...:  return "battery.50"
        case 0.1...:   return "battery.25"
        default:       return "battery.0"
        }
    }

    private func batteryColor(_ level: Double) -> Color {
        if level > 0.4 { return IslandColor.successGreen }
        if level > 0.2 { return IslandColor.noteYellow }
        return Color(hex: "FF453A")
    }
}

// MARK: - Medya Widget

struct MediaWidgetView: View {
    @ObservedObject var mediaService: MediaService

    var body: some View {
        HStack(spacing: 16) {
            albumArtView
            trackInfoView
            controlsView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var albumArtView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(mediaService.currentMedia?.platform.accentColor.opacity(0.18)
                      ?? Color.white.opacity(0.08))
                .frame(width: 58, height: 58)

            if let art = mediaService.currentMedia?.albumArt {
                Image(nsImage: art)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Image(systemName: mediaService.currentMedia?.platform.icon ?? "music.note")
                    .font(.system(size: 24))
                    .foregroundColor(
                        mediaService.currentMedia?.platform.accentColor ?? .white.opacity(0.25)
                    )
            }
        }
    }

    private var trackInfoView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let media = mediaService.currentMedia {
                Text(media.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if !media.artist.isEmpty {
                    Text(media.artist)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }

                if media.duration > 0 {
                    VStack(spacing: 3) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 3)
                                Capsule()
                                    .fill(media.platform.accentColor)
                                    .frame(
                                        width: geo.size.width * CGFloat(max(0, min(media.progress, 1))),
                                        height: 3
                                    )
                            }
                        }
                        .frame(height: 3)

                        HStack {
                            Text(formatSeconds(media.elapsed))
                            Spacer()
                            Text(formatSeconds(media.duration))
                        }
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.white.opacity(0.35))
                    }
                }

                // Platform rozeti
                Text(media.platform.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(media.platform.accentColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(media.platform.accentColor.opacity(0.14))
                    .clipShape(Capsule())

            } else {
                Text("Şu an bir şey çalmıyor")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                Text("Spotify, Music veya Chrome'da\nbir şey çal")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.25))
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controlsView: some View {
        HStack(spacing: 16) {
            Button(action: { mediaService.skipPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(mediaService.currentMedia != nil ? 0.85 : 0.25))
            }
            .buttonStyle(.plain)
            .disabled(mediaService.currentMedia == nil)

            Button(action: { mediaService.togglePlayPause() }) {
                Image(systemName: mediaService.currentMedia?.isPlaying == true ? "pause.fill" : "play.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button(action: { mediaService.skipNext() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(mediaService.currentMedia != nil ? 0.85 : 0.25))
            }
            .buttonStyle(.plain)
            .disabled(mediaService.currentMedia == nil)
        }
        .padding(.trailing, 4)
    }

    private func formatSeconds(_ s: Double) -> String {
        let total = Int(s)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

// MARK: - Toplantı Widget

struct MeetingWidgetView: View {
    @ObservedObject var calendarService: CalendarService

    var body: some View {
        HStack(spacing: 14) {
            // Sol ikon
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "BF5AF2").opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: "video.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "BF5AF2"))
                }
                Text("\(calendarService.upcomingEvents.count)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                Text("toplantı")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.4))
            }

            // Sıradaki toplantı bilgisi
            if let event = calendarService.upcomingEvents.first {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SIRADAKI")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(hex: "BF5AF2").opacity(0.8))
                        .tracking(0.8)

                    Text(event.title ?? "Başlıksız Toplantı")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 10) {
                        Label(timeStr(event.startDate), systemImage: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))

                        if let cd = countdown(to: event.startDate) {
                            Text(cd)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "BF5AF2"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "BF5AF2").opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bugün toplantı yok")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Gün akışın temiz görünüyor")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func timeStr(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func countdown(to date: Date) -> String? {
        let diff = date.timeIntervalSinceNow
        if diff <= 0 { return "Devam ediyor" }
        if diff < 60 { return "Şimdi başlıyor!" }
        let m = Int(diff / 60)
        if m < 60 { return "\(m)dk sonra" }
        return "\(m/60)s \(m%60)dk sonra"
    }
}

// MARK: - Odak Widget

struct FocusWidgetView: View {
    @ObservedObject var focusService: FocusService

    var body: some View {
        HStack(spacing: 18) {
            // Dairesel zamanlayıcı
            ZStack {
                Circle()
                    .stroke(IslandColor.focusOrange.opacity(0.15), lineWidth: 5)
                    .frame(width: 78, height: 78)

                Circle()
                    .trim(from: 0, to: CGFloat(focusService.sessionProgress))
                    .stroke(
                        IslandColor.focusOrange,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 78, height: 78)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: focusService.sessionProgress)

                VStack(spacing: 0) {
                    Text(focusService.formatTime())
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundColor(IslandColor.focusOrange)
                    Text(focusService.currentState == .idle ? "Hazır" :
                         focusService.currentState == .work ? "Odak" : "Mola")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            // Kontrol ve istatistikler
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    FocusChipView(label: "25dk", color: IslandColor.focusOrange) {
                        focusService.startFocus(minutes: 25)
                    }
                    FocusChipView(label: "50dk", color: IslandColor.focusOrange) {
                        focusService.startFocus(minutes: 50)
                    }
                    FocusChipView(label: "Mola", color: IslandColor.successGreen) {
                        focusService.startBreak(minutes: 5)
                    }
                    if focusService.currentState != .idle {
                        FocusChipView(label: "Dur", color: Color(hex: "FF453A")) {
                            focusService.stop()
                        }
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(IslandColor.focusOrange)
                    Text("Bugün \(focusService.totalFocusMinutesToday) dk odak")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Görev Widget

struct TaskWidgetView: View {
    @State private var tasks: [SimpleTask] = [
        SimpleTask(title: "Müşteri sunumunu hazırla", isDone: false, priority: .high),
        SimpleTask(title: "Sprint review toplantısı", isDone: false, priority: .medium),
        SimpleTask(title: "Haftalık raporu gönder",   isDone: true,  priority: .low)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(tasks.filter { !$0.isDone }.count) bekliyor")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                Spacer()
                Text("\(tasks.filter { $0.isDone }.count) tamamlandı")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(IslandColor.successGreen)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 6)

            VStack(spacing: 2) {
                ForEach($tasks) { $task in
                    HStack(spacing: 10) {
                        Button { task.isDone.toggle() } label: {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundColor(task.isDone ? IslandColor.successGreen : .white.opacity(0.3))
                        }
                        .buttonStyle(.plain)

                        Text(task.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(task.isDone ? .white.opacity(0.3) : .white)
                            .strikethrough(task.isDone, color: .white.opacity(0.3))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Circle()
                            .fill(
                                task.priority == .high   ? Color(hex: "FF453A") :
                                task.priority == .medium ? IslandColor.focusOrange :
                                                           Color.white.opacity(0.15)
                            )
                            .frame(width: 7, height: 7)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

struct SimpleTask: Identifiable {
    let id   = UUID()
    var title: String
    var isDone: Bool
    var priority: Priority
    enum Priority { case high, medium, low }
}

// MARK: - Not Widget

struct NotesWidgetView: View {
    @ObservedObject var noteService: NoteService
    @State private var newNoteText = ""
    @SwiftUI.FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Hızlı giriş
            HStack(spacing: 8) {
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundColor(IslandColor.noteYellow)

                TextField("Hızlı not...", text: $newNoteText)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit { submitNote() }

                if !newNoteText.isEmpty {
                    Button(action: submitNote) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(IslandColor.noteYellow)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Son notlar
            VStack(spacing: 0) {
                ForEach(noteService.notes.prefix(4)) { note in
                    HStack(spacing: 8) {
                        if note.isFromiPhone {
                            Image(systemName: "iphone")
                                .font(.system(size: 9))
                                .foregroundColor(IslandColor.accentBlue)
                        }
                        Text(note.content)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(timeAgo(note.createdAt))
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                }
            }
            .padding(.top, 6)
        }
    }

    private func submitNote() {
        let trimmed = newNoteText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        noteService.addNote(trimmed)
        newNoteText = ""
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60 { return "şimdi" }
        if diff < 3600 { return "\(diff/60)dk" }
        return "\(diff/3600)s"
    }
}

// MARK: - Cihaz Widget

struct DeviceWidgetView: View {
    @ObservedObject var deviceService: DeviceSyncService
    @ObservedObject var continuityService: ContinuityService

    var body: some View {
        HStack(spacing: 14) {
            // iPhone görseli
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 46, height: 68)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    if let dev = deviceService.linkediPhone {
                        VStack(spacing: 3) {
                            Image(systemName: dev.isCharging ? "bolt.fill" : "iphone")
                                .font(.system(size: 15))
                                .foregroundColor(IslandColor.accentBlue)
                            Text("\(Int(dev.batteryLevel * 100))%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(IslandColor.successGreen)
                        }
                    } else {
                        Image(systemName: "iphone.slash")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.15))
                    }
                }

                Text(deviceService.linkediPhone?.name ?? "Yok")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.35))
                    .lineLimit(1)
                    .frame(width: 64)
            }

            // Bilgi satırları
            if let dev = deviceService.linkediPhone {
                VStack(alignment: .leading, spacing: 7) {
                    deviceRow(icon: "battery.75",        label: "Pil",      value: "\(Int(dev.batteryLevel * 100))%",  color: IslandColor.successGreen)
                    deviceRow(icon: "arrow.clockwise",   label: "Senkron",  value: syncText(dev.lastSync),              color: IslandColor.accentBlue)
                    deviceRow(icon: "dot.radiowaves.right", label: "Durum", value: "Bağlı",                             color: IslandColor.successGreen)

                    if let clip = continuityService.lastClipboardContent {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 9))
                                .foregroundColor(IslandColor.noteYellow)
                            Text(clip)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(IslandColor.noteYellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("iPhone bağlı değil")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Companion uygulamayı açın")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.25))
                    Button(action: { deviceService.startSync() }) {
                        Text("Bağlan")
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(IslandColor.accentBlue.opacity(0.2))
                            .foregroundColor(IslandColor.accentBlue)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func deviceRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 9)).foregroundColor(color)
            Text(label).font(.system(size: 10)).foregroundColor(.white.opacity(0.4))
            Spacer()
            Text(value).font(.system(size: 10, weight: .semibold)).foregroundColor(.white.opacity(0.75))
        }
    }

    private func syncText(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60 { return "Az önce" }
        return "\(diff/60)dk önce"
    }
}

// MARK: - Yardımcı Bileşenler

struct FocusChipView: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(color.opacity(0.16))
                .foregroundColor(color)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IslandView(islandState: IslandState())
        .frame(width: 780, height: 260)
        .background(Color.gray.opacity(0.15))
}
