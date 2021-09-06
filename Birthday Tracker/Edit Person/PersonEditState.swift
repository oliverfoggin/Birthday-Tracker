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
