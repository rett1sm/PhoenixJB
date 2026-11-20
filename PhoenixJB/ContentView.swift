import SwiftUI
import UIKit
import UniformTypeIdentifiers

private enum PhoenixTab: Hashable {
    case home, catalog, ipa, sources, settings
}

private struct PackageSource: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var url: String
}

private struct IPAEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var storedFileName: String
    var size: Int64
    var importedAt: Date
    var sourceURL: String?
}

struct ContentView: View {
    @AppStorage("phoenix.packageManager") private var packageManager = "Sileo"
    @AppStorage("phoenix.sources") private var sourcesJSON = "[]"
    @State private var selectedTab: PhoenixTab = .home
    @State private var showAddSource = false

    private var sources: [PackageSource] {
        guard let data = sourcesJSON.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([PackageSource].self, from: data) else { return [] }
        return decoded
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { homeView }
                .tabItem { Label("Обзор", systemImage: "square.grid.2x2.fill") }
                .tag(PhoenixTab.home)

            NavigationStack { catalogView }
                .tabItem { Label("Каталог", systemImage: "shippingbox.fill") }
                .tag(PhoenixTab.catalog)

            NavigationStack { IPAVaultView() }
                .tabItem { Label("IPA", systemImage: "app.gift.fill") }
                .tag(PhoenixTab.ipa)

            NavigationStack { sourcesView }
                .tabItem { Label("Источники", systemImage: "point.3.connected.trianglepath.dotted") }
                .tag(PhoenixTab.sources)

            NavigationStack { settingsView }
                .tabItem { Label("Настройки", systemImage: "slider.horizontal.3") }
                .tag(PhoenixTab.settings)
        }
        .tint(PhoenixStyle.accent)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddSource) {
            AddSourceView { name, url in addSource(name: name, url: url) }
                .presentationDetents([.medium, .large])
        }
    }

    private var homeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topHeader
                heroCard

                HStack(spacing: 12) {
                    MetricCard(
                        icon: "shippingbox.fill",
                        title: "Источники",
                        value: "\(sources.count)",
                        tint: .cyan
                    )
                    MetricCard(
                        icon: "app.badge",
                        title: "Менеджер",
                        value: packageManager,
                        tint: .purple
                    )
                }

                VStack(alignment: .leading, spacing: 13) {
                    SectionTitle(title: "Быстрый доступ", subtitle: "всё нужное — рядом")
                    QuickLink(icon: "square.grid.2x2.fill", title: "Каталог пакетов", detail: "раздел приложений и твиков", tint: .purple) {
                        selectedTab = .catalog
                    }
                    QuickLink(icon: "app.gift.fill", title: "Моя IPA-библиотека", detail: "импорт и хранение IPA-файлов", tint: .cyan) {
                        selectedTab = .ipa
                    }
                    QuickLink(icon: "point.3.connected.trianglepath.dotted", title: "Репозитории", detail: "сохранённые источники пакетов", tint: .orange) {
                        selectedTab = .sources
                    }
                }

                Text("Phoenix JB · тестовая версия")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.30))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
        .phoenixBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(LinearGradient(
                        colors: [PhoenixStyle.accent, PhoenixStyle.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                Image(systemName: "flame.fill")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("PHOENIX")
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(.white)
                Text("центр управления")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.52))
            }

            Spacer()

            Text("BETA")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(Color(red: 0.80, green: 0.72, blue: 1.0))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(PhoenixStyle.accent.opacity(0.17), in: Capsule())
                .overlay(Capsule().stroke(PhoenixStyle.accent.opacity(0.35), lineWidth: 1))
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("УСТРОЙСТВО", systemImage: "iphone")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.65))
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(.orange).frame(width: 6, height: 6)
                    Text("СРЕДА НЕ АКТИВНА")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.7)
                }
                .foregroundStyle(.white.opacity(0.82))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(UIDevice.current.localizedModel)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("iOS \(UIDevice.current.systemVersion)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.68))
            }

            Rectangle()
                .fill(.white.opacity(0.17))
                .frame(height: 1)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ПАКЕТНЫЙ МЕНЕДЖЕР")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.55))
                    Text(packageManager)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.13), in: RoundedRectangle(cornerRadius: 15))
            }

            Text("Интерфейс готов. Для установки твиков и запуска jailbreak нужна совместимая системная среда.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 27, style: .continuous)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.31, green: 0.20, blue: 0.63),
                            Color(red: 0.13, green: 0.25, blue: 0.50),
                            Color(red: 0.08, green: 0.15, blue: 0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 190, height: 190)
                    .offset(x: 65, y: -75)
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 230, height: 230)
                    .offset(x: 80, y: -90)
            }
            .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 27, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: PhoenixStyle.accent.opacity(0.16), radius: 24, y: 12)
    }

    private var catalogView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(eyebrow: "PHOENIX STORE", title: "Каталог", detail: "Приложения, пакеты и твики")
                ManagerPickerCard(selection: $packageManager)

                InfoPanel(
                    icon: "lock.fill",
                    title: "Установка пока закрыта",
                    detail: "Каталог и установка DEB-пакетов подключатся после появления совместимой jailbreak-среды. Сейчас Phoenix не имитирует установку."
                )

                QuickLink(icon: "point.3.connected.trianglepath.dotted", title: "Открыть источники", detail: "\(sources.count) сохранено", tint: .orange) {
                    selectedTab = .sources
                }
            }
            .padding(18)
        }
        .phoenixBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sourcesView: some View {
        List {
            Section {
                if sources.isEmpty {
                    EmptyState(
                        icon: "point.3.connected.trianglepath.dotted",
                        title: "Пока пусто",
                        detail: "Добавь адрес репозитория, чтобы сохранить его в Phoenix."
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(sources) { source in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(source.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(source.url)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.48))
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 5)
                        .listRowBackground(PhoenixStyle.panel)
                    }
                    .onDelete(perform: deleteSources)
                }
            } header: {
                Text("СОХРАНЁННЫЕ ИСТОЧНИКИ")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
            } footer: {
                Text("В этой бете адреса сохраняются локально. Загрузка индексов репозиториев и установка пакетов ещё не подключены.")
                    .foregroundStyle(.white.opacity(0.42))
            }

            Section {
                Button {
                    showAddSource = true
                } label: {
                    Label("Добавить репозиторий", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .listRowBackground(PhoenixStyle.panel)
            }
        }
        .scrollContentBackground(.hidden)
        .phoenixBackground()
        .navigationTitle("Источники")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
                .tint(PhoenixStyle.accent)
        }
    }

    private var settingsView: some View {
        Form {
            Section("ПАКЕТНЫЙ МЕНЕДЖЕР") {
                Picker("По умолчанию", selection: $packageManager) {
                    Text("Sileo").tag("Sileo")
                    Text("Zebra").tag("Zebra")
                }
                .pickerStyle(.segmented)
            }

            Section("ПРИЛОЖЕНИЕ") {
                LabeledContent("Название", value: "Phoenix JB")
                LabeledContent("Канал", value: "Бета")
                LabeledContent("Версия", value: "0.00")
                LabeledContent("iOS", value: UIDevice.current.systemVersion)
            }

            Section("ВОЗМОЖНОСТИ") {
                Label("Импорт и хранение IPA", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Label("Локальные источники", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Label("Jailbreak-среда", systemImage: "clock")
                    .foregroundStyle(.orange)
                Label("Запуск неподписанных IPA", systemImage: "clock")
                    .foregroundStyle(.orange)
            }

            Section {
                Text("Phoenix JB находится в ранней бете. Здесь пока нет эксплойта, bootstrap, установщика Sileo/Zebra или движка запуска приложений по модели LiveContainer. Не устанавливай неизвестные профили и файлы, обещающие активировать jailbreak.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("ПРЕДУПРЕЖДЕНИЕ")
            }
        }
        .scrollContentBackground(.hidden)
        .phoenixBackground()
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addSource(name: String, url: String) {
        guard let parsed = URL(string: url),
              let scheme = parsed.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              parsed.host != nil else { return }

        var updated = sources
        guard !updated.contains(where: { $0.url.lowercased() == url.lowercased() }) else { return }
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
              let value = String(data: data, encoding: .utf8) else { return }
        sourcesJSON = value
    }
}

// MARK: - IPA library

private struct IPAVaultView: View {
    @AppStorage("phoenix.ipaLibrary") private var ipaJSON = "[]"
    @State private var showImporter = false
    @State private var showDownloadSheet = false
    @State private var isDownloading = false
    @State private var statusMessage: String?
    @State private var showStatus = false
    @State private var showLaunchInfo = false

    private var entries: [IPAEntry] {
        guard let data = ipaJSON.data(using: .utf8),
              let result = try? JSONDecoder().decode([IPAEntry].self, from: data) else { return [] }
        return result.sorted { $0.importedAt > $1.importedAt }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                PageHeader(eyebrow: "ЛИЧНАЯ БИБЛИОТЕКА", title: "IPA", detail: "Твои приложения в одном месте")

                HStack(spacing: 10) {
                    VaultAction(icon: "plus", title: "Импортировать") {
                        showImporter = true
                    }
                    VaultAction(icon: "arrow.down.to.line", title: "По ссылке") {
                        showDownloadSheet = true
                    }
                }

                InfoPanel(
                    icon: "info.circle.fill",
                    title: "Что умеет библиотека",
                    detail: "Phoenix может импортировать IPA из «Файлов», скачивать их по прямой ссылке и хранить внутри приложения. Запуск гостевых приложений пока не реализован."
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SectionTitle(title: "Мои IPA", subtitle: "\(entries.count) файлов")
                        Spacer()
                        if !entries.isEmpty {
                            Text("ЛОКАЛЬНО")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.8)
                                .foregroundStyle(.green)
                        }
                    }

                    if entries.isEmpty {
                        EmptyState(
                            icon: "shippingbox",
                            title: "Библиотека пуста",
                            detail: "Нажми «Импортировать» или добавь прямую ссылку на IPA."
                        )
                        .padding(.vertical, 22)
                        .frame(maxWidth: .infinity)
                        .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 22))
                    } else {
                        ForEach(entries) { entry in
                            IPAEntryCard(entry: entry, onLaunch: { showLaunchInfo = true }, onDelete: { deleteEntry(entry) })
                        }
                    }
                }

                Text("Файлы хранятся в контейнере Phoenix и не устанавливаются в iOS.")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.top, 3)
            }
            .padding(18)
        }
        .phoenixBackground()
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [UTType(filenameExtension: "ipa", conformingTo: .data) ?? .data],
            allowsMultipleSelection: true,
            onCompletion: handleImport
        )
        .sheet(isPresented: $showDownloadSheet) {
            DownloadIPASheet(isDownloading: isDownloading) { address in
                Task { await downloadIPA(from: address) }
            }
            .presentationDetents([.medium])
        }
        .alert("Phoenix JB", isPresented: $showStatus) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text(statusMessage ?? "")
        }
        .alert("Запуск недоступен", isPresented: $showLaunchInfo) {
            Button("Понятно", role: .cancel) { }
        } message: {
            Text("Для запуска IPA внутри Phoenix нужен отдельный совместимый движок, например интеграция уровня LiveContainer. Сейчас библиотека поддерживает импорт и хранение файлов.")
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var imported = 0
            for url in urls {
                do {
                    let entry = try copyIPAIntoLibrary(from: url)
                    save(entry)
                    imported += 1
                } catch {
                    statusMessage = error.localizedDescription
                    showStatus = true
                }
            }
            if imported > 0 {
                statusMessage = "Импортировано файлов: \(imported)."
                showStatus = true
            }
        case .failure(let error):
            statusMessage = "Не удалось импортировать файл: \(error.localizedDescription)"
            showStatus = true
        }
    }

    private func copyIPAIntoLibrary(from source: URL) throws -> IPAEntry {
        let hasAccess = source.startAccessingSecurityScopedResource()
        defer {
            if hasAccess { source.stopAccessingSecurityScopedResource() }
        }

        guard source.pathExtension.lowercased() == "ipa" else {
            throw NSError(domain: "PhoenixIPA", code: 1, userInfo: [NSLocalizedDescriptionKey: "Выбери файл с расширением .ipa."])
        }

        let attributes = try FileManager.default.attributesOfItem(atPath: source.path)
        let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0
        let storedName = "\(UUID().uuidString)-\(source.lastPathComponent)"
        let destination = documentsDirectory.appendingPathComponent(storedName)
        try FileManager.default.copyItem(at: source, to: destination)

        return IPAEntry(
            name: source.deletingPathExtension().lastPathComponent,
            storedFileName: storedName,
            size: size,
            importedAt: Date(),
            sourceURL: nil
        )
    }

    @MainActor
    private func downloadIPA(from address: String) async {
        guard let url = URL(string: address),
              let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              url.host != nil,
              url.pathExtension.lowercased() == "ipa" else {
            statusMessage = "Нужна прямая ссылка на файл с расширением .ipa."
            showStatus = true
            return
        }

        isDownloading = true
        defer { isDownloading = false }

        do {
            let (temporaryURL, response) = try await URLSession.shared.download(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw NSError(domain: "PhoenixIPA", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Сервер вернул ошибку HTTP \(http.statusCode)."])
            }

            let fileName = response.suggestedFilename ?? url.lastPathComponent
            guard fileName.lowercased().hasSuffix(".ipa") else {
                throw NSError(domain: "PhoenixIPA", code: 2, userInfo: [NSLocalizedDescriptionKey: "Ссылка не вернула IPA-файл."])
            }

            let storedName = "\(UUID().uuidString)-\(fileName)"
            let destination = documentsDirectory.appendingPathComponent(storedName)
            try FileManager.default.moveItem(at: temporaryURL, to: destination)

            let attributes = try FileManager.default.attributesOfItem(atPath: destination.path)
            let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0
            let entry = IPAEntry(
                name: url.deletingPathExtension().lastPathComponent,
                storedFileName: storedName,
                size: size,
                importedAt: Date(),
                sourceURL: address
            )
            save(entry)
            statusMessage = "Файл добавлен в библиотеку."
            showStatus = true
        } catch {
            statusMessage = "Ошибка загрузки: \(error.localizedDescription)"
            showStatus = true
        }
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func save(_ entry: IPAEntry) {
        var updated = entries
        updated.removeAll { $0.storedFileName == entry.storedFileName }
        updated.insert(entry, at: 0)
        guard let data = try? JSONEncoder().encode(updated),
              let value = String(data: data, encoding: .utf8) else { return }
        ipaJSON = value
    }

    private func deleteEntry(_ entry: IPAEntry) {
        let fileURL = documentsDirectory.appendingPathComponent(entry.storedFileName)
        try? FileManager.default.removeItem(at: fileURL)
        let updated = entries.filter { $0.id != entry.id }
        guard let data = try? JSONEncoder().encode(updated),
              let value = String(data: data, encoding: .utf8) else { return }
        ipaJSON = value
    }
}

// MARK: - Reusable views

private enum PhoenixStyle {
    static let accent = Color(red: 0.57, green: 0.43, blue: 1.0)
    static let blue = Color(red: 0.23, green: 0.52, blue: 0.95)
    static let panel = Color(red: 0.095, green: 0.105, blue: 0.15)
    static let background = Color(red: 0.035, green: 0.04, blue: 0.065)
}

private extension View {
    func phoenixBackground() -> some View {
        background {
            ZStack {
                PhoenixStyle.background
                LinearGradient(
                    colors: [PhoenixStyle.accent.opacity(0.10), .clear, PhoenixStyle.blue.opacity(0.07)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        }
    }
}

private struct PageHeader: View {
    let eyebrow: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow)
                .font(.system(size: 9, weight: .heavy))
                .tracking(1.4)
                .foregroundStyle(PhoenixStyle.accent)
            Text(title)
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.48))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

private struct SectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.42))
        }
    }
}

private struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 11))
            Text(value)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.06), lineWidth: 1))
    }
}

private struct QuickLink: View {
    let icon: String
    let title: String
    let detail: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.43))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.28))
            }
            .padding(13)
            .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.055), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ManagerPickerCard: View {
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Менеджер пакетов", subtitle: "предпочтительный интерфейс")
            Picker("Менеджер", selection: $selection) {
                Text("Sileo").tag("Sileo")
                Text("Zebra").tag("Zebra")
            }
            .pickerStyle(.segmented)
            HStack(spacing: 7) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Выбран \(selection)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.76))
                Spacer()
                Text("сохранено")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(16)
        .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 21).stroke(.white.opacity(0.06), lineWidth: 1))
    }
}

private struct InfoPanel: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 38, height: 38)
                .background(.orange.opacity(0.13), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.50))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(15)
        .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.055), lineWidth: 1))
    }
}

private struct EmptyState: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 29, weight: .light))
                .foregroundStyle(PhoenixStyle.accent)
                .padding(.bottom, 3)
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.42))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 270)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
    }
}

private struct VaultAction: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(colors: [PhoenixStyle.accent.opacity(0.72), PhoenixStyle.blue.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 19, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct IPAEntryCard: View {
    let entry: IPAEntry
    let onLaunch: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "app.fill")
                    .font(.system(size: 21))
                    .foregroundStyle(PhoenixStyle.accent)
                    .frame(width: 48, height: 48)
                    .background(PhoenixStyle.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(ByteCountFormatter.string(fromByteCount: entry.size, countStyle: .file)) · \(entry.importedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.40))
                }
                Spacer()
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Удалить из библиотеки", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(width: 34, height: 34)
                }
            }

            HStack {
                Label("Сохранено", systemImage: "checkmark.circle.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.green)
                Spacer()
                Button(action: onLaunch) {
                    Label("Запуск", systemImage: "play.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.09), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.06), lineWidth: 1))
    }
}

private struct DownloadIPASheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var address = ""
    let isDownloading: Bool
    let onDownload: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Вставь прямую ссылку на файл .ipa. После загрузки файл появится в твоей библиотеке.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
                TextField("https://example.com/app.ipa", text: $address)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 13))
                Button {
                    onDownload(address.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                } label: {
                    HStack {
                        if isDownloading { ProgressView().tint(.white) }
                        Text(isDownloading ? "Загрузка…" : "Скачать IPA")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(PhoenixStyle.accent, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
                    .font(.subheadline.weight(.bold))
                }
                .disabled(isDownloading || address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding(20)
            .background(PhoenixStyle.background.ignoresSafeArea())
            .navigationTitle("Загрузка IPA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                        .tint(PhoenixStyle.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var url = ""
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Сохрани адрес репозитория, чтобы он появился в твоём списке источников.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                TextField("Название источника", text: $name)
                    .textInputAutocapitalization(.words)
                    .padding(14)
                    .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 13))
                TextField("https://repo.example.com", text: $url)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(PhoenixStyle.panel, in: RoundedRectangle(cornerRadius: 13))
                Button {
                    let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !cleanName.isEmpty, !cleanURL.isEmpty else { return }
                    onSave(cleanName, cleanURL)
                    dismiss()
                } label: {
                    Text("Сохранить источник")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(PhoenixStyle.accent, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                        .font(.subheadline.weight(.bold))
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .padding(20)
            .background(PhoenixStyle.background.ignoresSafeArea())
            .navigationTitle("Новый репозиторий")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .tint(PhoenixStyle.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
