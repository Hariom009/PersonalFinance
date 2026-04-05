import SwiftUI

struct PresetChipRow: View {
    @Binding var selectedPreset: ChallengePreset?
    var onSelect: (ChallengePreset) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ChallengePreset.allCases) { preset in
                let isSelected = selectedPreset == preset

                Text(preset.label)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .background(isSelected ? Color.orange : Color.cardBackground)
                    .clipShape(Capsule())
                    .onTapGesture {
                        onSelect(preset)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedPreset)
    }
}
