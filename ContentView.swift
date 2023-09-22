import Foundation
import SwiftUI

enum TileStatus {
    // tiles owned by player
    case empty
    case ai
    case player
}

// Tile peramerters
class Tile : ObservableObject {
    @Published var _tileSts : TileStatus
    
    init(status : TileStatus) {
        self._tileSts = status
    }
}

struct Tile_VW : View {
    //assign paremters to tiles
    @ObservedObject var dataSource : Tile
    var action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Text(self.dataSource._tileSts == .ai ?
                    "X" : self.dataSource._tileSts == .player ? "O" : " ")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .background(Color.blue.opacity(0.6).cornerRadius(14))
                .padding(4)
        })
    }
}

class Game : ObservableObject {
    @Published var tileArray = [Tile]()
        
    //build tile layout
    init() {
        for _ in 0...8 {
            tileArray.append(Tile(status: .empty))
        }
    }
    
    //rebuild tile layout
    func restart() {
        for i in 0...8 {
            tileArray[i]._tileSts = .empty
        }
    }

    //Test for end of game
    var endOfGame : (TileStatus, Bool) {
        get {
            if checkWin != .empty {
                return (checkWin, true)
                
            }
            else {
                for i in 0...8 {
                    if tileArray[i]._tileSts == .empty {
                        return(.empty, false)
                    }
                }
                return (.empty, true)
            }
        }
    }
    
    //Test for winner against known winning combinations
    private var checkWin: TileStatus {
        get {
            //All the values in a row are the same
            if let check = self.checkIndexes([0, 1, 2]) {
                return check }
            //All the values in a row are the same
            else  if let check = self.checkIndexes([3, 4, 5]) {
                return check }
            //All the values in a row are the same
            else  if let check = self.checkIndexes([6, 7, 8]) {
                return check }
            //All the values in a column are the same
            else  if let check = self.checkIndexes([0, 3, 6]) {
                return check }
            //All the values in a column are the same
            else  if let check = self.checkIndexes([1, 4, 7]) {
                return check }
            //All the values in a column are the same
            else  if let check = self.checkIndexes([2, 5, 8]) {
                return check }
            //All the values in a diagonal are the same
            else  if let check = self.checkIndexes([0, 4, 8]) {
                return check }
            //All the values in a diagonal are the same
            else  if let check = self.checkIndexes([2, 4, 6]) {
                return check }
            //The values are either X or O and not blank
            return .empty
        }
    }
    
    //Check if AI or player has enoght tiles for win
    private func checkIndexes(_ indexes : [Int]) -> TileStatus? {
        var score = 0

        var aiCount : Int = 0
        var playerCount : Int = 0
        for index in indexes {
            let square = tileArray[index]
            if square._tileSts == .ai {
                aiCount += 1
            } else if square._tileSts == .player {
                playerCount += 1
            }
        }
        if aiCount == 3 {
            return .ai
        }
        else if playerCount == 3 {
            score += 1
            return .player
        }
        return nil
    }
    
    //turn based functions
    
    private func AIturn() {
        //random tile select for Ai player move
        var index = Int.random(in: 0...8)
        while nextMove(index: index, player: .player) == false && endOfGame.1 == false {
            index = Int.random(in: 0...8)
        }
    }
    
    func nextMove(index: Int, player: TileStatus) -> Bool {
        //Only let player select empty tile space and then play Ai move
        if tileArray[index]._tileSts == .empty {
            tileArray[index]._tileSts = player
            if player == .ai {
                AIturn()
            }
            return true
        }
        return false
    }
    
}


struct ContentView: View {
    //Setup for game
    @StateObject var gameLogic = Game()
    @State var gameOver : Bool = false
    @State var score = 0
    
    //assign buttons action to tiles, check for endofgame
    func buttonAction(_ index : Int) {
        _ = self.gameLogic.nextMove(index: index, player: .ai)
        self.gameOver = self.gameLogic.endOfGame.1
//        score = gameLogic.score
        if self.gameLogic.endOfGame.0 == .ai{
            score = 0
        }
    }

    var body: some View {
        
        //setup grid layout for tiles and title
        VStack {
            Text("Lel's game")
                .bold()
                .foregroundColor(Color.black.opacity(0.7))
                .padding(.bottom)
                .font(.title2)
            ForEach(0 ..< gameLogic.tileArray.count / 3, content: {
                row in
                HStack {
                    ForEach(0 ..< 3, content: {
                        column in
                        let index = row * 3 + column
                        Tile_VW(dataSource: gameLogic.tileArray[index], action: {self.buttonAction(index)})
                    })
                }
            })
            Text("Score: \(score)")
                .bold()
                .foregroundColor(Color.black.opacity(0.7))
                .padding(.top)
                .font(.title3)
        }

            
        // Game over alert
        .alert(isPresented: self.$gameOver, content: {
            Alert(title: Text("Game Over"),
                  message: Text(self.gameLogic.endOfGame.0 != .empty ? self.gameLogic.endOfGame.0 == .ai ? "You win"  : "You lose”" : "Tied" ) , dismissButton: Alert.Button.destructive(Text("Confirm"), action: {
                    self.gameLogic.restart()
                  }))
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
