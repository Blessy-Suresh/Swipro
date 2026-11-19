
import Foundation

final class AuthenticationService {

    private let defaults = UserDefaults.standard

    var hasAccount: Bool {
        defaults.bool(forKey: "hasAccount")
    }

    func signUp(name: String, email: String, password: String) -> Bool {

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanName.isEmpty,
              cleanEmail.contains("@"),
              password.count >= 6 else {
            return false
        }

        defaults.set(cleanName, forKey: "registeredName")
        defaults.set(cleanEmail, forKey: "registeredEmail")
        defaults.set(password, forKey: "registeredPassword")
        defaults.set(true, forKey: "hasAccount")

        return true
    }

    func login(email: String, password: String) -> Bool {

        let savedEmail = defaults.string(forKey: "registeredEmail") ?? ""
        let savedPassword = defaults.string(forKey: "registeredPassword") ?? ""

        return hasAccount &&
               email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == savedEmail &&
               password == savedPassword
    }
}
