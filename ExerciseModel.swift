//
//  ExerciseModel.swift
//  StretchDesk
//
//  Created by Hada Melino on 22/02/24.
//

import Foundation


struct ExerciseModel {
    
    var name: String
    var repetition: Int = 3
    var timePerRep: Int = 15
    var timeRemaining: Int
    var completedRepetition: Int = 0
    
    var isRunning: Bool {
        timeRemaining != timePerRep || completedRepetition != 0
    }
    
    var isCompleted: Bool {
        completedRepetition == repetition
    }
    
    init(name: String) {
        self.name = name
        self.timeRemaining = timePerRep
    }
    
    mutating func startOver() {
        self.repetition = 3
        self.timePerRep = 15
        self.timeRemaining = timePerRep
        self.completedRepetition = 0
    }
    
    static func makeDefaultWristShakeExercise() -> ExerciseModel {
        return ExerciseModel(name: "Wrist Shake Exercise")
    }
    
    static func makeDefaultWristCirclesExercise() -> ExerciseModel {
        return ExerciseModel(name: "Wrist Circles Exercise")
    }
    
}
