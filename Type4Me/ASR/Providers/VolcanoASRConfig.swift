import Foundation

struct VolcanoASRConfig: ASRProviderConfig, Sendable {

    static let provider = ASRProvider.volcano
    static var displayName: String { L("火山引擎 (Doubao)", "Volcano (Doubao)") }

    /// Seed ASR 2.0 - same model, 4.5x cheaper, higher default concurrency
    static let resourceIdSeedASR = "volc.seedasr.sauc.duration"
    /// Legacy big-model resource ID
    static let resourceIdBigASR = "volc.bigasr.sauc.duration"
    /// Auto-detect: try seed first, fall back to bigasr
    static let resourceIdAuto = "auto"

    static var credentialFields: [CredentialField] {[
        CredentialField(key: "appKey", label: "App ID", placeholder: "APPID", isSecure: false, isOptional: false, defaultValue: ""),
        CredentialField(key: "accessKey", label: "Access Token", placeholder: L("访问令牌", "Access token"), isSecure: true, isOptional: false, defaultValue: ""),
        CredentialField(
            key: "resourceId",
            label: L("识别模型", "Model"),
            placeholder: "",
            isSecure: false,
            isOptional: false,
            defaultValue: resourceIdAuto,
            options: [
                FieldOption(value: resourceIdAuto, label: L("自动", "Auto")),
                FieldOption(value: resourceIdSeedASR, label: L("模型 2.0（推荐，更便宜）", "Model 2.0 (recommended, cheaper)")),
                FieldOption(value: resourceIdBigASR, label: L("大模型", "Large Model")),
            ]
        ),
    ]}

    let appKey: String
    let accessKey: String
    let resourceId: String
    let uid: String

    init?(credentials: [String: String]) {
        guard let appKey = credentials["appKey"], !appKey.isEmpty,
              let accessKey = credentials["accessKey"], !accessKey.isEmpty
        else { return nil }
        self.appKey = appKey
        self.accessKey = accessKey
        let raw = credentials["resourceId"] ?? Self.resourceIdAuto
        if raw == Self.resourceIdAuto || raw.isEmpty {
            // Use resolved value from auto-detect, or default to seed
            self.resourceId = credentials["resolvedResourceId"]?.isEmpty == false
                ? credentials["resolvedResourceId"]!
                : Self.resourceIdSeedASR
        } else {
            self.resourceId = raw
        }
        self.uid = ASRIdentityStore.loadOrCreateUID()
    }

    func toCredentials() -> [String: String] {
        ["appKey": appKey, "accessKey": accessKey, "resourceId": resourceId]
    }

    var isValid: Bool {
        !appKey.isEmpty && !accessKey.isEmpty
    }
}
