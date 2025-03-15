import SwiftUI
import Charts

struct MoodInsightsView: View {
    var moodLogs: [MoodLog] // Accepts mood logs from the tracker

    // Calculating averages and insights based on mood logs
    private var averageMood: Double {
        guard !moodLogs.isEmpty else { return 0 }
        let totalMood = moodLogs.reduce(0) { $0 + Double($1.moodRating) }
        return totalMood / Double(moodLogs.count)
    }

    private var averageStress: Double {
        guard !moodLogs.isEmpty else { return 0 }
        let totalStress = moodLogs.reduce(0) { $0 + Double($1.stressLevel) }
        return totalStress / Double(moodLogs.count)
    }

    // Mood and stress trends
    private var moodTrend: String {
        guard moodLogs.count > 1 else { return "Not enough data to determine trends." }
        
        let firstLogMood = moodLogs.last!.moodRating
        let lastLogMood = moodLogs.first!.moodRating
        
        return lastLogMood > firstLogMood ? "Your mood has improved over time!" :
               lastLogMood < firstLogMood ? "Your mood has declined over time." :
               "Your mood has remained stable."
    }
    
    private var stressTrend: String {
        guard moodLogs.count > 1 else { return "Not enough data to determine trends." }
        
        let firstLogStress = moodLogs.last!.stressLevel
        let lastLogStress = moodLogs.first!.stressLevel
        
        return lastLogStress > firstLogStress ? "Your stress levels have increased." :
               lastLogStress < firstLogStress ? "Your stress levels have decreased!" :
               "Your stress levels have remained stable."
    }
    
    // Insights text based on mood and stress averages
    private var moodInsights: String {
        switch averageMood {
        case 4.5...5:
            return "Your mood has been consistently great! Keep up the positive energy."
        case 3..<4.5:
            return "Your mood is good, but there is room for improvement. Consider incorporating uplifting activities."
        case 1..<3:
            return "Your mood has been on the lower side. It might help to talk to someone or engage in stress-relief exercises."
        default:
            return "Not enough data to provide mood insights."
        }
    }
    
    private var stressInsights: String {
        switch averageStress {
        case 1..<2:
            return "Great job! Your stress levels are low, which is a positive sign."
        case 2..<3:
            return "Your stress levels are manageable, but keep an eye on them and practice self-care."
        case 3...:
            return "It seems like you're experiencing higher stress levels. Consider practicing relaxation techniques."
        default:
            return "Not enough data to provide stress insights."
        }
    }

    // Recommendations based on average mood and stress
    private var recommendations: String {
        if averageMood < 3 {
            return "Try engaging in activities that make you happy, like spending time with friends, hobbies, or exercise."
        } else if averageStress > 2 {
            return "Consider practicing mindfulness, meditation, or yoga to manage stress."
        } else {
            return "Keep maintaining your healthy habits!"
        }
    }

