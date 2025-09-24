//
//  BoardGameController.swift
//  Cards
//
//  Created by Алексей Колыченков on 17.08.2025.
//

import UIKit

class BoardGameController: UIViewController {
    //количество пар уникальных карточек
    var cardsPairsCounts = 8
    // размеры представлений игральных карточек
    private var cardSize: CGSize {
        CGSize(width: 80, height: 120)
    }
    
    // игральные карточки
    var cardViews = [UIView]()
    private var flippedCards = [any FlippableView]() //Значение в данном свойстве будут использоваться для сравнения идентичности карточек
    //настроенный экземпляр игры
    private lazy var game: Game = getNewGame()
    
    /// получаем доступ к текущему окну
    private var currentWindow: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return windowScene.windows.first
    }
    
    private lazy var startBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50), primaryAction: startGameTapped)
        btn.center.x = view.center.x
        // определяем отступ сверху Safe Area
        let topPadding = currentWindow?.safeAreaInsets.top ?? 0
        // устанавливаем координату Y кнопки в соответствии с отступом
        btn.frame.origin.y = topPadding
        
        btn.setTitle("Начать игру", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.gray, for: .highlighted)
        btn.backgroundColor = .systemGray4
        btn.layer.cornerRadius = 10
        
        return btn
    }()
    
    private lazy var startGameTapped = UIAction { [weak self] _ in
        guard let self else { return }
        self.game = self.getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
    
    private lazy var boardGameView: UIView = {
        // отступ игрового поля от ближайших элементов
        let margin: CGFloat = 10
        
        let boardView = UIView()
        // указываем координаты
        // x
        boardView.frame.origin.x = margin
        
        guard let window = currentWindow else { return boardView }
        
        // y
        boardView.frame.origin.y = startBtn.frame.maxY + margin
        
        // рассчитываем ширину
        boardView.frame.size.width = view.frame.width - margin * 2
        // рассчитываем высоту c учетом нижнего отступа
        let bottomPadding: CGFloat = window.safeAreaInsets.bottom
        boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - margin - bottomPadding
        
        boardView.layer.cornerRadius = 10
        boardView.backgroundColor = UIColor(red: 0.1, green: 0.9, blue: 0.1,
                                            alpha: 0.3)
        
        return boardView
    }()
    
    
    override func loadView() {
        super.loadView()
        view.addSubview(startBtn)
        view.addSubview(boardGameView)
    }

    
    private func placeCardsOnBoard(_ cards: [UIView]) {
        // удаляем все имеющиеся на игровом поле карточки
        for card in cardViews {
            card.removeFromSuperview()
        }
        self.cardViews = cards
        
        // предельные координаты размещения карточки
        var cardMaxXCoordinate: Double { boardGameView.frame.width - cardSize.width }
        var cardMaxYCoordinate: Double { boardGameView.frame.height - cardSize.height }
        
        for card in cardViews {
            // для каждой карточки генерируем случайные координаты
            let randomXCoordinate = Double.random(in: 0.0...cardMaxXCoordinate)
            let randomYCoordinate = Double.random(in: 0.0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            // размещаем карточку на игровом поле
            boardGameView.addSubview(card)
        }
    }
    
    /// генерация массива карточек UIView на основе данных Модели
    private func getCardsBy(modelData: [Card]) -> [UIView] {
        // хранилище для представлений карточек
        var cardViews = [UIView]()
        // фабрика карточек
        let cardViewFactory = CardViewFactory()
        // перебираем массив карточек в Модели
        for (index, cardModel) in modelData.enumerated() {
            // Для каждой карточки в Модели генерируются по две идентичные карточки в Представлении (параметры cardOne и cardTwo)
            
            //первый экземпляр карты
            let cardViewOne = cardViewFactory.getView(cardModel.type, size: cardSize, color: cardModel.color)
            cardViewOne.tag = index //для связи карточки в Модели и карточки в Представлении
            
            //второй экземпляр карты
            let cardViewTwo = cardViewFactory.getView(cardModel.type, size: cardSize, color: cardModel.color)
            cardViewTwo.tag = index
            
            cardViews.append(cardViewOne)
            cardViews.append(cardViewTwo)
        }
        
        // добавляем всем картам обработчик переворота
        for cardView in cardViews {
            (cardView as! (any FlippableView)).flipCompletionHandler = { [weak self] flippedCard in
                self?.handleCardFlip(flippedCard)
            }
        }
        return cardViews
    }
    
    private func handleCardFlip(_ flippedCard: any FlippableView) {
        // поднимаем карточку вверх иерархии
        flippedCard.superview?.bringSubviewToFront(flippedCard)
        
        // добавляем или удаляем карточку
        if flippedCard.isFlipped && self.flippedCards.count < 2 {
            self.flippedCards.append(flippedCard)
        } else if let index = self.flippedCards.firstIndex(where: { $0.tag == flippedCard.tag }) {
            self.flippedCards.remove(at: index)
        }
        
        // если перевернуто 2 карточки
        if self.flippedCards.count == 2 {
            self.processFlippedCards()
        }
    }
    
    private func processFlippedCards() {
        // получаем карточки из данных модели по tag в который записали index карточки
        let firstCard: Card = game.cards[self.flippedCards.first!.tag]
        let secondCard: Card = game.cards[self.flippedCards.last!.tag]
        
        // Проверка на идентичные карточки
        if game.checkCard(firstCard, secondCard) {
            // сперва анимировано скрываем их
            UIView.animate(withDuration: 0.6, delay: .zero, options: .curveEaseInOut) {
                self.flippedCards.forEach {
                    $0.layer.opacity = 0
                }
            } completion: { _ in
                // после чего удаляем из иерархии
                self.flippedCards.forEach { $0.removeFromSuperview() }
                self.flippedCards.removeAll()
            }
        } else {
            // переворачиваем карточки рубашкой вверх
            for card in flippedCards {
                UIView.animate(withDuration: 0.8) {
                    card.flip()
                }
            }
        }
    }
    
    private func getNewGame() -> Game {
        let game = Game()
        game.cardsCount = self.cardsPairsCounts
        game.generateCards()
        return game
    }
}
