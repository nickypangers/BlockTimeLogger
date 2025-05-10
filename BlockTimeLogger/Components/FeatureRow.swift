import SwiftUI

struct FeatureRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(.accentColor)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
        Text(description)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }
}

#Preview {
  FeatureRow(
    icon: "star.fill",
    title: "Sample Feature",
    description: "This is a sample feature description"
  )
  .padding()
}
