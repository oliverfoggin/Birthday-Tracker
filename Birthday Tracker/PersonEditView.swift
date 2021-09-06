//
//  PersonEditView.swift
//  PersonEditView
//
//  Created by Foggin, Oliver (Developer) on 01/09/2021.
//

import SwiftUI
import ComposableArchitecture

struct PersonEditState: Equatable {
  @BindableState var person: Person
}

enum PersonEditAction: BindableAction {
  case binding(BindingAction<PersonEditState>)
}

struct PersonEditEnvironment {}

let personEditReducer = Reducer<PersonEditState, PersonEditAction, PersonEditEnvironment> {
  _, _, _ in
  return .none
}
.binding()

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
