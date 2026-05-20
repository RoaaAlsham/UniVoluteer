import SwiftUI

struct ComboBoxField<Item: Identifiable & Hashable, RowContent: View>: View {
    let label: String
    let placeholder: String
    let items: [Item]
    @Binding var selection: Item?
    let displayName: (Item) -> String
    let searchableText: (Item) -> String
    @ViewBuilder let rowContent: (Item) -> RowContent
    var isDisabled: Bool = false
    var disabledMessage: String?

    @State private var showSheet = false

    private var hasSelection: Bool { selection != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(.secondary)

            Button {
                if !isDisabled { showSheet = true }
            } label: {
                HStack {
                    if let sel = selection {
                        Text(displayName(sel))
                            .font(.system(.body, design: .default, weight: .medium))
                            .foregroundStyle(.primary)
                    } else {
                        Text(placeholder)
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    if isDisabled {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showSheet ? 180 : 0))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(hasSelection ? Color.brandPrimary.opacity(0.4) : Color.primary.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
            .opacity(isDisabled ? 0.5 : 1)
            .animation(.easeOut(duration: 0.25), value: hasSelection)
            .accessibilityLabel("\(label), \(selection.map { displayName($0) } ?? "not selected")")
            .accessibilityHint("Double-tap to change")
            .accessibilityAddTraits(.isButton)

            if isDisabled, let msg = disabledMessage {
                Text(msg)
                    .font(.system(.caption2, design: .default, weight: .regular))
                    .foregroundStyle(.tertiary)
            }
        }
        .sheet(isPresented: $showSheet) {
            SelectionSheet(
                items: items,
                selection: $selection,
                displayName: displayName,
                searchableText: searchableText,
                rowContent: rowContent,
                showSearch: items.count > 4,
                onDismiss: { showSheet = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

private struct SelectionSheet<Item: Identifiable & Hashable, RowContent: View>: View {
    let items: [Item]
    @Binding var selection: Item?
    let displayName: (Item) -> String
    let searchableText: (Item) -> String
    @ViewBuilder let rowContent: (Item) -> RowContent
    let showSearch: Bool
    let onDismiss: () -> Void

    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var filtered: [Item] {
        guard !query.isEmpty else { return items }
        let q = query.lowercased()
        return items.filter { searchableText($0).lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { onDismiss() }
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if showSearch {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                    TextField("Search...", text: $query)
                        .font(.system(.subheadline))
                        .focused($searchFocused)
                        .accessibilityLabel("Search items")
                }
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .onAppear { searchFocused = true }
            }

            if filtered.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text("No matches")
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { item in
                            Button {
                                HapticService.impactLight()
                                selection = item
                                onDismiss()
                            } label: {
                                VStack(spacing: 0) {
                                    rowContent(item)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                    Divider().padding(.leading, 20)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .background(Color.brandBg)
    }
}
