
import Fluent
import Vapor
struct Constants {
    /// How long should access tokens live for. Default: 15 minutes (in seconds)
    static let ACCESS_TOKEN_LIFETIME: Double = 60 * 15
    /// How long should refresh tokens live for: Default: 7 days (in seconds)
    static let REFRESH_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 7
    /// How long should the email tokens live for: Default 24 hours (in seconds)
    static let EMAIL_TOKEN_LIFETIME: Double = 60 * 60 * 24
    /// Lifetime of reset password tokens: Default 1 hour (seconds)
    static let RESET_PASSWORD_TOKEN_LIFETIME: Double = 60 * 60
}

final class Token: Model, Content {
    typealias User = App.User
    static let schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token_value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @Field(key: "source")
    var source: SessionSource
    
    @Field(key: "is_revoked")
    var isRevoked: Bool

    init() { }

    init(id: UUID? = nil, userID: User.IDValue,source: SessionSource, token: String) {
        self.id = id
        self.$user.id = userID
        self.expiresAt = Date().advanced(by: Constants.REFRESH_TOKEN_LIFETIME)
        self.source = source
        self.value = token
        self.isRevoked = false
    }
}

extension Token: ModelTokenAuthenticatable {
  static let valueKey = \Token.$value
  static let userKey = \Token.$user
  
  var isValid: Bool {
    guard let expiryDate = expiresAt else {
      return true
    }
    
    return expiryDate > Date() && !self.isRevoked
  }
}


