//
//  SwiftyNinjaConstants.swift
//  Project 23 HWS SwiftyNinja
//
//  Created by Mohammed Qureshi on 2021/01/04.
//

import UIKit
//for challenge 1 created a struct to handle the 'magic numbers'. Seemingly worked. Can be called using dot notation in the GameScene.

struct K {
    static let emitterPosition = CGPoint(x: 76, y: 64)
    static let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
    static let randomAngularVelocity = CGFloat.random(in: -3...3)
    static let randomYVelocity = Int.random(in: 24...33)
}
