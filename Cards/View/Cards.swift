//
//  Cards.swift
//  Cards
//
//  Created by Алексей Колыченков on 17.08.2025.
//
import UIKit

protocol FlippableView: UIView {
    var isFlipped: Bool { get set }
    var flipCompletionHandler: ((FlippableView) -> Void)? { get set }
    func flip()
}

class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    var color: UIColor! //цвет фигуры
    var cornerRadius = 20
    var isFlipped: Bool = false {
        didSet {
            self.setNeedsDisplay() //перерисует вью при смене значения, треггерит draw
        }
    }
    var flipCompletionHandler: ((any FlippableView) -> Void)? //позволит выполнить произвольный код после того, как карточка будет перевернута
    
    // внутренний отступ представления
    private let margin: Int = 10
    // представление лицевой стороны карты
    lazy var frontSideView: UIView = getFrontSideView()
    // представление обратной стороны карты
    lazy var backSideView: UIView = getBackSideView()
    
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        setupBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // удаляем добавленные ранее дочерние представления
        backSideView.removeFromSuperview()
        frontSideView.removeFromSuperview()
        
        // добавляем новые представления
        if isFlipped {
            self.addSubview(backSideView)
            self.addSubview(frontSideView)
        } else {
            self.addSubview(frontSideView)
            self.addSubview(backSideView)
        }
    }
    
   
    private var anchPoint: CGPoint = CGPoint(x: 0, y: 0)  // точка привязки
    private var originPoint: CGPoint = .zero //исходные координаты игральной карточки
    
    // ОБРАБОТКА ПЕРЕМЕЩЕНИЯ КАРТОЧКИ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // изменяем координаты точки привязки
        ///anchPoint хранит координаты первого нажатия и в дальнейшем используется для того, чтобы верно рассчитывать значение свойства frame
        anchPoint.x = touches.first!.location(in: window).x - frame.minX
        anchPoint.y = touches.first!.location(in: window).y - frame.minY
        
        // сохраняем исходные координаты
        originPoint = frame.origin
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //вычитаем anchorPoint чтобы не было резкого скачка карточки
        self.frame.origin.x = touches.first!.location(in: window).x -
        anchPoint.x
        self.frame.origin.y = touches.first!.location(in: window).y -
        anchPoint.y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // анимировано возвращаем карточку в исходную позицию
//        UIView.animate(withDuration: 0.5) {
//            self.frame.origin = self.originPoint
//
//            if self.transform.isIdentity {
//                self.transform = CGAffineTransform(rotationAngle: .pi)
//            } else {
//                self.transform = .identity //отменяет преобразования
//            }
//
//        }
        //перед переворотом происходит проверка, была ли перемещена карточка (изменились ли ее исходные координаты)
        if self.frame.origin == self.originPoint {
            flip() //Если перемещения не было(был просто клик), то карточка переворачивается
        }
    }
    
    func flip() {
        // определяем, между какими представлениями осуществить переход
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: .transitionFlipFromTop) { _ in
            // обработчик переворота
            self.flipCompletionHandler?(self)
        }
        isFlipped.toggle()
    }
    
    /// настройка границ
    private func setupBorders() {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
    }
    
    ///возвращает представление для лицевой стороны карточки
    private func getFrontSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        // скругляем углы корневого слоя
        view.layer.masksToBounds = true //клипаем саблееры по границам род. леера
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        // создаем вью подложку с отступами от краев основной вью, чтобы фигуры на лицевой стороне не граничили с краями представления
        let shapeView = UIView(frame: CGRect(x: margin, y: margin, width: Int(self.bounds.width) - margin*2, height: Int(self.bounds.height) - margin*2))
        view.addSubview(shapeView)
        
        // создание слоя с фигурой
        let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
        shapeView.layer.addSublayer(shapeLayer)
        
        return view
    }
    
    /// возвращает рандомное вью для обратной стороны карточки
    private func getBackSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        switch ["circle", "line"].randomElement()! {
        case "circle":
            let layer = BackSideCircle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        case "line":
            let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.blue.cgColor)
            view.layer.addSublayer(layer)
        default:
            break
        }
        
        return view
    }
}
