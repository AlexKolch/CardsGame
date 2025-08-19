//
//  Game.swift
//  Cards
//
//  Created by Алексей Колыченков on 17.08.2025.
//

import Foundation

final class Game {
    // количество пар уникальных карточек
    var cardsCount = 0
    // массив сгенерированных карточек
    var cards = [Card]()
    
    /// генерация массива случайных карт
    func generateCards() {
        var cards: [Card] = []
        
        for _ in 0...cardsCount {
            let randomCard = (type: CardType.allCases.randomElement()!, color: CardColor.allCases.randomElement()!)
            cards.append(randomCard)
        }
        self.cards = cards
    }
    
    func checkCard(_ firstCard: Card, _ secondCard: Card) -> Bool {
        firstCard.type == secondCard.type && firstCard.color == secondCard.color ? true : false
    }
}
