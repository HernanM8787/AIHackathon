import SwiftUI
import UIKit

struct SchoolLogoView: View {
    let school: School
    let size: CGFloat
    
    init(school: School, size: CGFloat = 50) {
        self.school = school
        self.size = size
    }
    
    var body: some View {
        Group {
            if !school.logoImageName.isEmpty, let logoImage = UIImage(named: school.logoImageName) {
                // Use actual logo image if available
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(school.secondaryColor.opacity(0.3), lineWidth: 2)
                    }
            } else {
                // Fallback to icon with school colors
                Circle()
                    .fill(school.accentGradient)
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: school.logoIcon)
                            .foregroundStyle(school.secondaryColor)
                            .font(.system(size: size * 0.4))
                    }
                    .overlay {
                        Circle()
                            .stroke(school.secondaryColor.opacity(0.3), lineWidth: 2)
                    }
            }
        }
    }
}

struct SchoolBadgeView: View {
    let school: School
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: school.logoIcon)
                .font(.caption)
            Text(school.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(school.secondaryColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(school.primaryColor)
        )
    }
}

