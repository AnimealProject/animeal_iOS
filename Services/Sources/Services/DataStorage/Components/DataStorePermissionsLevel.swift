import Foundation

/// The access level for objects in Storage
public enum DataStoreAccessLevel: String {
    /// Objects can be read or written by any user without authentication
    case guest
    /// Objects can be viewed by any user without authentication, but only written by the owner
    case protected
    /// Objects can only be read and written by the owner
    case `private`
}
