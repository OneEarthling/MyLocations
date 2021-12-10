//
//  String+AddText.swift
//  MyLocations
//
//  Created by Nadya K on 10.12.2021.
//

import Foundation

extension String {
    
  mutating func add(text: String?, separatedBy separator: String = "") {
    if let text = text {
        if !isEmpty {
        self += separator
      }
        self += text
    }
  }
    
}
