import Foundation
import SwiftUI

// Небольшой UI-компонент "чип" для фильтров.
// Отображает заголовок, опциональную иконку и состояние выбранности, меняя цвет/обводку.
struct FilterChip: View {
    
    // Текстовая метка чипа
    let title: String
    // Опциональная SF Symbol иконка
    var icon: String? = nil
    // Базовый цвет чипа (используется для выделения)
    var color: Color = .blue
    // Состояние выбранности чипа (влияет на фон/цвет/обводку)
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            // Если иконка задана — показываем
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        // Фон и цвет текста зависят от isSelected
        .background(Color("ячейка"))
        .foregroundColor(Color("текст"))
        .cornerRadius(20)
        // Обводка появляется только в выбранном состоянии
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
    }
}

