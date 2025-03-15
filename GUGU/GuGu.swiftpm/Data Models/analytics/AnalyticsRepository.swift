import Foundation

class AnalyticsRepository {
    private let WEEKLY_ANALYTICS_KEY = "WEEKLY_ANALYTICS_KEY"
    
    func saveWeeklyAnalytics(_ analytics: [UUID: WeeklyAnalytics]) {
        if let encoded = try? JSONEncoder().encode(analytics) {
            UserDefaults.standard.set(encoded, forKey: WEEKLY_ANALYTICS_KEY)
        }
    }
    
    func loadWeeklyAnalytics() -> [UUID: WeeklyAnalytics] {
        guard let data = UserDefaults.standard.data(forKey: WEEKLY_ANALYTICS_KEY),
              let decoded = try? JSONDecoder().decode([UUID: WeeklyAnalytics].self, from: data)
        else {
            return [:]
        }
        return decoded
    }
    
    func clearOldData() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.startOfWeek()
        
        var analytics = loadWeeklyAnalytics()
        analytics = analytics.filter { _, weeklyData in
            weeklyData.weekStartDate == currentWeekStart
        }
        saveWeeklyAnalytics(analytics)
    }
}