    // Music Recommendations based on mood
    private var musicRecommendations: [MusicRecommendation] {
        let sadSongs = [
            MusicRecommendation(title: "Someone Like You", artist: "Adele", genre: "Pop"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Stay", artist: "Rihanna ft. Mikky Ekko", genre: "Pop"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "Breathe Me", artist: "Sia", genre: "Pop"),
            MusicRecommendation(title: "Creep", artist: "Radiohead", genre: "Alternative"),
            MusicRecommendation(title: "Someone You Loved", artist: "Lewis Capaldi", genre: "Pop"),
            MusicRecommendation(title: "All I Want", artist: "Kodaline", genre: "Indie"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "The A Team", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Hallelujah", artist: "Jeff Buckley", genre: "Rock"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Broken", artist: "Loverboy", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Half of My Heart", artist: "John Mayer", genre: "Rock"),
            MusicRecommendation(title: "In the Night", artist: "The Weeknd", genre: "R&B"),
            MusicRecommendation(title: "Sorrow", artist: "David Bowie", genre: "Rock"),
            MusicRecommendation(title: "Chasing Cars", artist: "Snow Patrol", genre: "Alternative"),
            MusicRecommendation(title: "Breathe", artist: "Pink Floyd", genre: "Rock"),
            MusicRecommendation(title: "Need You Now", artist: "Lady A", genre: "Country"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Say Something", artist: "A Great Big World", genre: "Pop"),
            MusicRecommendation(title: "When I Was Your Man", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "I Will Remember You", artist: "Sarah McLachlan", genre: "Pop"),
            MusicRecommendation(title: "Jealous", artist: "Labrinth", genre: "R&B"),
            MusicRecommendation(title: "The Scientist", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Candle in the Wind", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Coloratura", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Hurt", artist: "Nine Inch Nails", genre: "Industrial"),
            MusicRecommendation(title: "Everybody Hurts", artist: "R.E.M.", genre: "Alternative"),
            MusicRecommendation(title: "Good Riddance (Time of Your Life)", artist: "Green Day", genre: "Rock"),
            MusicRecommendation(title: "I Can't Make You Love Me", artist: "Bonnie Raitt", genre: "Blues"),
            MusicRecommendation(title: "Lonely", artist: "Akon", genre: "R&B"),
            MusicRecommendation(title: "Don't Speak", artist: "No Doubt", genre: "Rock"),
            MusicRecommendation(title: "Wherever You Will Go", artist: "The Calling", genre: "Rock"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Someone Like You", artist: "Adele", genre: "Pop"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Bitter Sweet Symphony", artist: "The Verve", genre: "Alternative"),
            MusicRecommendation(title: "The Sound of Silence", artist: "Simon & Garfunkel", genre: "Folk"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Wait", artist: "M83", genre: "Electronic"),
            MusicRecommendation(title: "Life After Death", artist: "The Weeknd", genre: "R&B"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "Little Lion Man", artist: "Mumford & Sons", genre: "Folk"),
            MusicRecommendation(title: "Simple Man", artist: "Lynyrd Skynyrd", genre: "Rock"),
            MusicRecommendation(title: "Let It Go", artist: "James Bay", genre: "Pop"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "Fast Car", artist: "Tracy Chapman", genre: "Folk"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Why", artist: "Katy Perry", genre: "Pop"),
            MusicRecommendation(title: "Falling", artist: "Harry Styles", genre: "Pop"),
            MusicRecommendation(title: "Nothing Breaks Like a Heart", artist: "Mark Ronson ft. Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "Everytime", artist: "Britney Spears", genre: "Pop"),
            MusicRecommendation(title: "Better Man", artist: "Pearl Jam", genre: "Rock"),
            MusicRecommendation(title: "You're Beautiful", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "I Can't Help Falling in Love", artist: "Elvis Presley", genre: "Pop"),
            MusicRecommendation(title: "Goodbye Yellow Brick Road", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "The One That Got Away", artist: "Katy Perry", genre: "Pop"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "Say You Love Me", artist: "Jessie Ware", genre: "R&B"),
            MusicRecommendation(title: "Stitches", artist: "Shawn Mendes", genre: "Pop"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Someone Like You", artist: "Adele", genre: "Pop"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "My Heart Will Go On", artist: "Celine Dion", genre: "Pop"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "The Sound of Silence", artist: "Simon & Garfunkel", genre: "Folk"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Someone You Loved", artist: "Lewis Capaldi", genre: "Pop"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "Creep", artist: "Radiohead", genre: "Alternative"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "I Can't Make You Love Me", artist: "Bonnie Raitt", genre: "Blues"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Nothing Breaks Like a Heart", artist: "Mark Ronson ft. Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "Falling", artist: "Harry Styles", genre: "Pop"),
            MusicRecommendation(title: "Simple Man", artist: "Lynyrd Skynyrd", genre: "Rock"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Hallelujah", artist: "Jeff Buckley", genre: "Rock"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Don't Speak", artist: "No Doubt", genre: "Rock"),
            MusicRecommendation(title: "My Heart Will Go On", artist: "Celine Dion", genre: "Pop"),
            MusicRecommendation(title: "Jealous", artist: "Labrinth", genre: "R&B"),
            MusicRecommendation(title: "Everybody Hurts", artist: "R.E.M.", genre: "Alternative"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "When I Was Your Man", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "Candle in the Wind", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "Little Lion Man", artist: "Mumford & Sons", genre: "Folk"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Sorrow", artist: "David Bowie", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Half of My Heart", artist: "John Mayer", genre: "Rock"),
            MusicRecommendation(title: "In the Night", artist: "The Weeknd", genre: "R&B"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Little Lion Man", artist: "Mumford & Sons", genre: "Folk"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Someone You Loved", artist: "Lewis Capaldi", genre: "Pop"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Goodbye Yellow Brick Road", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "The Scientist", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "When I Was Your Man", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Wherever You Will Go", artist: "The Calling", genre: "Rock"),
            MusicRecommendation(title: "Stitches", artist: "Shawn Mendes", genre: "Pop"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "Everytime", artist: "Britney Spears", genre: "Pop"),
            MusicRecommendation(title: "Let It Go", artist: "James Bay", genre: "Pop"),
            MusicRecommendation(title: "Say You Love Me", artist: "Jessie Ware", genre: "R&B"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "The Sound of Silence", artist: "Simon & Garfunkel", genre: "Folk"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Nothing Breaks Like a Heart", artist: "Mark Ronson ft. Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "Simple Man", artist: "Lynyrd Skynyrd", genre: "Rock"),
            MusicRecommendation(title: "The A Team", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "I Can't Help Falling in Love", artist: "Elvis Presley", genre: "Pop"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Don't Speak", artist: "No Doubt", genre: "Rock"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Everybody Hurts", artist: "R.E.M.", genre: "Alternative"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Say Something", artist: "A Great Big World", genre: "Pop"),
            MusicRecommendation(title: "Wherever You Will Go", artist: "The Calling", genre: "Rock"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "Someone Like You", artist: "Adele", genre: "Pop"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Half of My Heart", artist: "John Mayer", genre: "Rock"),
            MusicRecommendation(title: "Hurt", artist: "Nine Inch Nails", genre: "Industrial"),
            MusicRecommendation(title: "Creep", artist: "Radiohead", genre: "Alternative"),
            MusicRecommendation(title: "Sorrow", artist: "David Bowie", genre: "Rock"),
            MusicRecommendation(title: "Nothing Breaks Like a Heart", artist: "Mark Ronson ft. Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "I Can't Make You Love Me", artist: "Bonnie Raitt", genre: "Blues"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Hallelujah", artist: "Jeff Buckley", genre: "Rock"),
            MusicRecommendation(title: "I Will Remember You", artist: "Sarah McLachlan", genre: "Pop"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Goodbye Yellow Brick Road", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "You're Beautiful", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Lonely", artist: "Akon", genre: "R&B"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Everytime", artist: "Britney Spears", genre: "Pop"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Wherever You Will Go", artist: "The Calling", genre: "Rock"),
            MusicRecommendation(title: "I Can't Help Falling in Love", artist: "Elvis Presley", genre: "Pop"),
            MusicRecommendation(title: "Good Riddance (Time of Your Life)", artist: "Green Day", genre: "Rock"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "Simple Man", artist: "Lynyrd Skynyrd", genre: "Rock"),
            MusicRecommendation(title: "The A Team", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "Half of My Heart", artist: "John Mayer", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Chasing Cars", artist: "Snow Patrol", genre: "Alternative"),
            MusicRecommendation(title: "Sorrow", artist: "David Bowie", genre: "Rock"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "Say Something", artist: "A Great Big World", genre: "Pop"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Chasing Cars", artist: "Snow Patrol", genre: "Alternative"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Everytime", artist: "Britney Spears", genre: "Pop"),
            MusicRecommendation(title: "The Sound of Silence", artist: "Simon & Garfunkel", genre: "Folk"),
            MusicRecommendation(title: "Let It Go", artist: "James Bay", genre: "Pop"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Someone You Loved", artist: "Lewis Capaldi", genre: "Pop"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "Creep", artist: "Radiohead", genre: "Alternative"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "I Will Remember You", artist: "Sarah McLachlan", genre: "Pop"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Goodbye Yellow Brick Road", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Wherever You Will Go", artist: "The Calling", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "Falling", artist: "Harry Styles", genre: "Pop"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Simple Man", artist: "Lynyrd Skynyrd", genre: "Rock"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "When I Was Your Man", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Candle in the Wind", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Hallelujah", artist: "Jeff Buckley", genre: "Rock"),
            MusicRecommendation(title: "Say You Love Me", artist: "Jessie Ware", genre: "R&B"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "I Can't Help Falling in Love", artist: "Elvis Presley", genre: "Pop"),
            MusicRecommendation(title: "Lonely", artist: "Akon", genre: "R&B"),
            MusicRecommendation(title: "Half of My Heart", artist: "John Mayer", genre: "Rock"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Take Me to Church", artist: "Hozier", genre: "Indie"),
            MusicRecommendation(title: "Fix You", artist: "Coldplay", genre: "Alternative"),
            MusicRecommendation(title: "Everytime", artist: "Britney Spears", genre: "Pop"),
            MusicRecommendation(title: "Goodbye Yellow Brick Road", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Waiting For Love", artist: "Avicii", genre: "Electronic"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Good Riddance (Time of Your Life)", artist: "Green Day", genre: "Rock"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "The A Team", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Let It Go", artist: "James Bay", genre: "Pop"),
            MusicRecommendation(title: "The Night We Met", artist: "Lord Huron", genre: "Indie"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "I Can't Make You Love Me", artist: "Bonnie Raitt", genre: "Blues"),
            MusicRecommendation(title: "Dancing On My Own", artist: "Robyn", genre: "Dance"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "I Will Remember You", artist: "Sarah McLachlan", genre: "Pop"),
            MusicRecommendation(title: "Chasing Cars", artist: "Snow Patrol", genre: "Alternative"),
            MusicRecommendation(title: "Nothing Compares 2 U", artist: "Sinead O'Connor", genre: "Pop"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "The A Team", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "Goodbye My Lover", artist: "James Blunt", genre: "Pop"),
            MusicRecommendation(title: "Candle in the Wind", artist: "Elton John", genre: "Rock"),
            MusicRecommendation(title: "Someone You Loved", artist: "Lewis Capaldi", genre: "Pop"),
            MusicRecommendation(title: "I Will Always Love You", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Hurt", artist: "Nine Inch Nails", genre: "Industrial"),
            MusicRecommendation(title: "Lonely", artist: "Akon", genre: "R&B"),
            MusicRecommendation(title: "Fade Into You", artist: "Mazzy Star", genre: "Indie"),
            MusicRecommendation(title: "Back to December", artist: "Taylor Swift", genre: "Country"),
            MusicRecommendation(title: "Let Her Go", artist: "Passenger", genre: "Pop"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "Sorrow", artist: "David Bowie", genre: "Rock"),
            MusicRecommendation(title: "My Immortal", artist: "Evanescence", genre: "Rock"),
            MusicRecommendation(title: "Tears Dry on Their Own", artist: "Amy Winehouse", genre: "Soul"),
            MusicRecommendation(title: "The Sound of Silence", artist: "Simon & Garfunkel", genre: "Folk"),
            MusicRecommendation(title: "Wild Horses", artist: "The Rolling Stones", genre: "Rock"),
            MusicRecommendation(title: "Fade", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Goodbye", artist: "Spice Girls", genre: "Pop"),
            MusicRecommendation(title: "Skinny Love", artist: "Bon Iver", genre: "Indie"),
            MusicRecommendation(title: "Let It Go", artist: "James Bay", genre: "Pop"),
            MusicRecommendation(title: "I Can't Help Falling in Love", artist: "Elvis Presley", genre: "Pop")
           ]
           
        let feelGoodSongs = [
            MusicRecommendation(title: "Happy", artist: "Pharrell Williams", genre: "Pop"),
            MusicRecommendation(title: "Uptown Funk", artist: "Mark Ronson ft. Bruno Mars", genre: "Funk"),
            MusicRecommendation(title: "Walking on Sunshine", artist: "Katrina and the Waves", genre: "Pop"),
            MusicRecommendation(title: "Can't Stop the Feeling!", artist: "Justin Timberlake", genre: "Pop"),
            MusicRecommendation(title: "Good Vibrations", artist: "The Beach Boys", genre: "Rock"),
            MusicRecommendation(title: "Shut Up and Dance", artist: "WALK THE MOON", genre: "Pop"),
            MusicRecommendation(title: "I Got You (I Feel Good)", artist: "James Brown", genre: "Soul"),
            MusicRecommendation(title: "Don't Worry Be Happy", artist: "Bobby McFerrin", genre: "Pop"),
            MusicRecommendation(title: "Get Lucky", artist: "Daft Punk ft. Pharrell Williams", genre: "Dance"),
            MusicRecommendation(title: "Best Day of My Life", artist: "American Authors", genre: "Pop"),
            MusicRecommendation(title: "Shake It Off", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Dancing Queen", artist: "ABBA", genre: "Pop"),
            MusicRecommendation(title: "Here Comes the Sun", artist: "The Beatles", genre: "Rock"),
            MusicRecommendation(title: "Firework", artist: "Katy Perry", genre: "Pop"),
            MusicRecommendation(title: "Treasure", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "Raise Your Glass", artist: "P!nk", genre: "Pop"),
            MusicRecommendation(title: "Good as Hell", artist: "Lizzo", genre: "R&B"),
            MusicRecommendation(title: "Levitating", artist: "Dua Lipa ft. DaBaby", genre: "Pop"),
            MusicRecommendation(title: "We Found Love", artist: "Rihanna ft. Calvin Harris", genre: "Dance"),
            MusicRecommendation(title: "Party in the USA", artist: "Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "What Makes You Beautiful", artist: "One Direction", genre: "Pop"),
            MusicRecommendation(title: "Walking on Sunshine", artist: "Katrina and the Waves", genre: "Rock"),
            MusicRecommendation(title: "Sweet Caroline", artist: "Neil Diamond", genre: "Pop"),
            MusicRecommendation(title: "I Wanna Dance with Somebody", artist: "Whitney Houston", genre: "Pop"),
            MusicRecommendation(title: "Valerie", artist: "Mark Ronson ft. Amy Winehouse", genre: "Pop"),
            MusicRecommendation(title: "Good Time", artist: "Owl City & Carly Rae Jepsen", genre: "Pop"),
            MusicRecommendation(title: "Sugar", artist: "Maroon 5", genre: "Pop"),
            MusicRecommendation(title: "Jump Around", artist: "House of Pain", genre: "Hip Hop"),
            MusicRecommendation(title: "Best Day of My Life", artist: "American Authors", genre: "Rock"),
            MusicRecommendation(title: "Run the World (Girls)", artist: "Beyoncé", genre: "Pop"),
            MusicRecommendation(title: "I Will Survive", artist: "Gloria Gaynor", genre: "Disco"),
            MusicRecommendation(title: "Hotline Bling", artist: "Drake", genre: "Hip Hop"),
            MusicRecommendation(title: "Good Day Sunshine", artist: "The Beatles", genre: "Rock"),
            MusicRecommendation(title: "Can't Stop", artist: "Red Hot Chili Peppers", genre: "Rock"),
            MusicRecommendation(title: "Wake Me Up", artist: "Avicii", genre: "Dance"),
            MusicRecommendation(title: "Home", artist: "Edward Sharpe & The Magnetic Zeros", genre: "Indie"),
            MusicRecommendation(title: "Young, Wild & Free", artist: "Snoop Dogg & Wiz Khalifa", genre: "Hip Hop"),
            MusicRecommendation(title: "Celebration", artist: "Kool & The Gang", genre: "Funk"),
            MusicRecommendation(title: "Just the Way You Are", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "Pompeii", artist: "Bastille", genre: "Pop"),
            MusicRecommendation(title: "Here Comes the Sun", artist: "The Beatles", genre: "Rock"),
            MusicRecommendation(title: "Bubbly", artist: "Colbie Caillat", genre: "Pop"),
            MusicRecommendation(title: "Shiny Happy People", artist: "R.E.M.", genre: "Alternative"),
            MusicRecommendation(title: "Good Times", artist: "Chic", genre: "Funk"),
            MusicRecommendation(title: "Don't Stop Believin'", artist: "Journey", genre: "Rock"),
            MusicRecommendation(title: "Fly Me to the Moon", artist: "Frank Sinatra", genre: "Jazz"),
            MusicRecommendation(title: "I'm a Believer", artist: "The Monkees", genre: "Rock"),
            MusicRecommendation(title: "September", artist: "Earth, Wind & Fire", genre: "Funk"),
            MusicRecommendation(title: "One More Time", artist: "Daft Punk", genre: "Electronic"),
            MusicRecommendation(title: "Let's Go Crazy", artist: "Prince", genre: "Rock"),
            MusicRecommendation(title: "Take On Me", artist: "a-ha", genre: "Pop"),
            MusicRecommendation(title: "Summer of '69", artist: "Bryan Adams", genre: "Rock"),
            MusicRecommendation(title: "Shake It Out", artist: "Florence + The Machine", genre: "Indie"),
            MusicRecommendation(title: "All Star", artist: "Smash Mouth", genre: "Rock"),
            MusicRecommendation(title: "Ain't No Mountain High Enough", artist: "Marvin Gaye & Tammi Terrell", genre: "Soul"),
            MusicRecommendation(title: "You Make My Dreams", artist: "Daryl Hall & John Oates", genre: "Rock"),
            MusicRecommendation(title: "Valerie", artist: "Mark Ronson ft. Amy Winehouse", genre: "Pop"),
            MusicRecommendation(title: "Good Riddance (Time of Your Life)", artist: "Green Day", genre: "Rock"),
            MusicRecommendation(title: "Electric Feel", artist: "MGMT", genre: "Indie"),
            MusicRecommendation(title: "Best Day of My Life", artist: "American Authors", genre: "Rock"),
            MusicRecommendation(title: "Let's Groove", artist: "Earth, Wind & Fire", genre: "Funk"),
            MusicRecommendation(title: "Livin' on a Prayer", artist: "Bon Jovi", genre: "Rock"),
            MusicRecommendation(title: "Survivor", artist: "Destiny's Child", genre: "R&B"),
            MusicRecommendation(title: "Kiss", artist: "Prince", genre: "Rock"),
            MusicRecommendation(title: "Dance Monkey", artist: "Tones and I", genre: "Pop"),
            MusicRecommendation(title: "Come On Eileen", artist: "Dexys Midnight Runners", genre: "Pop"),
            MusicRecommendation(title: "Jump (For My Love)", artist: "The Pointer Sisters", genre: "Pop"),
            MusicRecommendation(title: "I Love It", artist: "Icona Pop ft. Charli XCX", genre: "Pop"),
            MusicRecommendation(title: "Watermelon Sugar", artist: "Harry Styles", genre: "Pop"),
            MusicRecommendation(title: "Unwritten", artist: "Natasha Bedingfield", genre: "Pop"),
            MusicRecommendation(title: "Raise Your Glass", artist: "P!nk", genre: "Pop"),
            MusicRecommendation(title: "Hey Ya!", artist: "OutKast", genre: "Hip Hop"),
            MusicRecommendation(title: "Everyday People", artist: "Sly & The Family Stone", genre: "Funk"),
            MusicRecommendation(title: "Sweet Child O' Mine", artist: "Guns N' Roses", genre: "Rock"),
            MusicRecommendation(title: "I Can See Clearly Now", artist: "Johnny Nash", genre: "Reggae"),
            MusicRecommendation(title: "Put It All on Me", artist: "Ed Sheeran", genre: "Pop"),
            MusicRecommendation(title: "Let’s Go", artist: "Calvin Harris ft. Ne-Yo", genre: "Dance"),
            MusicRecommendation(title: "Dancing in the Moonlight", artist: "Toploader", genre: "Pop"),
            MusicRecommendation(title: "Take Me Home, Country Roads", artist: "John Denver", genre: "Country"),
            MusicRecommendation(title: "She Will Be Loved", artist: "Maroon 5", genre: "Pop"),
            MusicRecommendation(title: "Ain't Nobody", artist: "Chaka Khan", genre: "Funk"),
            MusicRecommendation(title: "Dog Days Are Over", artist: "Florence + The Machine", genre: "Indie"),
            MusicRecommendation(title: "Rock Your Body", artist: "Justin Timberlake", genre: "Pop"),
            MusicRecommendation(title: "Island in the Sun", artist: "Weezer", genre: "Rock"),
            MusicRecommendation(title: "Give Me Everything", artist: "Pitbull ft. Ne-Yo", genre: "Dance")
           ]
           
        let motivationalSongs = [
            MusicRecommendation(title: "Eye of the Tiger", artist: "Survivor", genre: "Rock"),
            MusicRecommendation(title: "Lose Yourself", artist: "Eminem", genre: "Hip Hop"),
            MusicRecommendation(title: "Stronger", artist: "Kanye West", genre: "Hip Hop"),
            MusicRecommendation(title: "Hall of Fame", artist: "The Script ft. will.i.am", genre: "Pop"),
            MusicRecommendation(title: "Don't Stop Believin'", artist: "Journey", genre: "Rock"),
            MusicRecommendation(title: "Fight Song", artist: "Rachel Platten", genre: "Pop"),
            MusicRecommendation(title: "Can't Stop", artist: "Red Hot Chili Peppers", genre: "Rock"),
            MusicRecommendation(title: "Survivor", artist: "Destiny's Child", genre: "R&B"),
            MusicRecommendation(title: "We Will Rock You", artist: "Queen", genre: "Rock"),
            MusicRecommendation(title: "The Climb", artist: "Miley Cyrus", genre: "Pop"),
            MusicRecommendation(title: "Stronger (What Doesn't Kill You)", artist: "Kelly Clarkson", genre: "Pop"),
            MusicRecommendation(title: "Born to Run", artist: "Bruce Springsteen", genre: "Rock"),
            MusicRecommendation(title: "Champion", artist: "Carrie Underwood", genre: "Country"),
            MusicRecommendation(title: "Unstoppable", artist: "Sia", genre: "Pop"),
            MusicRecommendation(title: "Get Up Stand Up", artist: "Bob Marley", genre: "Reggae"),
            MusicRecommendation(title: "Run the World (Girls)", artist: "Beyoncé", genre: "Pop"),
            MusicRecommendation(title: "Good Life", artist: "OneRepublic", genre: "Pop"),
            MusicRecommendation(title: "Rise Up", artist: "Andra Day", genre: "Soul"),
            MusicRecommendation(title: "Invincible", artist: "Halsey", genre: "Pop"),
            MusicRecommendation(title: "Ain't No Mountain High Enough", artist: "Marvin Gaye & Tammi Terrell", genre: "Soul"),
            MusicRecommendation(title: "Happy", artist: "Pharrell Williams", genre: "Pop"),
            MusicRecommendation(title: "Titanium", artist: "David Guetta ft. Sia", genre: "Dance"),
            MusicRecommendation(title: "Believe", artist: "Cher", genre: "Pop"),
            MusicRecommendation(title: "Whatever It Takes", artist: "Imagine Dragons", genre: "Rock"),
            MusicRecommendation(title: "Shake It Off", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "Firework", artist: "Katy Perry", genre: "Pop"),
            MusicRecommendation(title: "On Top of the World", artist: "Imagine Dragons", genre: "Rock"),
            MusicRecommendation(title: "Never Give Up", artist: "Sia", genre: "Pop"),
            MusicRecommendation(title: "We Are the Champions", artist: "Queen", genre: "Rock"),
            MusicRecommendation(title: "Rise", artist: "Katy Perry", genre: "Pop"),
            MusicRecommendation(title: "Fight for Your Right", artist: "Beastie Boys", genre: "Hip Hop"),
            MusicRecommendation(title: "Eye of the Storm", artist: "Ryan Stevenson", genre: "Christian"),
            MusicRecommendation(title: "Rise Up", artist: "Andra Day", genre: "Soul"),
            MusicRecommendation(title: "Brave", artist: "Sara Bareilles", genre: "Pop"),
            MusicRecommendation(title: "The Greatest", artist: "Sia", genre: "Pop"),
            MusicRecommendation(title: "Survivor", artist: "Destiny's Child", genre: "R&B"),
            MusicRecommendation(title: "Runaway Baby", artist: "Bruno Mars", genre: "Pop"),
            MusicRecommendation(title: "Good Riddance (Time of Your Life)", artist: "Green Day", genre: "Rock"),
            MusicRecommendation(title: "Hall of Fame", artist: "The Script ft. will.i.am", genre: "Pop"),
            MusicRecommendation(title: "Stronger", artist: "Kelly Clarkson", genre: "Pop"),
            MusicRecommendation(title: "Just Do It", artist: "Boosie Badazz", genre: "Hip Hop"),
            MusicRecommendation(title: "Unbreakable", artist: "Alicia Keys", genre: "R&B"),
            MusicRecommendation(title: "Fight Song", artist: "Rachel Platten", genre: "Pop"),
            MusicRecommendation(title: "Born to Be Wild", artist: "Steppenwolf", genre: "Rock"),
            MusicRecommendation(title: "Run Boy Run", artist: "Woodkid", genre: "Indie"),
            MusicRecommendation(title: "Can't Hold Us", artist: "Macklemore & Ryan Lewis", genre: "Hip Hop"),
            MusicRecommendation(title: "Never Back Down", artist: "J. Cole", genre: "Hip Hop"),
            MusicRecommendation(title: "Don't Stop", artist: "Fleetwood Mac", genre: "Rock"),
            MusicRecommendation(title: "Get Lucky", artist: "Daft Punk ft. Pharrell Williams", genre: "Dance"),
            MusicRecommendation(title: "Limitless", artist: "Jennifer Lopez", genre: "Pop"),
            MusicRecommendation(title: "It's My Life", artist: "Bon Jovi", genre: "Rock"),
            MusicRecommendation(title: "Nothing's Gonna Stop Us Now", artist: "Starship", genre: "Rock"),
            MusicRecommendation(title: "Don't Stop Believin'", artist: "Journey", genre: "Rock"),
            MusicRecommendation(title: "Better Place", artist: "Rachel Platten", genre: "Pop"),
            MusicRecommendation(title: "Dare You to Move", artist: "Switchfoot", genre: "Rock"),
            MusicRecommendation(title: "Keep Your Head Up", artist: "Ben Howard", genre: "Indie"),
            MusicRecommendation(title: "Live Like You Were Dying", artist: "Tim McGraw", genre: "Country"),
            MusicRecommendation(title: "Good Day Sunshine", artist: "The Beatles", genre: "Rock"),
            MusicRecommendation(title: "Don't Stop Me Now", artist: "Queen", genre: "Rock"),
            MusicRecommendation(title: "Shut Up and Dance", artist: "WALK THE MOON", genre: "Pop"),
            MusicRecommendation(title: "What Doesn't Kill You (Stronger)", artist: "Kelly Clarkson", genre: "Pop"),
            MusicRecommendation(title: "The Power", artist: "Snap!", genre: "Dance"),
            MusicRecommendation(title: "One More Light", artist: "Linkin Park", genre: "Rock"),
            MusicRecommendation(title: "You're Gonna Be Okay", artist: "Brian & Jenn Johnson", genre: "Christian"),
            MusicRecommendation(title: "The Greatest", artist: "Sia", genre: "Pop"),
            MusicRecommendation(title: "Fight the Good Fight", artist: "Blood, Sweat & Tears", genre: "Rock"),
            MusicRecommendation(title: "I Will Survive", artist: "Gloria Gaynor", genre: "Disco"),
            MusicRecommendation(title: "Ain't No Stopping Us Now", artist: "McFadden & Whitehead", genre: "Funk"),
            MusicRecommendation(title: "Today is Your Day", artist: "Shania Twain", genre: "Country"),
            MusicRecommendation(title: "Harder Better Faster Stronger", artist: "Daft Punk", genre: "Dance"),
            MusicRecommendation(title: "Gonna Fly Now (Theme from Rocky)", artist: "Bill Conti", genre: "Soundtrack"),
            MusicRecommendation(title: "We Are Family", artist: "Sister Sledge", genre: "Disco"),
            MusicRecommendation(title: "Stand by Me", artist: "Ben E. King", genre: "Soul"),
            MusicRecommendation(title: "Shake It Off", artist: "Taylor Swift", genre: "Pop"),
            MusicRecommendation(title: "My Wish", artist: "Rascal Flatts", genre: "Country"),
            MusicRecommendation(title: "Fight Your Fear", artist: "The Fray", genre: "Rock"),
            MusicRecommendation(title: "Livin' on a Prayer", artist: "Bon Jovi", genre: "Rock"),
            MusicRecommendation(title: "Just Fine", artist: "Mary J. Blige", genre: "R&B"),
            MusicRecommendation(title: "Keep Holding On", artist: "Avril Lavigne", genre: "Pop"),
            MusicRecommendation(title: "Gonna Make You Sweat (Everybody Dance Now)", artist: "C+C Music Factory", genre: "Dance"),
            MusicRecommendation(title: "Brave", artist: "Sara Bareilles", genre: "Pop"),
            MusicRecommendation(title: "I Am Woman", artist: "Helen Reddy", genre: "Pop"),
            MusicRecommendation(title: "We Are Young", artist: "fun. ft. Janelle Monáe", genre: "Pop"),
            MusicRecommendation(title: "Ain't Nobody Gonna Turn Me Around", artist: "J. Moss", genre: "Gospel"),
            MusicRecommendation(title: "Nothing's Gonna Stop Us Now", artist: "Starship", genre: "Rock"),
            MusicRecommendation(title: "Every Breath You Take", artist: "The Police", genre: "Rock"),
            MusicRecommendation(title: "You Are the Best Thing", artist: "Ray LaMontagne", genre: "Indie")
           ]

           var recommendations: [MusicRecommendation]
           
           if averageMood < 3 {
               recommendations = sadSongs
           } else if averageMood >= 3 && averageMood < 4.5 {
               recommendations = feelGoodSongs
           } else {
               recommendations = motivationalSongs
           }

           return recommendations.shuffled().prefix(3).map { $0 } // Randomize and return 3 recommendations
       }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mood and Stress Insights")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                // Average mood and stress insights
                VStack(alignment: .leading, spacing: 10) {
                    Text("Average Mood: \(averageMood, specifier: "%.1f")")
                        .font(.headline)
                    Text(moodInsights)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)

                    Text("Average Stress: \(averageStress, specifier: "%.1f")")
                        .font(.headline)
                    Text(stressInsights)
                        .font(.body)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)

                    // Trend Insights
                    Text("Mood Trend: \(moodTrend)")
                        .font(.headline)
                    Text("Stress Trend: \(stressTrend)")
                        .font(.body)
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(10)

                    // Recommendations
                    Text("Recommendations:")
                        .font(.headline)
                    Text(recommendations)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)

                    // Music Recommendations Section
                    Text("Music Recommendations:")
                        .font(.headline)

                    // Display Music Recommendations
                    ForEach(musicRecommendations) { recommendation in
                        VStack(alignment: .leading) {
                            Text(recommendation.title)
                                .font(.body)
                                .fontWeight(.bold)
                            Text("by \(recommendation.artist) - \(recommendation.genre)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                }
                .padding()

                // Mood and Stress Line Chart
                Text("Mood and Stress Over Time")
                    .font(.headline)
                    .padding(.top, 10)

                Chart {
                    ForEach(moodLogs.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Date", moodLogs[index].date, unit: .day), // Use the date for the x-axis
                            y: .value("Mood", moodLogs[index].moodRating)
                        )
                        .foregroundStyle(Color.blue)

                        LineMark(
                            x: .value("Date", moodLogs[index].date, unit: .day), // Use the date for the x-axis
                            y: .value("Stress", moodLogs[index].stressLevel)
                        )
                        .foregroundStyle(Color.red)
                    }
                }
                .frame(height: 300)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .chartYScale(domain: 0...5)

                Spacer()
                    .padding()
            }
            .padding()
        }
        .navigationTitle("Mood Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for SwiftUI's design canvas
struct MoodInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        MoodInsightsView(moodLogs: [
            MoodLog(moodRating: 5, stressLevel: 1, date: Date()),
            MoodLog(moodRating: 3, stressLevel: 2, date: Date().addingTimeInterval(-86400)), // 1 day ago
            MoodLog(moodRating: 2, stressLevel: 3, date: Date().addingTimeInterval(-86400 * 2)) // 2 days ago
        ])
    }
}

// Define the MusicRecommendation structure
struct MusicRecommendation: Identifiable {
    let id = UUID() // Unique identifier
    var title: String
    var artist: String
    var genre: String
}
