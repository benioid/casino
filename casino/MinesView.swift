import SwiftUI

struct MinesView: View {
    @State private var grid: [[CellState]] = Array(repeating: Array(repeating: .hidden, count: 5), count: 5)
    @State private var gameOver = false
    @State private var score = 0
    
    let mineChance = 0.2
    
    enum CellState {
        case hidden, revealed, mine
    }
    
    var body: some View {
        VStack {
            Text("Score: \(score)")
                .font(.headline)
                .padding()
            
            ForEach(0..<5, id: \.self) { row in
                HStack {
                    ForEach(0..<5, id: \.self) { column in
                        Button(action: {
                            self.revealCell(row: row, column: column)
                        }) {
                            CellView(state: self.grid[row][column], gameOver: gameOver)
                        }
                    }
                }
            }
            
            if gameOver {
                Text("Game Over!")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
                
                Button("Restart") {
                    self.restartGame()
                }
                .padding()
            }
        }
        .onAppear {
            self.initializeGrid()
        }
    }
    
    func initializeGrid() {
        for row in 0..<5 {
            for column in 0..<5 {
                if Double.random(in: 0...1) < mineChance {
                    grid[row][column] = .mine
                } else {
                    grid[row][column] = .hidden
                }
            }
        }
    }
    
    func revealCell(row: Int, column: Int) {
        guard !gameOver else { return }
        
        if grid[row][column] == .mine {
            gameOver = true
            revealAllMines()
        } else if grid[row][column] == .hidden {
            grid[row][column] = .revealed
            score += 1
        }
    }
    
    func revealAllMines() {
        for row in 0..<5 {
            for column in 0..<5 {
                if grid[row][column] == .mine {
                    grid[row][column] = .revealed
                }
            }
        }
    }
    
    func restartGame() {
        grid = Array(repeating: Array(repeating: .hidden, count: 5), count: 5)
        gameOver = false
        score = 0
        initializeGrid()
    }
}

struct CellView: View {
    let state: MinesView.CellState
    let gameOver: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(backgroundColor)
                .frame(width: 50, height: 50)
            
            if state == .mine && gameOver {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.white)
            }
        }
    }
    
    var backgroundColor: Color {
        switch state {
        case .hidden:
            return .blue
        case .revealed:
            return .green
        case .mine:
            return gameOver ? .red : .blue
        }
    }
}

struct MinesView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
