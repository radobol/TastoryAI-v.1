//
//  OpenAIKeyStore.swift
//  TastoryAI
//

import Foundation
import Security

final class OpenAIKeyStore {
    static let shared = OpenAIKeyStore()

    private let service = "mansory.TastoryAI-v-1.openai"
    private let account = "user-api-key"
    private let accessGroup = "NFS6M4BR2B.group.tastoryai.app"

    private init() {}

    var hasKey: Bool {
        (try? load()) != nil
    }

    func load() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let key = String(data: data, encoding: .utf8),
                  !key.isEmpty else {
                throw OpenAIKeyStoreError.invalidStoredValue
            }
            return key
        case errSecItemNotFound:
            return nil
        default:
            throw OpenAIKeyStoreError.unhandledStatus(status)
        }
    }

    func save(_ rawKey: String) throws {
        let key = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            throw OpenAIKeyStoreError.emptyKey
        }

        guard let data = key.data(using: .utf8) else {
            throw OpenAIKeyStoreError.invalidStoredValue
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(
            baseQuery as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecItemNotFound {
            var item = baseQuery
            attributes.forEach { item[$0.key] = $0.value }

            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw OpenAIKeyStoreError.unhandledStatus(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw OpenAIKeyStoreError.unhandledStatus(updateStatus)
        }
    }

    func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw OpenAIKeyStoreError.unhandledStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessGroup as String: accessGroup
        ]
    }
}

enum OpenAIKeyStoreError: LocalizedError {
    case emptyKey
    case invalidStoredValue
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .emptyKey:
            return "Enter an API key before saving."
        case .invalidStoredValue:
            return "The saved API key could not be read."
        case .unhandledStatus(let status):
            let systemMessage = SecCopyErrorMessageString(status, nil) as String?
            return systemMessage ?? "Keychain error (\(status))."
        }
    }
}
