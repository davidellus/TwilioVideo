//
//  User.swift
//  App
//
//  Created by Davide Fastoso on 01/06/2020.
//

import Foundation
import Vapor
import Fluent

final class User : Model,Content,ModelAuthenticatable{
    static let schema = "users"
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name : String
    @Field(key: "email") var email : String
    @Field(key: "password_hash") var passwordHash: String
    @Field(key: "user_type") var userType: UserType
    
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at",on: .update) var updatedAt: Date?
    
    
    
    @Children(for: \.$user) var events : [Event]
    init(){}
    
    init(id : UUID? = nil , name : String, passwordHash: String,userType: UserType, email : String){
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.userType = userType
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generateToken() throws -> Token {
        try .init(
            value: [UInt8].random(count: 32).base64,
            userID: self.requireID()
        )
    }
}

enum UserType: String, Content {
    case visitor
    case exibithor
    case admin
}
