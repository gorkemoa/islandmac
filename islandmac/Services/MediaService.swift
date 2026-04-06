import Foundation
import MediaPlayer
import Combine
import AppKit

struct MediaInfo: Equatable {
    var title: String
    var artist: String
    var albumArt: NSImage?
    var isPlaying: Bool
    var platform: MediaPlatform
    
    static func == (lhs: MediaInfo, rhs: MediaInfo) -> Bool {
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.isPlaying == rhs.isPlaying && lhs.platform == rhs.platform
    }
}

enum MediaPlatform: String {
    case music = "Apple Music"
    case spotify = "Spotify"
    case youtube = "YouTube"
    case youtubeMusic = "YouTube Music"
    case chrome = "Chrome"
    case unknown = "Sistem Medya"
}

class MediaService: ObservableObject {
    @Published var currentMedia: MediaInfo?
    private var timer: Timer?
    
    init() {
        setupUniversalMonitoring()
    }
    
    private func setupUniversalMonitoring() {
        // 1. Apple Music / iTunes (Distributed Notification)
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.Music.playbackStateChanged"), object: nil, queue: .main) { [weak self] _ in
            self?.refreshMedia()
        }
        
        // 2. Spotify
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"), object: nil, queue: .main) { [weak self] _ in
            self?.refreshMedia()
        }
        
        // 3. Periyodik Kontrol (Saniyede 1)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshMedia()
        }
    }
    
    private func refreshMedia() {
        // Control Center (Sağ üstteki alan) bu veriyi AppleScript yerine 
        // MediaPlayer framework üzerinden çeker. 
        // Sandbox içinden erişim için 'MPNowPlayingInfoCenter'ı direkt deniyoruz:
        
        // --- ADIM 1: APPLE MUSIC (MUSIC.APP) ---
        if let music = fetchFromAppleScript(appName: "Music", platform: .music) {
            updateMedia(music); return
        }
        
        // --- ADIM 2: SPOTIFY (SPOTIFY.APP) ---
        if let spotify = fetchFromAppleScript(appName: "Spotify", platform: .spotify) {
            updateMedia(spotify); return
        }
        
        // --- ADIM 3: CHROME / YOUTUBE ---
        fetchChromeInfo { [weak self] track in
            if let t = track {
                self?.updateMedia(t)
            } else {
                self?.updateMedia(nil)
            }
        }
    }
    
    private func updateMedia(_ info: MediaInfo?) {
        DispatchQueue.main.async {
            if self.currentMedia != info {
                self.currentMedia = info
            }
        }
    }
    
    private func fetchFromAppleScript(appName: String, platform: MediaPlatform) -> MediaInfo? {
        let scriptSource = "if application \"\(appName)\" is running then tell application \"\(appName)\" to get {name of current track, artist of current track, player state as string}"
        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            let result = script.executeAndReturnError(&error)
            if result.numberOfItems >= 3 {
                if let t = result.atIndex(1)?.stringValue, let a = result.atIndex(2)?.stringValue {
                    let s = result.atIndex(3)?.stringValue ?? ""
                    let isPlaying = (s == "playing" || s == "kPSP")
                    return MediaInfo(title: t, artist: a, albumArt: nil, isPlaying: isPlaying, platform: platform)
                }
            }
        }
        return nil
    }
    
    private func fetchChromeInfo(completion: @escaping (MediaInfo?) -> Void) {
        let scriptSource = "if application \"Google Chrome\" is running then tell application \"Google Chrome\" to get title of every tab of every window"
        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            let result = script.executeAndReturnError(&error)
            if let allTitles = result.stringValue {
                if allTitles.contains("YouTube") {
                    // YouTube Music veya YouTube başlığını bulalım
                    let titles = allTitles.components(separatedBy: ", ")
                    if let ytTitle = titles.first(where: { $0.contains("YouTube") }) {
                        let clean = ytTitle.replacingOccurrences(of: " - YouTube Music", with: "")
                                           .replacingOccurrences(of: " - YouTube", with: "")
                        completion(MediaInfo(title: clean, artist: "YouTube", albumArt: nil, isPlaying: true, platform: .youtube))
                        return
                    }
                }
            }
        }
        completion(nil)
    }
    
    func togglePlayPause() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let key: UInt16 = 16 
        let d = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true); d?.post(tap: .cghidEventTap)
        let u = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false); u?.post(tap: .cghidEventTap)
    }
}
