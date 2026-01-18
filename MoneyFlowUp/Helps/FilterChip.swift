import Foundation
import SwiftUI

struct FilterChip: View {
    
    let title: String
    var icon: String? = nil
    var color: Color = .blue
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            
            Text(title)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
        .foregroundColor(isSelected ? color : .primary)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? color : Color.clear, lineWidth: 1)
        )
    }
}
