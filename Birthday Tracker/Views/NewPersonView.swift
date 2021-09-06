//
//  NewPersonView.swift
//  NewPersonView
//
//  Created by Foggin, Oliver (Developer) on 06/09/2021.
//

import SwiftUI
import ComposableArchitecture

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
