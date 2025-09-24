//
//  Ball.swift
//  Created by Алексей Колыченков on 26.08.2025.
//

import UIKit

protocol BallProtocol {
    init(color: UIColor, radius: Int, coordinate: CGPoint)
}

public class Ball: UIView, @preconcurrency BallProtocol {
     required public init(color: UIColor, radius: Int, coordinate: CGPoint) {
         // создание графического элемента - прямоугольник
        super.init(frame:
                    CGRect(x: coordinate.x,
                           y: coordinate.y,
                           width: CGFloat(radius * 2),
                           height: CGFloat(radius * 2)))
         //вторая фаза иниц, можем обращаться в self и настраивать себя
         self.layer.cornerRadius = self.bounds.width / 2 //превращаем его в круг
         self.backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
