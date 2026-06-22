import SwiftUI

struct WelcomeView: View {
    // Колбэк, который вызовется после задержки — чтобы переключиться на основной интерфейс
    let onFinish: () -> Void
    
    @State private var isVisible = false
    @State private var textOffset: CGFloat = -200 // начальное смещение текста влево
    @State private var textOpacity: Double = 0.0  // начальная прозрачность текста
    
    // Настройки анимации текста
    private let textAnimationDuration: Double = 0.6
    private let textAnimationDelay: Double = 0.2
    
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
                
                // Подпись внизу — заезжает слева направо
                Text("money flow up")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(Color("текст"))
                    .opacity(textOpacity)
                    .offset(x: textOffset, y: 0)
            }
        }
        .onAppear {
            // Плавное появление лого
            isVisible = true
            
            // Запуск анимации текста с задержкой
            DispatchQueue.main.asyncAfter(deadline: .now() + textAnimationDelay) {
                withAnimation(.easeOut(duration: textAnimationDuration)) {
                    textOffset = 0
                    textOpacity = 1.0
                }
                
                // Переход на следующий экран строго после завершения анимации текста
                DispatchQueue.main.asyncAfter(deadline: .now() + textAnimationDuration + 0.5) {
                    onFinish()
                }
            }
        }
    }
}

