//
//  Array.swift
//  Array
//
//  Created by Foggin, Oliver (Developer) on 01/09/2021.
//

import Foundation
import ComposableArchitecture

extension Array where Element: Identifiable {
  var identified: IdentifiedArrayOf<Element> {
    IdentifiedArray(uniqueElements: self)
  }
}
