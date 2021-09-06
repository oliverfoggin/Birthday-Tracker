//
//  PersonListView.swift
//  PersonListView
//
//  Created by Foggin, Oliver (Developer) on 06/09/2021.
//

import SwiftUI

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
