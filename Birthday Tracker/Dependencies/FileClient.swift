//
//  FileClient.swift
//  FileClient
//
//  Created by Foggin, Oliver (Developer) on 25/08/2021.
//

import Foundation
import ComposableArchitecture

struct FileClient {
  struct Failure: Error, Equatable {
    let message: String?
  }
  
  var save: (_ data: IdentifiedArrayOf<Person>, _ fileName: String) -> Effect<Never, Never>
  var load: (_ fileName: String) -> Effect<IdentifiedArrayOf<Person>, Never>
}

extension FileClient {
  static var live = Self.init(
    save: { data, fileName in
      if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let urlPath = directory.appendingPathComponent(fileName)

        do {
          let jsonObject = try JSONEncoder().encode(data)
          try jsonObject.write(to: urlPath)
        } catch {
          // Handle error
        }
      }
      
      return .none
    },
    load: { fileName in
      if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let urlPath = directory.appendingPathComponent(fileName)

        do {
          let data = try Data(contentsOf: urlPath)
          let object = try JSONDecoder().decode(IdentifiedArrayOf<Person>.self, from: data)
          return Effect(value: object)
        } catch {
          // Handle error
        }
      }
      
      return Effect(value: [])
    }
  )
}
