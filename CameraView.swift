//
//  CameraView.swift
//  StretchDesk
//
//  Created by Hada Melino on 10/02/24.
//

import Combine
import SwiftUI

struct CameraView: View {
    
    @State var cancellables = [AnyCancellable]()
    
    private var camera = Camera()
    @StateObject var exerciseHandler = ExerciseHandler()
    
    @State var instructions: String = "Make sure your hand is the frame"
    @State var predictionLabel: String = "Put your hands in the frame"
    @State var displayedImage: Image?
    @State var timerLabel: String = ""
    
    // Navigation properties
    @State var isShowInstruction: Bool = true
    @State var isShowTimerSetting: Bool = false
    
    @State var timerBgColor: Color = .yellow
    
    @State var shouldGenerateEmoji: Bool = false
    @State var xPos: Int = 0
    @State var yPos: Int = 0
    
    @State var messageToUserAfterCountDown: String = ""
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                if let displayedImage = displayedImage {
                    displayedImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }.task {
                await camera.start()
                
                let imageStream = camera.previewStream.map { $0.image }
                for await image in imageStream {
                    displayedImage = image!
                }
            }
            
            GeometryReader { geometry in
                EmojiEmitter()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(shouldGenerateEmoji ? 1 : 0)
                    .animation(.easeInOut(duration: 1))
            }
            
                        
            HStack (alignment: .top, spacing: 20) {
                
                // Timer Button
                Button("Current exercise: \(exerciseHandler.exercises[exerciseHandler.currentExerciseIndex].name) \(exerciseHandler.exercises[exerciseHandler.currentExerciseIndex].timeRemaining) s") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowTimerSetting = true
                    }
                }
                .tint(.white)
                .font(.system(size: 22, weight: .semibold))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25.0).fill(timerBgColor)
                )
                .frame(alignment: .leading)
                .opacity(isShowTimerSetting ? 0.0 : 1.0)
                .overlay(alignment: .topLeading) {
                    TimerSettingView(isShowTimerSetting: $isShowTimerSetting, exercises: $exerciseHandler.exercises, currentExerciseIndex: $exerciseHandler.currentExerciseIndex, timerBgColor: $timerBgColor)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 25.0).fill(.background)
                                .opacity(0.8)
                        )
                        .frame(height: 330)
                        .opacity(isShowTimerSetting ? 1.0 : 0.0)
                }
                
                
                VStack (spacing: 10) {
                    // Prediction Label
                    Text(predictionLabel).task {
                        let outputStream = camera.outputStream.map { $0 }
                                                
                        for await output in outputStream {
                            switch output {
                            case .actionDetected(let action):
                                switch action {
                                case .wristCirle:
                                    let label = "Wrist Circles Exercise"
                                    predictionLabel = label
                                    checkDetectionMatchability(actionName: label)
                                case .wristShake:
                                    let label = "Wrist Shake Exercise"
                                    predictionLabel = label
                                    checkDetectionMatchability(actionName: label)
                                case .background:
                                    exerciseHandler.stopCountdown()
                                    predictionLabel = "No Action Identified, try to move your hands as instructed on the right button"
                                    checkDetectionMatchability()
                                }
                            case .handsNotInframe:
                                predictionLabel = "Your hands are not in the frame"
                                shouldGenerateEmoji = false
                                timerBgColor = .yellow
                                exerciseHandler.stopCountdown()
                            case .detectingAction:
                                shouldGenerateEmoji = true
                                predictionLabel = "Detecting your exercise..."
                                timerBgColor = .yellow
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .font(.system(size: 32, weight: .medium))
                    .multilineTextAlignment(.center)
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(.background.opacity(0.8))
                    )
                    
                    Text(exerciseHandler.completionMessage)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12).fill(Color.brown.opacity(0.8))
                        }
                        .opacity(exerciseHandler.exercises[exerciseHandler.currentExerciseIndex].timeRemaining == 0 ? 1.0 : 0.0)
                        .animation(.bouncy())
                }
                
                
                // Instruction Button
                Button("􀅴") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowInstruction = true
                    }
                }
                .font(.title2)
                .tint(.blue)
                .padding()
                .background(
                    Circle().fill(.background.opacity(0.8))
                )
                .frame(width: 550, alignment: .trailing)
                .opacity(isShowInstruction ? 0.0 : 1.0)
                .overlay(alignment: .topTrailing) {
                    InstructionView(isShowInstruction: $isShowInstruction)
                        .frame(width: 500, height: 850, alignment: .trailing)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 25.0).fill(.background)
                        )
                        .opacity(isShowInstruction ? 1.0 : 0.0)
                }
                
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
        
        }
        
    }
    
    func checkDetectionMatchability(actionName: String = "") {
        
        if exerciseHandler.isReadyToStart {
            let currentIndex = exerciseHandler.currentExerciseIndex
            
            isShowTimerSetting = false

            if actionName == exerciseHandler.exercises[currentIndex].name {
                if exerciseHandler.isReadyToStart {
                    exerciseHandler.startCountdown()
                }
                shouldGenerateEmoji = true
                timerBgColor = .green
            } else {
                shouldGenerateEmoji = false
                timerBgColor = .red
                exerciseHandler.stopCountdown()
            }
        }
    }
    
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {
    
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
