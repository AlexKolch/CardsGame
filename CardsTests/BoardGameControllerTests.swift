import XCTest
@testable import Cards

class BoardGameControllerTests: XCTestCase {

    var sut: BoardGameController!
    var mockGame: MockGame!
    
    override func setUp() {
        super.setUp()
        mockGame = MockGame()
        sut = BoardGameController()
        sut.cardsPairsCounts = 2 // Ensure enough cards are generated for tags 0 and 1
        sut.game = mockGame
        sut.game.cardsCount = sut.cardsPairsCounts // Set cardsCount on the mock game
        sut.game.generateCards() // Generate cards for the mock game
        sut.loadViewIfNeeded() // Load the view to ensure outlets are connected
    }

    override func tearDown() {
        sut = nil
        mockGame = nil
        super.tearDown()
    }

    // MARK: - Mock Objects
    class MockFlippableView: UIView, FlippableView {
        var isFlipped: Bool = false
        var flipCompletionHandler: ((any FlippableView) -> Void)?
        var flipCalled = false
        
        func flip() {
            isFlipped.toggle()
            flipCalled = true
            flipCompletionHandler?(self)
        }
        
        static func == (lhs: MockFlippableView, rhs: MockFlippableView) -> Bool {
            return lhs.tag == rhs.tag
        }
    }
    
    class MockGame: Game {
        var checkCardResult = true
        override func checkCard(_ firstCard: Cards.Card, _ secondCard: Cards.Card) -> Bool {
            return checkCardResult
        }
    }

    // MARK: - Tests for handleCardFlip
    func testHandleCardFlip_addFirstCard() {
        // Given
        let card = MockFlippableView(frame: .zero)
        card.tag = 0
        card.isFlipped = true
        sut.flippedCards.removeAll()

        // When
        sut.handleCardFlip(card)

        // Then
        XCTAssertEqual(sut.flippedCards.count, 1)
        XCTAssertEqual(sut.flippedCards.first?.tag, card.tag)
    }

    func testHandleCardFlip_addSecondCard() {
        // Given
        let card1 = MockFlippableView(frame: .zero)
        card1.tag = 0
        card1.isFlipped = true
        let card2 = MockFlippableView(frame: .zero)
        card2.tag = 1
        card2.isFlipped = true
        sut.flippedCards.removeAll()
        sut.flippedCards.append(card1)

        // When
        sut.handleCardFlip(card2)

        // Then
        XCTAssertEqual(sut.flippedCards.count, 2)
        XCTAssertEqual(sut.flippedCards.last?.tag, card2.tag)
    }

    func testHandleCardFlip_removeCard() {
        // Given
        let card = MockFlippableView(frame: .zero)
        card.tag = 0
        card.isFlipped = false // Card is unflipped
        sut.flippedCards.removeAll()
        sut.flippedCards.append(card)

        // When
        sut.handleCardFlip(card)

        // Then
        XCTAssertTrue(sut.flippedCards.isEmpty)
    }
    
    func testHandleCardFlip_processFlippedCardsCalledWhenTwoCardsFlipped() {
        // Given
        let card1 = MockFlippableView(frame: .zero)
        card1.tag = 0
        card1.isFlipped = true
        let card2 = MockFlippableView(frame: .zero)
        card2.tag = 1
        card2.isFlipped = true
        sut.flippedCards.removeAll()
        sut.flippedCards.append(card1)

        let expectation = XCTestExpectation(description: "processFlippedCards should be called")
    
        class TestBoardGameController: BoardGameController {
            var processFlippedCardsCalled = false
            var expectation: XCTestExpectation?
            
            override func processFlippedCards() {
                super.processFlippedCards()
                processFlippedCardsCalled = true
                expectation?.fulfill()
            }
        }
        
        let testSut = TestBoardGameController()
        testSut.game = mockGame
        testSut.loadViewIfNeeded()
        testSut.flippedCards.append(card1)
        testSut.expectation = expectation

        // When
        testSut.handleCardFlip(card2)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(testSut.processFlippedCardsCalled)
    }

    // MARK: - Tests for processFlippedCards
    func testProcessFlippedCards_matchingCards() {
        // Given
        let cardModel1 = Card(type: .circle, color: .red)
        let cardModel2 = Card(type: .circle, color: .red)
        sut.game.cards = [cardModel1, cardModel2]
        
        let cardView1 = MockFlippableView(frame: .zero)
        cardView1.tag = 0
        let cardView2 = MockFlippableView(frame: .zero)
        cardView2.tag = 1
        
        sut.flippedCards = [cardView1, cardView2]
        
        // When
        sut.processFlippedCards()
        
        // Then
        let expectation = XCTestExpectation(description: "Cards should be removed from superview")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { // Wait for animation to complete
            XCTAssertTrue(self.sut.flippedCards.isEmpty)
            XCTAssertNil(cardView1.superview)
            XCTAssertNil(cardView2.superview)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testProcessFlippedCards_nonMatchingCards() {
        // Given
        let cardModel1 = Card(type: .circle, color: .red)
        let cardModel2 = Card(type: .cross, color: .orange)
        sut.game.cards = [cardModel1, cardModel2]
        
        let cardView1 = MockFlippableView(frame: .zero)
        cardView1.tag = 0
        let cardView2 = MockFlippableView(frame: .zero)
        cardView2.tag = 1
        
        sut.flippedCards = [cardView1, cardView2]
        
        // When
        sut.processFlippedCards()
        
        // Then
        let expectation = XCTestExpectation(description: "Cards should flip back")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { // Wait for animation to complete
            XCTAssertFalse(cardView1.isFlipped)
            XCTAssertFalse(cardView2.isFlipped)
            XCTAssertTrue(self.sut.flippedCards.isEmpty) // Cards are still in flippedCards, just unflipped
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.5)
    }
}
