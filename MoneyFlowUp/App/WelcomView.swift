import SwiftUI

struct WelcomeView: View {
    // Колбэк, который вызовется после задержки — чтобы переключиться на основной интерфейс
    let onFinish: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Color("фон лого").ignoresSafeArea()
            
            VStack {
                
                // Логотип по центру
                Image("лого2")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180, maxHeight: 180)
                    .opacity(isVisible ? 1 : 0.0)
                    .scaleEffect(isVisible ? 1.0 : 0.95)
                    .animation(.easeOut(duration: 0.35), value: isVisible)
                    
              
                
                // Подпись внизу
                Text("money flow up", )
                    .font(.system(size: 30, weight: .medium))
                    
                    .foregroundColor(Color("текст"))
                    .opacity(isVisible ? 1 : 0.0)
                    .animation(.easeIn(duration: 0.35).delay(0.1), value: isVisible)
                
            }
        }
        .onAppear {
            // Плавное появление
            isVisible = true
            // Автопереход через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                onFinish()
            }
        }
    }
}

#Preview {
    WelcomeView(onFinish: {})
}
