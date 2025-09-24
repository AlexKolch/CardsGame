//
//  SquareArea.swift
//  
//
//  Created by Алексей Колыченков on 26.08.2025.
//

import UIKit

protocol SquareAreaProtocol {
    init(size: CGSize, color: UIColor)
    // установить шарики в область
    func setBalls(withColors ballsColor: [UIColor], radius: Int)
}

public class SquareArea: UIView, @preconcurrency SquareAreaProtocol {
    // коллекция всех шариков
    private var balls: [UIView] = []
    // аниматор графических объектов
    private var animator: UIDynamicAnimator?
    // обработчик перемещений объектов
    private var snapBehavior: UISnapBehavior? // делаем опциональным, чтобы потом очистить ресурсы когда обработчик станет не нужным
    // обработчик столкновений
    private var collisionBehavior: UICollisionBehavior
    
    required public init(size: CGSize, color: UIColor) {
        //Первая фаза инита установка своих св-в, после чего вызов super.init
        collisionBehavior = UICollisionBehavior(items: []) // создание обработчика столкновений
        // строим прямоугольную графическую область
        super.init(frame: CGRect(
                           x: 0,
                           y: 0,
                           width: size.width,
                           height: size.height))
        
        //вторая фаза иниц, можем обращаться в self и настраивать себя
        self.backgroundColor = color
        // указываем границы прямоугольной области как объекты взаимодействия, чтобы об них могли ударяться шарики
        collisionBehavior.setTranslatesReferenceBoundsIntoBoundary(
            with: UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0))
        // подключаем аниматор с указанием на сам класс
        animator = UIDynamicAnimator(referenceView: self)
        // подключаем к аниматору обработчик столкновений
        animator?.addBehavior(collisionBehavior)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //При нажатии на определенную точку в прямоугольной области будет определяться, соответствуют ли координаты нажатия текущему положению одного из шариков
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self) //координаты относительно площадки, на которой расположены шарики
    // определяем, относятся ли координаты касания к какому-либо из шариков
            for ball in balls {
                if ball.frame.contains(touchPoint) {
            //Если находится соответствие, то в свойство snapBehavior записываются данные о шарике, с которым в текущий момент происходит взаимодействие, и о координатах касания
                    snapBehavior = UISnapBehavior(item: ball, snapTo: touchPoint)
                    snapBehavior?.damping = 0.5 // плавность и затухание при движении шарика
                    animator?.addBehavior(snapBehavior!) // указываем, что обрабатываемое классом UISnapBehavior поведение объекта должно быть анимировано
                }
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            if let snapBehavior {
                snapBehavior.snapPoint = touchPoint // изменяем координаты объекта
            }
        }
    }
    
    // Этот метод служит для решения одной очень важной задачи — очистки используемых ресурсов
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let snapBehavior {
            animator?.removeBehavior(snapBehavior)
        }
        snapBehavior = nil //После того как взаимодействие с шариком окончено, хранить информацию об обработчике поведения уже нет необходимости
    }
    
    ///создание экземпляров типа Ball и размещение их на прямоугольной площадке
   public func setBalls(withColors ballsColor: [UIColor], radius: Int) {
        // перебираем переданные цвета. Шариков создастся столько, сколько передадим цветов. Один цвет — один шарик
        for color in ballsColor {
            // рассчитываем координаты левого верхнего угла шарика
            let xRandom: CGFloat = CGFloat.random(in: 0...frame.width)
            let yRandom: CGFloat = CGFloat.random(in: 0...frame.height)
            // создаем экземпляр сущности "Шарик"
            let bal = Ball(color: color, radius: radius, coordinate: CGPoint(x: xRandom, y: yRandom))
            self.addSubview(bal)
            self.balls.append(bal)
            collisionBehavior.addItem(bal) // добавляем шарик в обработчик столкновений
        }
    }
    
    
}
