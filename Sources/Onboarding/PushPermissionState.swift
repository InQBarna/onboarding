//
//  PushPermissionState.swift
//  Mundo Deportivo
//
//  Created by Alexis on 20/02/2020.
//  Copyright © 2020 GrupoGodo. All rights reserved.
//

import Foundation

enum PushPermissionState {
    case notPrompted
    case denied
    case accepted

    static func currentState(_ completion: @escaping ((PushPermissionState) -> Void)) {
        if GGPushManager.sharedInstance().userHasBeenPromptedForPushPermission {
            GGPushManager.sharedInstance().isRegisteredAndHasEnabledRemoteNotifications {
                (enabled) in
                DispatchQueue.main.async {
                    if enabled {
                        completion(.accepted)
                    } else {
                        completion(.denied)
                    }
                }
            }
        } else {
            completion(.notPrompted)
        }
    }
}
