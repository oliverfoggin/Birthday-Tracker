//
//  PersonView.swift
//  PersonView
//
//  Created by Foggin, Oliver (Developer) on 25/08/2021.
//

import SwiftUI
import ComposableArchitecture

struct PersonViewState: Equatable {
  static func == (lhs: PersonViewState, rhs: PersonViewState) -> Bool {
    lhs.person == rhs.person
  }
  
  var person: Person
  var now: () -> Date
  
  @BindableState var isEditSheetPresented = false
  
  var personEditState: PersonEditState {
    get { PersonEditState(person: person) }
    set { person = newValue.person }
  }
  
  static let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeStyle = .none
    df.dateStyle = .full
    return df
  }()
}

enum PersonViewAction: BindableAction {
  case onAppear
  case editAction(PersonEditAction)
  case binding(BindingAction<PersonViewState>)
}

struct PersonViewEnvironment {}

let personViewReducer = Reducer.combine(
  personEditReducer
    .pullback(
      state: \.personEditState,
      action: /PersonViewAction.editAction,
      environment: { _ in PersonEditEnvironment() }
    ),
  Reducer<PersonViewState, PersonViewAction, PersonViewEnvironment> {
    state, action, environment in

    switch action {
    case .onAppear:
      return .none
    case .editAction:
      return .none
    case .binding(_):
      return .none
    }
  }
)
.binding()

struct PersonView: View {
  let store: Store<PersonViewState, PersonViewAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Text(viewStore.person.name)
        
        Text(PersonViewState.dateFormatter.string(from: viewStore.person.dob))
      }
      .sheet(isPresented: viewStore.$isEditSheetPresented) {
        PersonEditView(
          store: store.scope(
            state: \.personEditState,
            action: PersonViewAction.editAction
          )
        )
      }
      .navigationTitle(viewStore.person.name)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .background(Color.yellow)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewStore.send(.set(\.$isEditSheetPresented, true))
          } label: {
            Text("Edit")
          }
        }
      }
    }
  }
}
