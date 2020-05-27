//
//  WhatsNewVersionUserDefaultsStore.swift
//  LaVanguardia
//
//  Created by Alexis on 18/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import Foundation
import WhatsNewKit

struct WhatsNewVersionUserDefaultsStore: WhatsNewVersionStore {
    struct Constants {
        static let versionNumberDefaultsKey = "com.grupoGodo.whatsnewDisplay.version"
        static let lastInstalleđVersionDefaultsKey = "com.grupoGodo.whatsnewDisplay.lastVersion"
    }

    private func defaultsKey(for version: WhatsNew.Version) -> String {
        return "\(Constants.versionNumberDefaultsKey).\(version.description)"
    }

    func has(version: WhatsNew.Version) -> Bool {
        return UserDefaults.standard.bool(forKey: defaultsKey(for: version))
    }

    func set(version: WhatsNew.Version) {
        UserDefaults.standard.set(true, forKey: defaultsKey(for: version))
        UserDefaults.standard.set(version.description, forKey: Constants.lastInstalleđVersionDefaultsKey)
    }

    func lastWhatsNewDisplayedVersion() -> WhatsNew.Version? {
        if let storedVersionNumber = UserDefaults.standard.string(forKey: Constants.lastInstalleđVersionDefaultsKey) {
            return WhatsNew.Version(stringLiteral: storedVersionNumber)
        } else {
            return nil
        }
    }
}
