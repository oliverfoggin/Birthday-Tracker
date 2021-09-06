//
//  Person.swift
//  Person
//
//  Created by Foggin, Oliver (Developer) on 01/09/2021.
//

import Foundation

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
