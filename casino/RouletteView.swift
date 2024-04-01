import SwiftUI

struct RouletteView: View {
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning = false
    @State private var selectedNumber: Int?
    @State private var balance: Int = 100000000
    @State private var bet: Int = 10
    @State private var showResult = false
    @State private var ballPosition: CGPoint = .zero
    
    let numbers = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0, blue: 0), Color.black]),
                           center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Balance: $\(balance)")
                    .foregroundColor(.white)
                    .font(.custom("Helvetica Neue", size: 24).bold())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 0.2, green: 0, blue: 0))
                            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0, blue: 0), Color.black]),
                                           center: .center,
                                           startRadius: 5,
                                           endRadius: 150)
                        )
                        .frame(width: 320, height: 320)
                        .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 0)
                    
                    ForEach(0..<37) { index in
                        RouletteNumber(number: numbers[index], angle: Double(index) * 360 / 37, color: getNumberColor(numbers[index]))
                            .rotationEffect(.degrees(rotationDegrees))
                    }
                    
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 5, endRadius: 10))
                        .frame(width: 20, height: 20)
                        .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 0)
                    
                    Ball(position: $ballPosition)
                        .rotationEffect(.degrees(rotationDegrees))
                }
                .overlay(
                    Triangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.red.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 20, height: 20)
                        .shadow(color: .red.opacity(0.5), radius: 5, x: 0, y: 0)
                        .offset(y: -170)
                )
                .rotation3DEffect(.degrees(20), axis: (x: 1, y: 0, z: 0))
                
                HStack {
                    Button(action: {
                        if bet > 10 { bet -= 10 }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                    
                    Text("Bet: $\(bet)")
                        .foregroundColor(.white)
                        .font(.custom("Helvetica Neue", size: 20).bold())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if bet < balance { bet += 1000000 }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.2, green: 0, blue: 0))
                        .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                
                Button(action: spin) {
                    Text("SPIN")
                        .foregroundColor(.white)
                        .font(.custom("Helvetica Neue", size: 24).bold())
                        .padding()
                        .frame(width: 200)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(red: 0.6, green: 0, blue: 0), Color(red: 0.8, green: 0, blue: 0)]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(25)
                        .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .disabled(isSpinning)
            }
        }
        .alert(isPresented: $showResult) {
            Alert(
                title: Text("Result"),
                message: Text(resultMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func spin() {
        guard balance >= bet else { return }
        
        balance -= bet
        isSpinning = true
        showResult = false
        
        let spinDuration = 5.0
        let spinRotations = Double.random(in: 5...10)
        let totalRotation = 360 * spinRotations + Double.random(in: 0...360)
        
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotationDegrees = totalRotation
            ballPosition = CGPoint(x: 0, y: -130)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {
            isSpinning = false
            calculateResult()
            showResult = true
            
            withAnimation(.easeOut(duration: 0.5)) {
                ballPosition = .zero
            }
        }
    }
    
    func calculateResult() {
        let normalizedRotation = rotationDegrees.truncatingRemainder(dividingBy: 360)
        let index = Int(round(normalizedRotation / (360 / 37))) % 37
        selectedNumber = numbers[index]
        
        if selectedNumber == 0 {
            // House wins
        } else if selectedNumber! % 2 == 0 {
            balance += bet * 2 // Even number wins
        } else {
            // Odd number, player loses
        }
    }
    
    var resultMessage: String {
        guard let number = selectedNumber else { return "" }
        if number == 0 {
            return "House wins! The number is 0."
        } else if number % 2 == 0 {
            return "You win! The number is \(number) (even)."
        } else {
            return "You lose. The number is \(number) (odd)."
        }
    }
    
    func getNumberColor(_ number: Int) -> Color {
        if number == 0 {
            return .green
        } else {
            return [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36].contains(number) ? .red : .black
        }
    }
}

struct RouletteNumber: View {
    let number: Int
    let angle: Double
    let color: Color
    
    var body: some View {
        Text("\(number)")
            .foregroundColor(color == .black ? .white : color)
            .font(.custom("Helvetica Neue", size: 14).bold())
            .rotationEffect(.degrees(-angle))
            .offset(y: -140)
            .rotationEffect(.degrees(angle))
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct Ball: View {
    @Binding var position: CGPoint
    
    var body: some View {
        Circle()
            .fill(RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 0, endRadius: 5))
            .frame(width: 15, height: 15)
            .shadow(color: .white.opacity(0.8), radius: 3, x: 0, y: 0)
            .offset(x: position.x, y: position.y)
    }
}

struct RouletteView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
