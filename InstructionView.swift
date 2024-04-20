//
//  MenuView.swift
//  StretchDesk
//
//  Created by Hada Melino on 18/02/24.
//

import AVKit
import SwiftUI

struct InstructionView: View {
    
    @Binding var isShowInstruction: Bool
    
    var body: some View {
        VStack (spacing: 20) {
            VStack(alignment: .trailing) {
                Button("􀆄") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowInstruction = false
                    }
                }
                .offset(x: 70)
                .font(.title2)
                 
                 Text("Hello Apple team! Welcome to StretchDesk 🥳")
                     .font(.title)
                     .multilineTextAlignment(.center)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    Text("Here are some exercises you can try, along with recommended repetitions and duration based on my research. Feel free to adjust them to suit your preferences by tapping the left most button (timer). \n\nThe timer has three different colors to indicate the detection output:\n- Yellow\t: The app is waitting for your movement \n- Green\t: The hand movement matches the current exercise and will start counting down \n- Red\t\t: The detected movement does not match with the current exercise \n\nLet's begin with the Wrist Shake Exercise, followed by the Wrist Circles Exercise. The detailed instructions for each exercise movement are provided below. Have a good experience!\n")
                    HStack(alignment: .top, spacing: 20) {
                        GifImage("WS")
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Wrist Shake Exercise")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            
                            Text("Put your hands in front of you with palms facing downwards, let your wrists loose, and shake up and down several times to boost circulation and relieve stiffness.")
                        }
                        
                    }
                    
                    HStack(alignment: .top, spacing: 20) {
                        GifImage("WC")
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Wrist Circles Exercise")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            
                            Text("Position your hands with your palm facing down, imagine drawing a circle in the air with your fingertips. Maintain a smooth and controlled motion as you rotate your wrist in a circular pattern.")
                        }
                    }
                }
                .padding()
            }
        }
       
        
    }
    
}


