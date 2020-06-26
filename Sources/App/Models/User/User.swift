//
//  User.swift
//  App
//
//  Created by Davide Fastoso on 01/06/2020.
//

import Foundation
import Vapor
import Fluent

final class User : Model,Content{
   struct Public: Content {
     let username: String
     let id: UUID
     let createdAt: Date?
     let updatedAt: Date?
   }
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "username") var username : String
    
    @Field(key: "email") var email : String
    
    @Field(key: "password_hash") var passwordHash: String
    
    @Field(key: "user_type") var userType: UserType
    
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at",on: .update) var updatedAt: Date?
    
    @Children(for: \.$user) var events : [Event]
//    @Children(for: \.$user) var booking : [Booking]
    
    init(){}
    
    init(id : UUID? = nil , username : String, passwordHash: String,userType: UserType, email : String){
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.userType = userType
    }
}

extension User {
  static func create(from userSignup: UserSignup) throws -> User {
    User(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password), userType: .exibithor, email: userSignup.email)
  }
  
  func createToken(source: SessionSource) throws -> Token {
    let calendar = Calendar(identifier: .gregorian)
    let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
    return try Token(userID: requireID(), source: source, token: [UInt8].random(count: 16).base64)
  }

  func asPublic() throws -> Public {
    Public(username: username,
           id: try requireID(),
           createdAt: createdAt,
           updatedAt: updatedAt)
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$passwordHash
  
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}

enum UserType: String, Content {
    case visitor
    case exibithor
    case admin
}
