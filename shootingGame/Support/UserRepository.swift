//
//  UserRepository.swift
//  shootingGame
//
//  Created by Mac on 2019/11/28.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

class UserRepository {
    let userDefaults: UserDefaults
    init(userDefalut: UserDefaults = .standard) {
        self.userDefaults = userDefalut
    }
    
    func getScore(for name: String) -> Int {
        if let score = userDefaults.value(forKey: "\(name)HighestScore") as? Int {
            return score
        } else {
            return -1
        }
    }
    
    func storageScore(score: Int, for name: String) {
        userDefaults.set(score, forKey: "\(name)HighestScore")
    }
    
    func resetStorage() {
        userDefaults.removeObject(forKey: "duckHighestScore")
        userDefaults.removeObject(forKey: "targetHighestScore")
    }
    
}
