import Foundation
import Combine
import EventKit

class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var upcomingEvents: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        self.authorizationStatus = status
        
        if #available(macOS 14.0, *) {
            if status == .fullAccess || status == .writeOnly {
                fetchEvents()
            }
        } else {
            if status == .authorized {
                fetchEvents()
            }
        }
    }
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.fetchEvents()
                    }
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.fetchEvents()
                    }
                    completion(granted)
                }
            }
        }
    }
    
    func fetchEvents() {
        let calendars = eventStore.calendars(for: .event)
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.upcomingEvents = events.sorted { $0.startDate < $1.startDate }
        }
    }
}
