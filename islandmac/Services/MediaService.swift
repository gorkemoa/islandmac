import Foundation
import AppKit
import SwiftUI

struct MediaInfo {
    var title: String
    var artist: String
    var albumArt: NSImage?
    var isPlaying: Bool
    var progress: Double
    var duration: Double
    var elapsed: Double
    var platform: MediaPlatform
    var artworkURL: URL?
    var sourceApplication: String
}

enum MediaPlatform: String {
    case music = "Apple Music"
    case spotify = "Spotify"
    case youtube = "YouTube"
    case youtubeMusic = "YouTube Music"
    case spotifyWeb = "Spotify Web"
    case soundcloud = "SoundCloud"
    case unknown = "Sistem Medyası"

    var icon: String {
        switch self {
        case .music: return "music.note"
        case .spotify, .spotifyWeb: return "dot.radiowaves.left.and.right"
        case .youtube: return "play.rectangle.fill"
        case .youtubeMusic: return "music.note.list"
        case .soundcloud: return "waveform"
        case .unknown: return "play.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .music: return Color(hex: "FA3C55")
        case .spotify, .spotifyWeb: return Color(hex: "1ED760")
        case .youtube: return Color(hex: "FF2D55")
        case .youtubeMusic: return Color(hex: "FF375F")
        case .soundcloud: return Color(hex: "FF7A00")
        case .unknown: return Color.white
        }
    }
}

final class MediaService: ObservableObject {
    @Published private(set) var currentMedia: MediaInfo?
    @Published private(set) var lastRefreshDate: Date?

