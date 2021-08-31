//
//  Birthday_TrackerApp.swift
//  Birthday Tracker
//
//  Created by Foggin, Oliver (Developer) on 24/08/2021.
//

import SwiftUI
import ComposableArchitecture

@main
struct Birthday_TrackerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(
          initialState: .init(),
          reducer: appReducer,
          environment: .live
        )
      )
    }
  }
}
