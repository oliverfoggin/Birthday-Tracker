//
//  PersonView.swift
//  PersonView
//
//  Created by Foggin, Oliver (Developer) on 25/08/2021.
//

import SwiftUI
import ComposableArchitecture

struct Person: Identifiable, Equatable, Codable {
  var id: UUID
  var name: String
  var dob: Date
  
  func nextBirthday(now: Date, calendar: Calendar) -> Date {
    let nowYear = calendar.dateComponents([.year], from: now).year!
    
    var dobComps = calendar.dateComponents([.month, .day], from: dob)
    dobComps.year = nowYear
    
    let thisYearBirthday = calendar.date(from: dobComps)!
    
    if thisYearBirthday > now {
      print(thisYearBirthday)
      return thisYearBirthday
    }
    
    let nextYearBirthday = calendar.date(byAdding: .year, value: 1, to: thisYearBirthday)!
    print(nextYearBirthday)
    return nextYearBirthday
  }
}

struct PersonViewState: Equatable {
  static func == (lhs: PersonViewState, rhs: PersonViewState) -> Bool {
    lhs.person == rhs.person
  }
  
  var person: Person
  var now: () -> Date
  
  static let ageFormatter: RelativeDateTimeFormatter = {
    let df = RelativeDateTimeFormatter()
    df.formattingContext = Formatter.Context.listItem
    df.unitsStyle = RelativeDateTimeFormatter.UnitsStyle.spellOut
    df.dateTimeStyle = RelativeDateTimeFormatter.DateTimeStyle.numeric
    return df
  }()
}

enum PersonViewAction {
  case binding(BindingAction<PersonViewState>)
  case onAppear
}

struct PersonViewEnvironment {}

let personViewReducer = Reducer<PersonViewState, PersonViewAction, PersonViewEnvironment> {
  state, action, environment in
  
  switch action {
  case .binding:
    return .none
  case .onAppear:
    return .none
  }
}
  .binding(action: /PersonViewAction.binding)

struct PersonView: View {
  let store: Store<PersonViewState, PersonViewAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Text(viewStore.person.name)
        
        Text(PersonViewState.ageFormatter.localizedString(for: viewStore.person.dob, relativeTo: Date()))
      }
      .navigationTitle(viewStore.person.name)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .background(Color.yellow)
    }
  }
}
