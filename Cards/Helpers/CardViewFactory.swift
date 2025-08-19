//
//  CardViewFactory.swift
//  Cards
//
//  Created by Алексей Колыченков on 17.08.2025.
//

import UIKit

final class CardViewFactory {
    
    func getView(_ shape: CardType, size: CGSize, color: CardColor) -> UIView {
        let frameView = CGRect(origin: .zero, size: size)
        let colorView = getViewColor(by: color)
        
        switch shape {
        case .circle:
           return CardView<CircleShape>(frame: frameView, color: colorView)
        case .cross:
            return CardView<CrossShape>(frame: frameView, color: colorView)
        case .square:
            return CardView<SquareShape>(frame: frameView, color: colorView)
        case .fill:
            return CardView<FillShape>(frame: frameView, color: colorView)
        }
    }
    
    private func getViewColor(by modelColor: CardColor) -> UIColor {
        switch modelColor {
        case .red:
                .red
        case .green:
                .green
        case .black:
                .black
        case .gray:
                .gray
        case .brown:
                .brown
        case .yellow:
                .yellow
        case .purple:
                .purple
        case .orange:
                .orange
        }
    }
}
