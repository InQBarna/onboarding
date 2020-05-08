//
//  OnboardingAnimation.swift
//  LaVanguardia
//
//  Created by Alexis on 20/02/2020.
//  Copyright © 2020 GrupoGodo. All rights reserved.
//

import UIKit

class OnboardingAnimation {
    // Same animation as the WhatsNewKit .slideUp
    static func animateSlidingUp(_ views: [UIView]) {
        let delay: TimeInterval = 0.2
        views.enumerated().forEach { (
            OnboardingAnimation.animateSlidingUp($0.element, delay: delay + TimeInterval($0.offset) * 0.1)
        ) }
    }

    static func animateSlidingUp(_ view: UIView, delay: TimeInterval) {
        let transform: CGAffineTransform = CGAffineTransform(
            translationX: 0,
            y: view.frame.size.height / 2
        )

        // Apply Transform
        view.transform = transform
        // Set zero alpha
        view.alpha = 0.0
        // Perform animation
        UIView.animate(
            // Duration
            withDuration: 0.5,
            // Delay
            delay: delay,
            // Ease in and out
            options: .curveEaseInOut,
            animations: {
                // Set identity transform
                view.transform = .identity
                // Set default alpha
                view.alpha = 1.0
            }
        )
    }
}
