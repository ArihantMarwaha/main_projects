//
//  ProfileEditor.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 10/01/25.
//

import SwiftUI


struct ProfileEditor: View {
    @Binding var profile: Profile
    
    var dateRange: ClosedRange<Date> {
           let min = Calendar.current.date(byAdding: .year, value: -1, to: profile.goalDate)!
           let max = Calendar.current.date(byAdding: .year, value: 1, to: profile.goalDate)!
           return min...max
       }
    
    
    var body: some View {
        List {
            
            //1.
            HStack {
                Text("Username")
                Spacer()
                TextField("Username", text: $profile.username)
                    .foregroundStyle(.secondary)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.trailing)
                
            }
            
            //2.
            Toggle(isOn: $profile.prefersNotifications) {
                Text("Enable Notifications")
            }
            
            //.3
            Picker("Seasonal Photo", selection: $profile.seasonalPhoto) {
                ForEach(Profile.Season.allCases) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            
            //4.
            DatePicker(selection: $profile.goalDate, in: dateRange, displayedComponents: .date) {
                           Text("Goal Date")
                       }
        }
        .foregroundStyle(.black)
        .background(Color.white)
    }
}



#Preview {
    ProfileEditor(profile: .constant(.default))
}
