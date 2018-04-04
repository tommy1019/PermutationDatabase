import Foundation

extension String
{
    var intValue : Int? {
        get {
            return Int(self)
        }
    }

    var longValue : Int64? {
        get {
            return Int64(self)
        }
    }

    var boolValue : Bool? {
        get {
            return self == "on"
        }
    }
}
