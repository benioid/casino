import SwiftUI

struct Peg: Identifiable {
    let id = UUID()
    let position: CGPoint
}

struct Bucket: Identifiable {
    let id = UUID()
    let position: CGPoint
    let score: Int
}

class PlinkoGame: ObservableObject {
    @Published var ballPosition: CGPoint
    @Published var ballVelocity: CGPoint = .zero
    @Published var isDropping = false
    @Published var score = 0
    
    let pegs: [Peg]
    let buckets: [Bucket]
    let screenSize: CGSize
    let pegRadius: CGFloat = 5
    let ballRadius: CGFloat = 10
    
    private var displayLink: CADisplayLink?
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        self.ballPosition = CGPoint(x: screenSize.width / 2, y: 50)
        
        // Create pegs
        var pegs = [Peg]()
        let pegRows = 8
        let pegsPerRow = 9
        let pegSpacingX = screenSize.width / CGFloat(pegsPerRow + 1)
        let pegSpacingY = (screenSize.height - 200) / CGFloat(pegRows + 1)
        
        for row in 0..<pegRows {
            for col in 0..<pegsPerRow {
                let xOffset = row.isMultiple(of: 2) ? pegSpacingX / 2 : 0
                let x = CGFloat(col + 1) * pegSpacingX + xOffset
                let y = CGFloat(row + 1) * pegSpacingY + 100
                pegs.append(Peg(position: CGPoint(x: x, y: y)))
            }
        }
        self.pegs = pegs
        
        // Create buckets
        var buckets = [Bucket]()
        let bucketWidth = screenSize.width / CGFloat(pegsPerRow)
        for i in 0..<pegsPerRow {
            let x = CGFloat(i) * bucketWidth + bucketWidth / 2
            let y = screenSize.height - 50
            buckets.append(Bucket(position: CGPoint(x: x, y: y), score: (i + 1) * 10))
        }
        self.buckets = buckets
    }
    
    func dropBall() {
        guard !isDropping else { return }
        isDropping = true
        ballPosition = CGPoint(x: screenSize.width / 2, y: 50)
        ballVelocity = CGPoint(x: 0, y: 50)
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func update() {
        let gravity: CGFloat = 9.8
        let timeStep: CGFloat = 1.0 / 60.0
        
        ballVelocity.y += gravity
        ballPosition.x += ballVelocity.x * timeStep
        ballPosition.y += ballVelocity.y * timeStep
        
        // Check for collisions with pegs
        for peg in pegs {
            if distance(from: ballPosition, to: peg.position) < (ballRadius + pegRadius) {
                let normal = normalize(vector: CGPoint(x: ballPosition.x - peg.position.x,
                                                       y: ballPosition.y - peg.position.y))
                ballPosition = CGPoint(x: peg.position.x + normal.x * (ballRadius + pegRadius),
                                       y: peg.position.y + normal.y * (ballRadius + pegRadius))
                
                let dot = dotProduct(ballVelocity, normal)
                ballVelocity = CGPoint(x: ballVelocity.x - 2 * dot * normal.x,
                                       y: ballVelocity.y - 2 * dot * normal.y)
                
                // Add some randomness to the bounce
                ballVelocity.x += CGFloat.random(in: -20...20)
                
                // Dampen the velocity
                ballVelocity = CGPoint(x: ballVelocity.x * 0.8, y: ballVelocity.y * 0.8)
            }
        }
        
        // Check for collision with walls
        if ballPosition.x - ballRadius < 0 || ballPosition.x + ballRadius > screenSize.width {
            ballVelocity.x *= -0.8
            ballPosition.x = max(ballRadius, min(screenSize.width - ballRadius, ballPosition.x))
        }
        
        // Check if ball reached the bottom
        if ballPosition.y + ballRadius > screenSize.height - 70 {
            displayLink?.invalidate()
            displayLink = nil
            isDropping = false
            calculateScore()
        }
    }
    
    private func calculateScore() {
        if let bucket = buckets.min(by: { abs($0.position.x - ballPosition.x) < abs($1.position.x - ballPosition.x) }) {
            score += bucket.score
        }
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    private func normalize(vector: CGPoint) -> CGPoint {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y)
        return CGPoint(x: vector.x / length, y: vector.y / length)
    }
    
    private func dotProduct(_ v1: CGPoint, _ v2: CGPoint) -> CGFloat {
        v1.x * v2.x + v1.y * v2.y
    }
}

struct PlinkoView: View {
    @StateObject private var game: PlinkoGame
    
    init() {
        let screenSize = UIScreen.main.bounds.size
        _game = StateObject(wrappedValue: PlinkoGame(screenSize: screenSize))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Score
                Text("Score: \(game.score)")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                
                // Game board
                GeometryReader { geometry in
                    ZStack {
                        // Pegs
                        ForEach(game.pegs) { peg in
                            Circle()
                                .fill(Color.white)
                                .frame(width: game.pegRadius * 2, height: game.pegRadius * 2)
                                .position(peg.position)
                        }
                        
                        // Buckets
                        ForEach(game.buckets) { bucket in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width / CGFloat(game.buckets.count), height: 40)
                                .position(bucket.position)
                            
                            Text("\(bucket.score)")
                                .foregroundColor(.white)
                                .position(bucket.position)
                        }
                        
                        // Ball
                        Circle()
                            .fill(Color.red)
                            .frame(width: game.ballRadius * 2, height: game.ballRadius * 2)
                            .position(game.ballPosition)
                    }
                }
                
                // Drop button
                Button(action: game.dropBall) {
                    Text("Drop")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(game.isDropping)
                .padding()
            }
        }
    }
}

struct PlinkoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
