//
//  NewPerson.swift
//  NewPerson
//
//  Created by Foggin, Oliver (Developer) on 25/08/2021.
//

import SwiftUI
import ComposableArchitecture

struct NewPersonState: Equatable {
  var dob: Date
  var name: String = ""
  var saveButtonDisabled: Bool {
    name.isEmpty
  }
}

enum NewPersonAction {
  case binding(BindingAction<NewPersonState>)
  case saveButtonTapped
  case cancelButtonTapped
}

struct NewPersonEnvironment {}

let newPersonReducer = Reducer<NewPersonState, NewPersonAction, NewPersonEnvironment> {
  state, action, environment in
  
  switch action {
  case .binding:
    return .none
    
  case .saveButtonTapped:
    return .none
    
  case .cancelButtonTapped:
    return .none
  }
}
.binding(action: /NewPersonAction.binding)

struct NewPersonView: View {
  let store: Store<NewPersonState, NewPersonAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        Form {
          TextField(
            "Name",
            text: viewStore.binding(keyPath: \.name, send: NewPersonAction.binding)
          )
          DatePicker(
            "DOB",
            selection: viewStore.binding(keyPath: \.dob, send: NewPersonAction.binding),
            displayedComponents: .date
          )
        }
        .navigationBarTitle("New Person")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              viewStore.send(NewPersonAction.saveButtonTapped)
            } label: {
              Text("Save")
            }
            .disabled(viewStore.saveButtonDisabled)
          }
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              viewStore.send(NewPersonAction.cancelButtonTapped)
            } label: {
              Text("Cancel")
            }
            .disabled(false)
          }
        }
      }
    }
  }
}
