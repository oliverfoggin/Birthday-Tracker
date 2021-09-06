//
//  NewPerson.swift
//  NewPerson
//
//  Created by Foggin, Oliver (Developer) on 25/08/2021.
//

import SwiftUI
import ComposableArchitecture

struct NewPersonState: Equatable {
  @BindableState var dob: Date
  @BindableState var name: String = ""
  var saveButtonDisabled: Bool {
    name.isEmpty
  }
}

enum NewPersonAction: BindableAction {
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
.binding()

struct NewPersonView: View {
  let store: Store<NewPersonState, NewPersonAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        Form {
          TextField("Name", text: viewStore.$name)
          DatePicker("DOB", selection: viewStore.$dob, displayedComponents: .date)
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
