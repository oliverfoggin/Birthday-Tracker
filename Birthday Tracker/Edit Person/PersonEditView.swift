//
//  PersonEditView.swift
//  PersonEditView
//
//  Created by Foggin, Oliver (Developer) on 06/09/2021.
//

import SwiftUI
import ComposableArchitecture

struct PersonEditView: View {
  let store: Store<PersonEditState, PersonEditAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        Form {
          TextField("Name", text: viewStore.$person.name, prompt: Text("Name"))
          
          DatePicker("DOB", selection: viewStore.$person.dob, displayedComponents: .date)
        }
      }
    }
  }
}
