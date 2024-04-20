//
//  ExerciseModel.swift
//  wwdc24
//
//  Created by Hada Melino on 19/02/24.
//

import Combine
import Foundation


class ExerciseHandler: ObservableObject {
    
    private var timerCancellable: Cancellable?
    private var timerValueCancellable: Cancellable?
    
    // Exercise Properties
    @Published var currentExerciseIndex = 0 {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @Published var completionMessage: String = "" {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    @Published var isReadyToStart: Bool = true {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    var exercises: [ExerciseModel] = [
        .makeDefaultWristShakeExercise(),
        .makeDefaultWristCirclesExercise()
    ]
    
    private var timer = Timer.publish(every: 1, on: .main, in: .default)
    
    init() {
        bindTimer()
    }
    
    func bindTimer() {
        
        timerValueCancellable = timer.sink { _ in
            
            var currentExercise = self.exercises[self.currentExerciseIndex]
            
            if currentExercise.timeRemaining > 0 {
                
                currentExercise.timeRemaining -= 1
                
                self.exercises[self.currentExerciseIndex] = currentExercise
                
            } else {
                self.isReadyToStart = false
                
                currentExercise.completedRepetition += 1
                
                self.exercises[self.currentExerciseIndex] = currentExercise

                self.checkCompletion()

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    
                    if currentExercise.completedRepetition == currentExercise.repetition {
                        if self.currentExerciseIndex < self.exercises.count - 1 {
                            self.currentExerciseIndex += 1
                        }
                    }
                    
                    if !self.exercises.allSatisfy({ $0.repetition == $0.completedRepetition }) {
                        self.exercises[self.currentExerciseIndex].timeRemaining = self.exercises[self.currentExerciseIndex].timePerRep
                    }
                    
                    self.isReadyToStart = true
                }
            
                self.stopCountdown()
            }
            
        }
    }

    func startCountdown() {
        if timerCancellable == nil {
            bindTimer()
            timerCancellable = timer.connect()
        }
    }
    
    func stopCountdown() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
     
    func checkCompletion() {
        if exercises[currentExerciseIndex].timeRemaining == 0 {
            if exercises.allSatisfy({ $0.repetition == $0.completedRepetition }) {
                completionMessage = "🎉📣 Congratulations! You have finished all the exercises 🎉📣"
            } else if exercises[currentExerciseIndex].completedRepetition == exercises[currentExerciseIndex].repetition {
                completionMessage = "💪 Congratulations! You have finished \(exercises[currentExerciseIndex].name) 💪"
            } else {
                completionMessage = "✅ Congratulations! You have finished a repetition ✅"
            }
        }
    }
}
