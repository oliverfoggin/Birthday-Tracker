//
//  PersonView.swift
//  PersonView
//
//  Created by Foggin, Oliver (Developer) on 06/09/2021.
//

import SwiftUI
import ComposableArchitecture

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
