//
//  EmojiEmitter.swift
//  StretchDesk
//
//  Created by Hada Melino on 23/02/24.
//

import Foundation
import UIKit
import SwiftUI

struct EmojiEmitter: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let emojiEmitter = CAEmitterLayer()
        
        emojiEmitter.position = .init(x: 1000, y: 1200)
        emojiEmitter.emitterShape = .line
        emojiEmitter.emitterSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        
        let emojis = ["🔥", "🥵", "😁", "📣", "👏", "Keep going!"]
        
        var emojiCells = [CAEmitterCell]()
        
        for emoji in emojis {
            let cell = makeEmojiEmitterCell(emoji: emoji)
            emojiCells.append(cell)
        }
        
        emojiEmitter.emitterCells = emojiCells
        view.layer.addSublayer(emojiEmitter)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func makeEmojiEmitterCell(emoji: String) -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        cell.birthRate = 1
        cell.lifetime = 10
        cell.lifetimeRange = 0
        cell.velocity = 150
        cell.emissionRange = CGFloat.pi
        
        if let emojiImage = imageFromEmoji(emoji: emoji) {
            cell.contents = emojiImage.cgImage
        }
        
        return cell
    }
    
    func imageFromEmoji(emoji: String) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 32)
        label.sizeToFit()
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
    
}
