//
//  TimerView.swift
//  StretchDesk
//
//  Created by Hada Melino on 22/02/24.
//

import SwiftUI

struct TimerSettingView: View {
    
    @Binding var isShowTimerSetting: Bool
    @Binding var exercises: [ExerciseModel]
    @Binding var currentExerciseIndex: Int
    @Binding var timerBgColor: Color
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Button("􀆄") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowTimerSetting = false
                    }
                }
                .font(.title2)
                
                Button("Start Over") {
                    exercises[currentExerciseIndex].startOver()
                    timerBgColor = .yellow
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            VStack (alignment: .leading, spacing: 10) {
                
                Text("Once you've finished setting up the values, you can start doing the exercise to the camera!")
                
                Text("Current Exercise\t: \(exercises[currentExerciseIndex].name)")
                    .fontWeight(.bold)
                
                Text("Time Remaining\t: \(exercises[currentExerciseIndex].timeRemaining)")
                
                HStack {
                    Stepper("Time per rep\t\t: \(exercises[currentExerciseIndex].timePerRep)", onIncrement: {
                        exercises[currentExerciseIndex].timePerRep += 1
                        exercises[currentExerciseIndex].timeRemaining += 1
                    }, onDecrement: {
                        if exercises[currentExerciseIndex].timePerRep > 1 {
                            exercises[currentExerciseIndex].timePerRep -= 1
                            exercises[currentExerciseIndex].timeRemaining -= 1
                        }
                    })
                    .disabled(
                        exercises[currentExerciseIndex].isRunning ||
                        exercises[currentExerciseIndex].isCompleted
                    )
                }
                
                HStack {
                    Stepper("Repetition\t\t\t: \(exercises[currentExerciseIndex].completedRepetition) / \(exercises[currentExerciseIndex].repetition)", onIncrement: {
                        exercises[currentExerciseIndex].repetition += 1
                    }, onDecrement: {
                        if exercises[currentExerciseIndex].repetition > 1 {
                            exercises[currentExerciseIndex].repetition -= 1
                        }
                    })
                    .disabled(
                        exercises[currentExerciseIndex].isRunning ||
                        exercises[currentExerciseIndex].isCompleted
                    )
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            HStack {
                
                Button("Previous") {
                    if currentExerciseIndex > 0 {
                        currentExerciseIndex -= 1
                    }
                }
                .disabled(currentExerciseIndex == 0)
                .frame(maxWidth: .infinity)
                .tint(.blue)
                
                Button("Next") {
                    if currentExerciseIndex < exercises.count - 1 {
                        currentExerciseIndex += 1
                    }
                }
                .disabled(currentExerciseIndex == exercises.count - 1)
                .tint(.blue)
                .frame(maxWidth: .infinity)
            }
            
        }
        .frame(maxHeight: .infinity)
        
    }
}

