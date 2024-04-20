//
//  QLImage.swift
//  StretchDesk
//
//  Created by Hada Melino on 22/02/24.
//

import SwiftUI
import FLAnimatedImage

struct GifImage: UIViewRepresentable {
    private let animatedView = FLAnimatedImageView()
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let url = Bundle.main.url(forResource: name, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        let gif = FLAnimatedImage(animatedGIFData: data)

        animatedView.animatedImage = gif
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.clipsToBounds = true
        animatedView.layer.cornerRadius = 16
        
        view.addSubview(animatedView)
        
        NSLayoutConstraint.activate([
            animatedView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animatedView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GifImage>) {
        
    }

}
