//
//  ProfileSummary.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 10/01/25.
//

import SwiftUI


struct ProfileSummary: View {
    var profile: Profile
    @Environment(ModelData.self) var modelData
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading){
                    Text(profile.username)
                        .bold()
                        .font(.title)
                    
                    Text("Notifications: \(profile.prefersNotifications ? "On": "Off" )")
                    
                    Text("Seasonal Photos: \(profile.seasonalPhoto.rawValue)")
                    
                    Text("Goal Date: ") + Text(profile.goalDate, style: .date)
                }
                .padding(.leading,20)
                .padding(.bottom,-5)
                
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Recent Hikes")
                        .font(.headline)
                        .padding(.leading,20)
                        .padding(.bottom,-5)
                    
                    HikeView(hike: modelData.hikes[0])
                }
               
                
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Completed Badges")
                        .font(.headline)
                    
                    
                    ScrollView(.horizontal) {
                        HStack {
                            HikeBadge(name: "First Hike")
                            HikeBadge(name: "Earth Day")
                                .hueRotation(Angle(degrees: 90))
                            HikeBadge(name: "Tenth Hike")
                                .grayscale(0.5)
                                .hueRotation(Angle(degrees: 45))
                        }
                        .padding(.bottom)
                        .padding(.leading,-5)
                    }
                }
                .padding(.leading,20)
                .padding(.bottom,-5)
                
                
               
                
            }
        }
    }
}


#Preview {
    ProfileSummary(profile: Profile.default)
        .environment(ModelData())
}
