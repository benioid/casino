import SwiftUI

struct ContentView: View {
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)), Color(#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Crypto Casino")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 2, x: 0, y: 0)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: isAnimating)
                    
                    Text("Choose your game")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                    
                    VStack(spacing: 20) {
                        GameButton(title: "Plinko", systemImage: "circle.grid.3x3.fill", color: .blue, destination: PlinkoView())
                        GameButton(title: "Roulette", systemImage: "circle.fill", color: .red, destination: RouletteView())
                        GameButton(title: "Mines", systemImage: "diamond.fill", color: .green, destination: MinesView())
                    }
                    .padding()
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct GameButton<Destination: View>: View {
    let title: String
    let systemImage: String
    let color: Color
    let destination: Destination
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .font(.system(size: 24))
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
