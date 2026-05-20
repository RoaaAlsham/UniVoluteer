import SwiftUI
import PhotosUI

struct ReflectionView: View {
    @Binding var reflections: [String]
    @Binding var photoData: Data?

    var onExtract: () -> Void

    @State private var selectedPhoto: PhotosPickerItem?

    private let prompts = [
        "What did you specifically do? Walk us through a concrete moment.",
        "What was the hardest part? How did you handle it?",
        "What would you do differently next time?",
    ]

    private var allFieldsReady: Bool {
        reflections.allSatisfy { $0.count >= 50 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tell us what you actually did")
                        .largeTitleStyle()
                    Text("The more specific you are, the better your skills will reflect what you really accomplished")
                        .captionStyle()
                }
                .padding(.top, 8)

                photoSection

                ForEach(0..<3, id: \.self) { index in
                    reflectionField(index: index)
                }

                Button(action: onExtract) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Extract My Skills")
                    }
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(allFieldsReady ? Color.brandPrimary : Color.brandPrimary.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!allFieldsReady)
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color.brandBg)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo (optional)")
                .font(.system(.subheadline, design: .default, weight: .medium))

            if let photoData, let uiImage = UIImage(data: photoData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        self.photoData = nil
                        selectedPhoto = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Add a photo")
                    }
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(Color.brandPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color.brandPrimary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.brandPrimary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                }
            }
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    private func reflectionField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(prompts[index])
                .font(.system(.subheadline, design: .default, weight: .medium))

            TextEditor(text: $reflections[index])
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.1))
                )

            HStack {
                Spacer()
                let count = reflections[index].count
                Text("\(count) characters")
                    .font(.system(.caption2, design: .default, weight: .medium))
                    .foregroundStyle(count >= 100 ? Color.brandSuccess : count >= 50 ? Color.brandAccent : .secondary)
                if count < 50 {
                    Text("· \(50 - count) more needed")
                        .font(.system(.caption2, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
