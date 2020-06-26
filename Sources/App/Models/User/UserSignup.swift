//
//  UserSignup.swift
//  App
//
//  Created by Davide Fastoso on 12/06/2020.
//

import Foundation
import Vapor

struct UserSignup: Content {
  let username: String
  let email: String
  let password: String
}

struct NewSession: Content {
  let token: String
  let user: User.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("username", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}
