import Foundation

@MainActor
final class AppModel: ObservableObject {
    let islandState: IslandState
    let calendarService: CalendarService
    let focusService: FocusService
    let deviceService: DeviceSyncService
    let noteService: NoteService
    let continuityService: ContinuityService
    let mediaService: MediaService
    let taskService: TaskService

    init() {
        let islandState = IslandState()
        self.islandState = islandState
        calendarService = CalendarService()
        focusService = FocusService()
        deviceService = DeviceSyncService()
        noteService = NoteService()
        continuityService = ContinuityService()
        mediaService = MediaService()
        taskService = TaskService()
    }
}
