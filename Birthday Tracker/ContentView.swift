//
//  ContentView.swift
//  Birthday Tracker
//
//  Created by Foggin, Oliver (Developer) on 24/08/2021.
//

import SwiftUI
import ComposableArchitecture

enum Sort: LocalizedStringKey, CaseIterable, Hashable {
  case age = "Age"
  case nextBirthday = "Next Birthday"
}

struct PersonListView: Equatable, Identifiable {
  
  static let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .none
    return df
  }()
  
  var person: Person
  var id: UUID { person.id }
  var age: String
  var nextBirthday: String
  
  var title: String {
    person.name
  }
  
  init(person: Person, now: Date, calendar: Calendar) {
    self.person = person
    
    let ageComps = calendar.dateComponents([.year, .month, .day], from: person.dob, to: now)
    
    if ageComps.year! == 1 {
      self.age = "One year old"
    } else if ageComps.year! > 1 {
      self.age = "\(ageComps.year!) years old"
    } else if ageComps.month! == 1 {
      self.age = "1 month old"
    } else if ageComps.month! > 1 {
      self.age = "\(ageComps.month!) months old"
    } else if ageComps.day! == 1 {
      self.age = "1 day old"
    } else if ageComps.day! > 1 {
      self.age = "\(ageComps.day!) days old"
    } else {
      self.age = "unknown age"
    }
    
    self.nextBirthday = Self.dateFormatter.string(
      from: person.nextBirthday(now: now, calendar: calendar)
    )
  }
}

struct AppState: Equatable {
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
  case sortPicked(Sort)
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

struct ContentView: View {
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
            ForEach(Sort.allCases, id: \.self) { sort in
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
                  if (viewStore.sort == .age) {
                    
                  }
                  Text(viewStore.sort == Sort.age ? personListView.age : personListView.nextBirthday)
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
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