    private var refreshTimer: Timer?
    private let scriptQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        queue.name = "com.islandmac.media"
        return queue
    }()
    private let artworkQueue = DispatchQueue(label: "com.islandmac.media.artwork", qos: .utility)
    private var artworkCache: [String: NSImage] = [:]
    private var lastPlatform: MediaPlatform?

    init() {
        observePlayerNotifications()
        startPolling()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    func togglePlayPause() {
        guard let media = currentMedia else { return }
        scriptQueue.addOperation { [weak self] in
            guard let self else { return }
            switch media.platform {
            case .music:
                self.runAppleScript("tell application \"Music\" to playpause")
            case .spotify:
                self.runAppleScript("tell application \"Spotify\" to playpause")
            case .youtube, .youtubeMusic, .spotifyWeb, .soundcloud:
                self.chromeExecuteJS(self.browserPlayPauseJS(for: media.platform), matching: self.urlHint(for: media.platform))
            case .unknown:
                break
            }
            Thread.sleep(forTimeInterval: 0.35)
            self.refreshMedia()
        }
    }

    func skipNext() {
        guard let media = currentMedia else { return }
        scriptQueue.addOperation { [weak self] in
            guard let self else { return }
            switch media.platform {
            case .music:
                self.runAppleScript("tell application \"Music\" to next track")
            case .spotify:
                self.runAppleScript("tell application \"Spotify\" to next track")
            case .youtube, .youtubeMusic, .spotifyWeb, .soundcloud:
                self.chromeExecuteJS(self.browserNextJS(for: media.platform), matching: self.urlHint(for: media.platform))
            case .unknown:
                break
            }
            Thread.sleep(forTimeInterval: 0.6)
            self.refreshMedia()
        }
    }

    func skipPrevious() {
        guard let media = currentMedia else { return }
        scriptQueue.addOperation { [weak self] in
            guard let self else { return }
            switch media.platform {
            case .music:
                self.runAppleScript("tell application \"Music\" to previous track")
            case .spotify:
                self.runAppleScript("tell application \"Spotify\" to previous track")
            case .youtube, .youtubeMusic, .spotifyWeb, .soundcloud:
                self.chromeExecuteJS(self.browserPreviousJS(for: media.platform), matching: self.urlHint(for: media.platform))
            case .unknown:
                break
            }
            Thread.sleep(forTimeInterval: 0.6)
            self.refreshMedia()
        }
    }

    func refreshMedia() {
        guard scriptQueue.operationCount == 0 else { return }
        scriptQueue.addOperation { [weak self] in
            guard let self else { return }

            let candidates = [
                self.fetchSpotifyInfo(),
                self.fetchMusicInfo(),
                self.fetchChromeMediaInfo()
            ]
            .compactMap { $0 }

            let selected = self.selectBestCandidate(from: candidates)
            DispatchQueue.main.async {
                self.currentMedia = selected
                self.lastRefreshDate = .now
                self.lastPlatform = selected?.platform
            }

            if let selected, let artworkURL = selected.artworkURL {
                self.loadArtworkIfNeeded(from: artworkURL, for: selected)
            }
        }
    }

    private func observePlayerNotifications() {
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshMedia()
        }

        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshMedia()
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshMedia()
        }
    }

    private func startPolling() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { [weak self] _ in
            self?.refreshMedia()
        }
        refreshTimer?.tolerance = 0.4
        refreshMedia()
    }

    private func fetchMusicInfo() -> MediaInfo? {
        let script = """
        if application "Music" is running then
            tell application "Music"
                set ps to player state
                if ps is playing or ps is paused then
                    set t to name of current track
                    set a to artist of current track
                    set pos to player position
                    set dur to duration of current track
                    return t & "||" & a & "||" & (ps as string) & "||" & (pos as string) & "||" & (dur as string)
                end if
            end tell
        end if
        return ""
        """

        guard let raw = runAppleScript(script), raw.isEmpty == false else { return nil }
        let parts = raw.components(separatedBy: "||")
        guard parts.count >= 5 else { return nil }

        let elapsed = Double(parts[3]) ?? 0
        let duration = Double(parts[4]) ?? 0
        return MediaInfo(
            title: parts[0],
            artist: parts[1],
            albumArt: nil,
            isPlaying: parts[2] == "playing",
            progress: duration > 0 ? min(elapsed / duration, 1) : 0,
            duration: duration,
            elapsed: elapsed,
            platform: .music,
            artworkURL: nil,
            sourceApplication: "Music"
        )
    }

    private func fetchSpotifyInfo() -> MediaInfo? {
        let script = """
        if application "Spotify" is running then
            tell application "Spotify"
                set ps to player state
                if ps is playing or ps is paused then
                    set t to name of current track
                    set a to artist of current track
                    set pos to player position
                    set dur to duration of current track
                    set art to artwork url of current track
                    return t & "||" & a & "||" & (ps as string) & "||" & (pos as string) & "||" & ((dur / 1000) as string) & "||" & art
                end if
            end tell
        end if
        return ""
        """

        guard let raw = runAppleScript(script), raw.isEmpty == false else { return nil }
        let parts = raw.components(separatedBy: "||")
        guard parts.count >= 5 else { return nil }

        let elapsed = Double(parts[3]) ?? 0
        let duration = Double(parts[4]) ?? 0
        let artworkURL = parts.count > 5 ? URL(string: parts[5]) : nil

        return MediaInfo(
            title: parts[0],
            artist: parts[1],
            albumArt: cachedArtwork(for: artworkURL),
            isPlaying: parts[2] == "playing",
            progress: duration > 0 ? min(elapsed / duration, 1) : 0,
            duration: duration,
            elapsed: elapsed,
            platform: .spotify,
            artworkURL: artworkURL,
            sourceApplication: "Spotify"
        )
    }

    private func fetchChromeMediaInfo() -> MediaInfo? {
        let script = """
        if application "Google Chrome" is running then
            tell application "Google Chrome"
                repeat with w in windows
                    repeat with t in tabs of w
                        set tURL to URL of t
                        if tURL contains "youtube.com" or tURL contains "music.youtube.com" or tURL contains "open.spotify.com" or tURL contains "soundcloud.com" then
                            try
                                set payload to execute t javascript "\(escapedJavaScript(browserDetectionJS))"
                                if payload is not "" and payload is not "null" then
                                    return tURL & "||" & payload
                                end if
                            end try
                        end if
                    end repeat
                end repeat
            end tell
        end if
        return ""
        """

        guard let raw = runAppleScript(script), raw.isEmpty == false else { return nil }
        let components = raw.components(separatedBy: "||")
        guard components.count >= 2 else { return nil }

        let urlString = components[0]
        let payload = components.dropFirst().joined(separator: "||")
        guard let data = payload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        let title = sanitizeBrowserTitle(json["title"] as? String ?? "", urlString: urlString)
        guard title.isEmpty == false else { return nil }

        let artist = sanitizeArtist(json["artist"] as? String)
        let elapsed = json["elapsed"] as? Double ?? 0
        let duration = json["duration"] as? Double ?? 0
        let isPlaying = json["playing"] as? Bool ?? false
        let artworkURL = (json["artwork"] as? String).flatMap(URL.init(string:))
        let platform = platform(for: urlString)

        return MediaInfo(
            title: title,
            artist: artist,
            albumArt: cachedArtwork(for: artworkURL),
            isPlaying: isPlaying,
            progress: duration > 0 ? min(elapsed / duration, 1) : 0,
            duration: duration,
            elapsed: elapsed,
            platform: platform,
            artworkURL: artworkURL,
            sourceApplication: "Google Chrome"
        )
    }

    private func selectBestCandidate(from candidates: [MediaInfo]) -> MediaInfo? {
        candidates.max { lhs, rhs in
            score(for: lhs) < score(for: rhs)
        }
    }

    private func score(for info: MediaInfo) -> Int {
        var total = info.isPlaying ? 100 : 20
        if info.duration > 0 { total += 10 }
        if lastPlatform == info.platform { total += 8 }
        if info.platform == .spotify || info.platform == .music { total += 4 }
        return total
    }

    private func platform(for urlString: String) -> MediaPlatform {
        if urlString.contains("music.youtube.com") { return .youtubeMusic }
        if urlString.contains("youtube.com") { return .youtube }
        if urlString.contains("open.spotify.com") { return .spotifyWeb }
        if urlString.contains("soundcloud.com") { return .soundcloud }
        return .unknown
    }

    private func sanitizeBrowserTitle(_ title: String, urlString: String) -> String {
        var cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: " - YouTube Music", with: "")
        cleaned = cleaned.replacingOccurrences(of: " - YouTube", with: "")
        cleaned = cleaned.replacingOccurrences(of: " | Spotify", with: "")
        cleaned = cleaned.replacingOccurrences(of: " | SoundCloud", with: "")

        if urlString.contains("open.spotify.com"), cleaned.contains("song and lyrics by") {
            cleaned = cleaned.components(separatedBy: " song and lyrics by ").first ?? cleaned
        }
        return cleaned
    }

    private func sanitizeArtist(_ artist: String?) -> String {
        let cleaned = artist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if cleaned == "YouTube" || cleaned == "Spotify" {
            return ""
        }
        return cleaned
    }

    private func loadArtworkIfNeeded(from url: URL, for media: MediaInfo) {
        if cachedArtwork(for: url) != nil { return }

        artworkQueue.async { [weak self] in
            guard let self else { return }
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 4)
            guard let data = try? Data(contentsOf: request.url!),
                  let image = NSImage(data: data) else { return }

            DispatchQueue.main.async {
                self.artworkCache[url.absoluteString] = image
                guard var current = self.currentMedia,
                      current.title == media.title,
                      current.artist == media.artist else {
                    return
                }
                current.albumArt = image
                self.currentMedia = current
            }
        }
    }

    private func cachedArtwork(for url: URL?) -> NSImage? {
        guard let key = url?.absoluteString else { return nil }
        return artworkCache[key]
    }

    private var browserDetectionJS: String {
        """
        (function() {
            const media = document.querySelector('video, audio');
            const title = document.querySelector('meta[property="og:title"]')?.content
                || document.querySelector('ytmusic-player-bar .title')?.textContent
                || document.querySelector('#title h1')?.textContent
                || document.title
                || '';
            const artist = document.querySelector('[data-testid="context-item-info-artist"] a')?.textContent
                || document.querySelector('ytmusic-player-bar .byline')?.textContent
                || document.querySelector('#upload-info #channel-name a')?.textContent
                || '';
            const artwork = document.querySelector('meta[property="og:image"]')?.content
                || document.querySelector('img[src*="i.scdn.co"]')?.src
                || document.querySelector('ytmusic-player-bar img')?.src
                || '';
            if (!media && !title) { return ''; }
            return JSON.stringify({
                title: (title || '').trim(),
                artist: (artist || '').replace(/\\s+/g, ' ').trim(),
                elapsed: media ? Number(media.currentTime || 0) : 0,
                duration: media && Number.isFinite(media.duration) ? Number(media.duration) : 0,
                playing: media ? !media.paused : false,
                artwork: artwork || ''
            });
        })()
        """
    }

    private func browserPlayPauseJS(for platform: MediaPlatform) -> String {
        switch platform {
        case .spotifyWeb:
            return "document.querySelector('[data-testid=\"control-button-playpause\"]')?.click()"
        case .youtube, .youtubeMusic:
            return "document.querySelector('.ytp-play-button, tp-yt-paper-icon-button.play-pause-button')?.click()"
        case .soundcloud:
            return "document.querySelector('.playControl')?.click()"
        default:
            return "document.querySelector('video, audio') && (document.querySelector('video, audio').paused ? document.querySelector('video, audio').play() : document.querySelector('video, audio').pause())"
        }
    }

    private func browserNextJS(for platform: MediaPlatform) -> String {
        switch platform {
        case .spotifyWeb:
            return "document.querySelector('[data-testid=\"control-button-skip-forward\"]')?.click()"
        case .youtube, .youtubeMusic:
            return "document.querySelector('.ytp-next-button, tp-yt-paper-icon-button.next-button')?.click()"
        case .soundcloud:
            return "document.querySelector('.skipControl__next')?.click()"
        default:
            return ""
        }
    }

    private func browserPreviousJS(for platform: MediaPlatform) -> String {
        switch platform {
        case .spotifyWeb:
            return "document.querySelector('[data-testid=\"control-button-skip-back\"]')?.click()"
        case .youtube, .youtubeMusic:
            return "document.querySelector('.ytp-prev-button, tp-yt-paper-icon-button.previous-button')?.click()"
        case .soundcloud:
            return "document.querySelector('.skipControl__previous')?.click()"
        default:
            return ""
        }
    }

    private func urlHint(for platform: MediaPlatform) -> String {
        switch platform {
        case .youtubeMusic:
            return "music.youtube.com"
        case .youtube:
            return "youtube.com"
        case .spotifyWeb:
            return "open.spotify.com"
        case .soundcloud:
            return "soundcloud.com"
        default:
            return ""
        }
    }

    private func chromeExecuteJS(_ javaScript: String, matching urlFragment: String) {
        guard javaScript.isEmpty == false else { return }
        let script = """
        if application "Google Chrome" is running then
            tell application "Google Chrome"
                repeat with w in windows
                    repeat with t in tabs of w
                        if URL of t contains "\(urlFragment)" then
                            execute t javascript "\(escapedJavaScript(javaScript))"
                            return "ok"
                        end if
                    end repeat
                end repeat
            end tell
        end if
        return ""
        """
        runAppleScript(script)
    }

    private func escapedJavaScript(_ javaScript: String) -> String {
        javaScript
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: " ")
    }

    @discardableResult
    private func runAppleScript(_ source: String) -> String? {
        guard let script = NSAppleScript(source: source) else { return nil }
        var errorInfo: NSDictionary?
        let result = script.executeAndReturnError(&errorInfo)
        if errorInfo != nil {
            return nil
        }
        return result.stringValue
    }
}
