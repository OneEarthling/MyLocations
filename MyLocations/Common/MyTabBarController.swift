//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Nadya K on 10.12.2021.
//

import UIKit

class MyTabBarController: UITabBarController {
    
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
    
  override var childForStatusBarStyle: UIViewController? {
    return nil
  }
    
}
