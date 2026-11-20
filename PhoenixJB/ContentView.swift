import SwiftUI
import UIKit

private enum PhoenixTab: Hashable {
    case home, store, sources, settings
}

private struct PackageSource: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var url: String
}

struct ContentView: View {
    @AppStorage("phoenix.packageManager") private var packageManager = "Sileo"
    @AppStorage("phoenix.sources") private var sourcesJSON = "[]"
    @State private var selectedTab: PhoenixTab = .home
    @State private var showAddSource = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    private var sources: [PackageSource] {
        guard let data = sourcesJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([PackageSource].self, from: data) else {
            return []
        }
        return decoded
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                homeView
            }
            .tabItem { Label("Главная", systemImage: "house.fill") }
            .tag(PhoenixTab.home)

            NavigationStack {
                storeView
            }
            .tabItem { Label("Каталог", systemImage: "square.grid.2x2.fill") }
            .tag(PhoenixTab.store)

            NavigationStack {
                sourcesView
            }
            .tabItem { Label("Источники", systemImage: "shippingbox.fill") }
            .tag(PhoenixTab.sources)

            NavigationStack {
                settingsView
            }
            .tabItem { Label("Настройки", systemImage: "gearshape.fill") }
            .tag(PhoenixTab.settings)
        }
        .tint(Color(red: 0.55, green: 0.48, blue: 1.0))
        .alert("Phoenix JB", isPresented: $showAlert) {
            Button("понятно", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showAddSource) {
            AddSourceView { name, url in
                addSource(name: name, url: url)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Состояние устройства", systemImage: "iphone")
                            .font(.headline)
                        Spacer()
                        StatusPill(title: "не активирован", color: .orange)
                    }

                    HStack {
                        DeviceFact(title: "Устройство", value: UIDevice.current.model)
                        Spacer()
                        DeviceFact(title: "iOS", value: UIDevice.current.systemVersion)
                    }

                    Divider().overlay(Color.white.opacity(0.12))

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.orange)
                        Text("Phoenix пока работает как интерфейс и менеджер источников. Совместимый jailbreak-backend для этого устройства не подключён.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(18)
                .background(PanelBackground())

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeading(title: "Менеджер пакетов", subtitle: "выбери интерфейс, который хочешь использовать")
                    Picker("Менеджер пакетов", selection: $packageManager) {
                        Text("Sileo").tag("Sileo")
                        Text("Zebra").tag("Zebra")
                    }
                    .pickerStyle(.segmented)
                    .tint(.purple)

                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Выбран: \(packageManager)")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("настройка сохранена")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .padding(18)
                .background(PanelBackground())

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeading(title: "Быстрый доступ", subtitle: "основные разделы Phoenix")
                    QuickAction(icon: "square.grid.2x2.fill", title: "Каталог", detail: "приложения и твики") {
                        selectedTab = .store
                    }
                    QuickAction(icon: "shippingbox.fill", title: "Источники", detail: "управление репозиториями") {
                        selectedTab = .sources
                    }
                }
            }
            .padding(18)
        }
        .background(Color(red: 0.055, green: 0.06, blue: 0.09).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("PHOENIX JB")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .tracking(1.2)
                Text("твой центр управления пакетами")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Image(systemName: "flame.fill")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.top, 12)
    }

    private var storeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeading(title: "Каталог", subtitle: "пакеты, приложения и твики")
                HStack {
                    Label("Менеджер", systemImage: "shippingbox")
                    Spacer()
                    Text(packageManager)
                        .fontWeight(.semibold)
                        .foregroundStyle(.purple.opacity(0.9))
                }
                .padding(16)
                .background(PanelBackground())

                VStack(spacing: 12) {
                    Image(systemName: "lock.iphone")
                        .font(.system(size: 38))
                        .foregroundStyle(.purple)
                    Text("установка пока недоступна")
                        .font(.headline)
                    Text("для установки deb-пакетов и твиков нужна активная jailbreak-среда. Phoenix не будет имитировать установку или сообщать об успехе, пока backend не подключён.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.62))
                    Button("перейти к источникам") {
                        selectedTab = .sources
                    }
                    .buttonStyle(PhoenixButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(PanelBackground())
            }
            .padding(18)
        }
        .background(Color(red: 0.055, green: 0.06, blue: 0.09).ignoresSafeArea())
        .navigationTitle("Каталог")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sourcesView: some View {
        List {
            Section {
                if sources.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("пока нет источников")
                            .font(.headline)
                        Text("добавь URL репозитория. Phoenix сохранит его на устройстве.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } else {
                    ForEach(sources) { source in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(source.name).font(.headline)
                            Text(source.url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteSources)
                }
            } header: {
                Text("мои репозитории")
            } footer: {
                Text("это локальный список адресов. получение индекса пакетов и установка пока не подключены.")
            }

            Section {
                Button {
                    showAddSource = true
                } label: {
                    Label("добавить источник", systemImage: "plus.circle.fill")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.055, green: 0.06, blue: 0.09))
        .navigationTitle("Источники")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
    }

    private var settingsView: some View {
        Form {
            Section("пакетный менеджер") {
                Picker("по умолчанию", selection: $packageManager) {
                    Text("Sileo").tag("Sileo")
                    Text("Zebra").tag("Zebra")
                }
                .pickerStyle(.segmented)
            }

            Section("о приложении") {
                LabeledContent("Название", value: "Phoenix JB")
                LabeledContent("Версия", value: "1.0")
                LabeledContent("iOS", value: UIDevice.current.systemVersion)
            }

            Section {
                Text("Phoenix сейчас не содержит эксплойта, bootstrap или драйвера установки пакетов. Не устанавливай неизвестные профили и IPA, обещающие активировать jailbreak.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("важно")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.055, green: 0.06, blue: 0.09))
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addSource(name: String, url: String) {
        guard let parsed = URL(string: url),
              let scheme = parsed.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              parsed.host != nil else {
            alertMessage = "введи корректный URL, начинающийся с http:// или https://."
            showAlert = true
            return
        }

        var updated = sources
        guard !updated.contains(where: { $0.url.lowercased() == url.lowercased() }) else {
            alertMessage = "этот источник уже добавлен."
            showAlert = true
            return
        }
        updated.append(PackageSource(name: name, url: url))
        saveSources(updated)
    }

    private func deleteSources(at offsets: IndexSet) {
        var updated = sources
        for index in offsets.sorted(by: >) where updated.indices.contains(index) {
            updated.remove(at: index)
        }
        saveSources(updated)
    }

    private func saveSources(_ updated: [PackageSource]) {
        guard let data = try? JSONEncoder().encode(updated),
              let string = String(data: data, encoding: .utf8) else { return }
        sourcesJSON = string
    }
}

private struct PanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(red: 0.105, green: 0.11, blue: 0.16))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            }
    }
}

private struct SectionHeading: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.title3.bold())
            Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.5))
        }
    }
}

private struct StatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.16), in: Capsule())
            .foregroundStyle(color)
    }
}

private struct DeviceFact: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.48))
            Text(value).font(.subheadline.weight(.semibold))
        }
    }
}

private struct QuickAction: View {
    let icon: String
    let title: String
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.purple)
                    .frame(width: 38, height: 38)
                    .background(.purple.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(detail).font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.35))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct PhoenixButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var url = ""
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("данные источника") {
                    TextField("название, например My Repo", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("https://example.com/repo", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section {
                    Text("добавляй только репозитории, которым доверяешь. добавление адреса само по себе не устанавливает пакеты.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Новый источник")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("сохранить") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty, !trimmedURL.isEmpty else { return }
                        onSave(trimmedName, trimmedURL)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
