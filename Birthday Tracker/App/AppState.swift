//
//  ContentView.swift
//  Birthday Tracker
//
//  Created by Foggin, Oliver (Developer) on 24/08/2021.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
  enum Sort: LocalizedStringKey, CaseIterable, Hashable {
    case age = "Age"
    case nextBirthday = "Next Birthday"
  }
  
  var sort: Sort = .age
  var people: IdentifiedArrayOf<Person> = []
  var newPersonState: NewPersonState?
  var isNewPersonSheetPresented: Bool { self.newPersonState != nil }
  var selectedPerson: PersonViewState?
  var selectedPersonId: Person.ID?
  var sortedPeople: IdentifiedArrayOf<PersonListView> = []
  
  func sortPeople(now: () -> Date, calendar: Calendar) -> IdentifiedArrayOf<PersonListView> {
    let d = now()
    switch sort {
    case .age:
      return people
        .sorted(by: \.dob)
        .map { PersonListView(person: $0, now: d, calendar: calendar) }
        .identified
    case .nextBirthday:
      return people
        .sorted { $0.nextBirthday(now: d, calendar: calendar) < $1.nextBirthday(now: d, calendar: calendar) }
        .map { PersonListView(person: $0, now: d, calendar: calendar) }
        .identified
    }
  }
}

enum AppAction {
  case onAppear
  case addButtonTapped
  case loadedResults(Result<IdentifiedArrayOf<Person>, Never>)
  case newPersonAction(NewPersonAction)
  case personViewAction(PersonViewAction)
  case setSheet(isPresented: Bool)
  case setSelectedPerson(Person.ID?)
  case sortPicked(AppState.Sort)
}

struct AppEnvironment {
  let now: () -> Date
  let fileClient: FileClient
  let uuid: () -> UUID
  let calendar: Calendar
}

extension AppEnvironment {
  static let live = Self.init(
    now: Date.init,
    fileClient: .live,
    uuid: UUID.init,
    calendar: .current
  )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  newPersonReducer
    .optional()
    .pullback(
      state: \.newPersonState,
      action: /AppAction.newPersonAction,
      environment: { _ in NewPersonEnvironment() }
    ),
  personViewReducer
    .optional()
    .pullback(
      state: \AppState.selectedPerson,
      action: /AppAction.personViewAction,
      environment: { _ in PersonViewEnvironment() }
    ),
  Reducer {
    state, action, environment in
    
    switch action {
      
    case .onAppear:
      return environment.fileClient
        .load("people.json")
        .catchToEffect(AppAction.loadedResults)
      
    case let .loadedResults(.success(people)):
      state.people = people
      state.sortedPeople = state.sortPeople(
        now: environment.now,
        calendar: environment.calendar
      )
      return .none
      
    case .loadedResults:
      return .none
      
    case .addButtonTapped:
      state.newPersonState = .init(
        dob: environment.now()
      )
      return .none
      
    case .newPersonAction(.cancelButtonTapped):
      state.newPersonState = nil
      return .none
      
    case .newPersonAction(.saveButtonTapped):
      let newPerson = Person(
        id: environment.uuid(),
        name: state.newPersonState!.name,
        dob: state.newPersonState!.dob
      )
      state.people.append(newPerson)
      state.newPersonState = nil
      state.sortedPeople = state.sortPeople(
        now: environment.now,
        calendar: environment.calendar
      )
      return environment.fileClient
        .save(state.people, "people.json")
        .fireAndForget()
      
    case .newPersonAction:
      return .none
      
    case .setSheet(isPresented: false):
      state.newPersonState = nil
      return .none
      
    case .setSheet:
      return .none
      
    case .personViewAction:
      return environment.fileClient
        .save(state.people, "people.json")
        .fireAndForget()
      
    case let .setSelectedPerson(.some(id)):
      state.selectedPersonId = id
      if let person = state.people[id: id] {
        state.selectedPerson = PersonViewState(person: person, now: environment.now)
      }
      return .none
      
    case .setSelectedPerson(nil):
      state.selectedPersonId = nil
      state.selectedPerson = nil
      return .none
      
    case let .sortPicked(sort):
      state.sort = sort
      state.sortedPeople = state.sortPeople(
        now: environment.now,
        calendar: environment.calendar
      )
      return .none
    }
  }
)
.debug()
