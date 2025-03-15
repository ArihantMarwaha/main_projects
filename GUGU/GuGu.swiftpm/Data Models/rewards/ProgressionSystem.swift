import Foundation

struct SkillNode: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    var level: Int
    var maxLevel: Int
    var requiredNodes: [UUID]
    var isUnlocked: Bool
    var skillPoints: Int
    
    mutating func levelUp() {
        if level < maxLevel {
            level += 1
            skillPoints += level * 10
        }
    }
}

enum ProgressionCategory: String, Codable {
    case personalDevelopment
    case healthAndWellness
    case productivity
    case learning
    case socialConnection
}

@MainActor
class ProgressionSystem: ObservableObject {
    @Published var skillTree: [SkillNode]
    @Published var experiencePoints: Int
    @Published var level: Int
    
    init() {
        self.skillTree = []
        self.experiencePoints = 0
        self.level = 1
    }
    
    func gainExperience(_ points: Int, in category: ProgressionCategory) {
        experiencePoints += points
        
        switch category {
        case .personalDevelopment: experiencePoints += points / 2
        case .productivity: experiencePoints += points / 3
        default: break
        }
        
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        let baseXPRequirement = 100
        let levelUpRequirement = baseXPRequirement * (level + 1)
        
        if experiencePoints >= levelUpRequirement {
            level += 1
            unlockSkillNodes()
        }
    }
    
    private func unlockSkillNodes() {
        for index in skillTree.indices {
            if shouldUnlockSkillNode(at: index) {
                skillTree[index].isUnlocked = true
            }
        }
    }
    
    private func shouldUnlockSkillNode(at index: Int) -> Bool {
        let node = skillTree[index]
        return node.requiredNodes.allSatisfy { requiredNodeId in
            skillTree.first(where: { $0.id == requiredNodeId })?.isUnlocked ?? false
        }
    }
} 