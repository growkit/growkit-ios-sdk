//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/26/22.
//

import Foundation

public struct ChatTextValidator {
    let validateText: (String) -> Bool
    let errorMessage: String?
    
    public init(validateText: @escaping (String) -> Bool, errorMessage: String?) {
        self.validateText = validateText
        self.errorMessage = errorMessage
        let _ = self.validate(text: "")
    }
    
    public func validate(text: String) -> Bool {
        return validateText(text)
    }
    
    public static func email() -> ChatTextValidator {
        return ChatTextValidator(validateText: { text in
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let test = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            let isValid = test.evaluate(with: text)
            return isValid
        }, errorMessage: "Please enter a valid email address.")
    }
    
    public static func phoneNumber() -> ChatTextValidator {
        return ChatTextValidator(validateText: { text in
            let phoneRegEx = "\\d{3}-\\d{3}-\\d{4}$"
            let test = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
            let isValid = test.evaluate(with: text)
            return isValid
        }, errorMessage: "Please enter a valid phone number.")
    }
    
    public static func length(atLeast: Int, maximum: Int) -> ChatTextValidator {
        return ChatTextValidator(validateText: { text in
            return text.count > atLeast && text.count <= maximum
        }, errorMessage: "Please enter at least \(atLeast) character\(atLeast == 1 ? "" : "s")")
    }
}
