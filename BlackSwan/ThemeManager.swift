import SwiftUI
import Combine

// ObservableObject to manage theme settings across the app
class ThemeManager: ObservableObject {
    // Use AppStorage internally for persistence
    @AppStorage("colorThemePreference") var storedTheme: String = ColorThemePreference.standard.rawValue
    @AppStorage("customPrimaryColorData") var customPrimaryColorData: Data?
    @AppStorage("customSecondaryColorData") var customSecondaryColorData: Data?

    // Published property for the selected theme enum
    @Published var selectedTheme: ColorThemePreference = .standard

    // Published properties for custom colors with get/set logic for AppStorage
    @Published var customPrimaryColor: Color = .blue // Default value
    @Published var customSecondaryColor: Color = .cyan // Default value

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Initialize published properties from AppStorage
        self.selectedTheme = ColorThemePreference(rawValue: storedTheme) ?? .standard
        self.customPrimaryColor = color(from: customPrimaryColorData) ?? .blue
        self.customSecondaryColor = color(from: customSecondaryColorData) ?? .cyan

        // Sink changes from published properties back to AppStorage
        $selectedTheme
            .map { $0.rawValue }
            .sink { [weak self] value in
                self?.storedTheme = value
            }
            .store(in: &cancellables)

        $customPrimaryColor
            .map { [weak self] value in self?.data(from: value) }
            .sink { [weak self] data in
                self?.customPrimaryColorData = data
            }
            .store(in: &cancellables)

        $customSecondaryColor
            .map { [weak self] value in self?.data(from: value) }
            .sink { [weak self] data in
                self?.customSecondaryColorData = data
            }
            .store(in: &cancellables)
    }

    // Centralized function to get the appropriate gradient
    func gradient(for swan: Swan? = nil) -> RadialGradient {
        switch selectedTheme {
        case .standard:
            return RadialGradient(colors: [.secondary, .primary], center: .topLeading, startRadius: 10, endRadius: 700)
        case .classificationBased:
            // Use swan's classification if available, otherwise fallback to standard
            if let classification = swan?.classification {
                 return RadialGradient(colors: [classification.secondaryColor, classification.primaryColor], center: .topLeading, startRadius: 10, endRadius: 700)
            } else {
                return RadialGradient(colors: [.secondary, .primary], center: .topLeading, startRadius: 10, endRadius: 700)
            }
        case .custom:
            return RadialGradient(colors: [customSecondaryColor, customPrimaryColor], center: .topLeading, startRadius: 10, endRadius: 700)
        }
    }

    // --- Helper functions for Color <-> Data conversion ---
    private func data(from color: Color) -> Data? {
        let uiColor = UIColor(color)
        // Use secure coding
        return try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
    }

    private func color(from data: Data?) -> Color? {
        guard let data = data,
              // Ensure unarchiving allows UIColor class
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return nil
        }
        return Color(uiColor)
    }
} 