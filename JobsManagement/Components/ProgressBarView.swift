import SwiftUI

struct ProgressBarView: View {
    let progress: Int
    var tint: Color = .accentColor
    var height: CGFloat = 8
    var showLabel: Bool = true

    private var clampedProgress: Int {
        min(100, max(0, progress))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel {
                HStack {
                    Text("Tiến độ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(clampedProgress)%")
                        .font(.caption.bold())
                        .foregroundStyle(tint)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))

                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * CGFloat(clampedProgress) / 100)
                }
            }
            .frame(height: height)
        }
    }
}

#Preview {
    ProgressBarView(progress: 65, tint: .orange)
        .padding()
}
