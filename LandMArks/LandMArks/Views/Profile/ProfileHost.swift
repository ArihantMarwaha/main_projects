//
//  ProfileHost.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 10/01/25.
//

import SwiftUI


//The ProfileHost view will host both a static, summary view of profile information and an edit mode.

struct ProfileHost: View {
    @Environment(\.editMode) var editMode
    
    //Read the user’s profile data from the environment to pass control of the data to the profile host.
    @Environment(ModelData.self) var modelData
    @State private var draftProfile = Profile.default
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                if editMode?.wrappedValue == .active {
                    Button("Cancel", role: .cancel) {
                        draftProfile = modelData.profile
                        editMode?.animation().wrappedValue = .inactive
                    }
                    .padding(.leading)
                }
                Spacer()
                EditButton()
                    .padding()
    
            }
            
            
            if editMode?.wrappedValue == .inactive {
                //To avoid updating the global app state before confirming any edits ,the editing view operates on a copy of itself.
                ProfileSummary(profile: modelData.profile)
            } else {
                ProfileEditor(profile: $draftProfile)
                    .onAppear {
                        draftProfile = modelData.profile
                    }
                    .onDisappear {
                        modelData.profile = draftProfile
                    }
            }
        }
        
    }
}


#Preview {
    ProfileHost()
        .environment(ModelData())
}
