//
//  WhatsNewWrapper.swift
//  Mundo Deportivo
//
//  Created by Alexis on 26/02/2020.
//  Copyright © 2020 GrupoGodo. All rights reserved.
//

import UIKit
import WhatsNewKit

struct WhatsNewWithImageStrings: Codable, Equatable, Hashable {
    struct WhatsNewWithImageStringsItem: Codable, Equatable, Hashable {
        let title: String
        let subtitle: String
        let image: String?

        func toWhatsNewItem() -> WhatsNew.Item? {
            guard let imageName = image,
                let madeImage = UIImage(named: imageName) else {
                return WhatsNew.Item(title: title, subtitle: subtitle, image: nil)
            }

            return WhatsNew.Item(title: title, subtitle: subtitle, image: madeImage)
        }
    }

    let version: WhatsNew.Version
    let title: String
    let items: [WhatsNewWithImageStringsItem]

    public init(version: WhatsNew.Version = .current(inBundle: .main),
                title: String,
                items: [WhatsNewWithImageStringsItem]) {
        self.version = version
        self.title = title
        self.items = items
    }

    func toWhatsNew() -> WhatsNew? {
        return WhatsNew(version: version, title: title, items: items.compactMap { $0.toWhatsNewItem() })
    }
}
