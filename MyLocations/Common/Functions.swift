//
//  Functions.swift
//  MyLocations
//
//  Created by Nadya K on 08.12.2021.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
