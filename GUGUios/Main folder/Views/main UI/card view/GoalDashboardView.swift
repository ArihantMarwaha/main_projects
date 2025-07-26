//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct GoalDashboardView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var showingCreator = false
    @State private var selectedCategory: GoalCategory? = nil
    @State private var searchText = ""
    
    private var filteredGoals: [Goal] {
        let categoryFiltered = selectedCategory == nil
            ? goalsManager.goals
            : goalsManager.goals
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter { goal in
            goal.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    DailySummaryView(goalsManager: goalsManager)
                        .transition(.scale.combined(with: .opacity))
                    
                    
                    //fot category filteration
                    
                    /*
                     
                     CategoryFilterView(
                         selectedCategory: $selectedCategory,
                         categories: goalsManager.categories
                     )
                     .transition(.slide)
                     */
                  
                    
                    SearchBar(text: $searchText)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredGoals) { goal in
                            GoalCardView(
                                goal: goal,
                                tracker: goalsManager.trackers[goal.id]
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                            .id(goal.id)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4), value: filteredGoals.map { $0.id })
                }
            }
            .navigationTitle("Daily Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showingCreator = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreator) {
            CustomGoalCreatorView()
                .environmentObject(goalsManager)
        }
    }
}

struct GoalDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = GoalsManager()
        
        return Group {
            GoalDashboardView()
                .environmentObject(previewManager)
                .previewDisplayName("Light Mode")
            
            GoalDashboardView()
                .environmentObject(previewManager)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

