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
