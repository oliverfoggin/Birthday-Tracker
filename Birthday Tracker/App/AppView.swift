//
//  AppView.swift
//  AppView
//
//  Created by Foggin, Oliver (Developer) on 06/09/2021.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
  let store: Store<AppState, AppAction>
  
  @State private var isActive = false
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        VStack {
          Picker(
            "Sort:",
            selection: viewStore.binding(get: \.sort, send: AppAction.sortPicked).animation()
          ) {
            ForEach(AppState.Sort.allCases, id: \.self) { sort in
              Text(sort.rawValue).tag(sort)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.horizontal)
          
          List {
            ForEach(viewStore.sortedPeople) { personListView in
              NavigationLink(
                tag: personListView.id,
                selection: viewStore.binding(
                  get: \.selectedPersonId,
                  send: AppAction.setSelectedPerson
                )
              ){
                IfLetStore(
                  store.scope(state: \.selectedPerson, action: AppAction.personViewAction),
                  then: PersonView.init(store:),
                  else: { Text("Nothing here") }
                )
              } label: {
                HStack {
                  Text(personListView.title)
                  Spacer()
                  Text(viewStore.sort == .age ? personListView.age : personListView.nextBirthday)
                    .font(.caption)
                }
              }
            }
          }
        }
        .sheet(
          isPresented: viewStore.binding(
            get: \.isNewPersonSheetPresented,
            send: AppAction.setSheet(isPresented:)
          )
        ) {
          IfLetStore(
            self.store.scope(
              state: \.newPersonState,
              action: AppAction.newPersonAction
            ),
            then: NewPersonView.init(store:)
          )
        }
        .navigationBarTitle("Birthdays")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              viewStore.send(AppAction.addButtonTapped)
            } label: {
              Image(systemName: "plus.circle")
            }
          }
        }
        .onAppear {
          if (viewStore.people.count == 0) {
            viewStore.send(.onAppear)
          }
        }
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: .init(
          people: IdentifiedArray(uniqueElements: [
            Person(id: UUID(), name: "Oliver", dob: Date()),
            Person(id: UUID(), name: "Daniel", dob: Date()),
          ])
        ),
        reducer: appReducer,
        environment: AppEnvironment.live
      )
    )
  }
}

