//
//  Profile.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 10/01/25.
//

import Foundation

struct Profile {
    var username: String
    var prefersNotifications : Bool = false
    var seasonalPhoto : Season = Season.winter
    var goalDate : Date = Date()


    static let `default` = Profile(username: "Arihant")

    enum Season: String, CaseIterable, Identifiable {
        case spring = "🌷"
        case summer = "🌞"
        case autumn = "🍂"
        case winter = "☃️"


        var id: String { rawValue }
    }
}
