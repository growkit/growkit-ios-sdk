//
//  ChatTextInput.swift
//  
//
//  Created by Zachary Shakked on 9/26/22.
//

import UIKit

public struct ChatTextInput: Chat, JSONObject {
    public let id: String
    public let message: String
    public let required: Bool

    public let placeholder: String
    public let inputType: ChatInputType
        
    public let validator: ChatTextValidator?
    public let keyboardType: UIKeyboardType
    public let returnKey: UIReturnKeyType
    public let contentType: UITextContentType?
    
    public init(message: String,
                inputType: ChatInputType,
                required: Bool) {
        self.id = UUID().uuidString
        self.message = message
        self.required = required
        
        self.placeholder = inputType.placeholder
        self.inputType = inputType
        self.validator = inputType.validator
        self.keyboardType = inputType.keyboardType
        self.returnKey = inputType.returnKey
        self.contentType = inputType.contentType
    }
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.message = json["message"].stringValue
        self.placeholder = json["placeholder"].stringValue
        self.required = json["required"].bool ?? false
        if let inputTypeString = json["inputType"].string, let inputType = ChatInputType(rawValue: inputTypeString) {
            self.inputType = inputType
            self.validator = inputType.validator
            self.keyboardType = inputType.keyboardType
            self.returnKey = inputType.returnKey
            self.contentType = inputType.contentType
        } else {
            self.inputType = .longText
            self.keyboardType = .`default`
            self.returnKey = .done
            self.contentType = nil
            self.validator = nil
        }
    }
    
    var jsonDictionary: [String : Any] {
        var theJSON: [String: Any] = [
            "type": "chatTextInput",
            "id": id,
            "message": message,
            "inputType": inputType.rawValue,
            "required": required,
        ]
        
        return theJSON
    }
}

public enum ChatInputType: String {
    case email
    case password
    case shortText
    case longText
    case number
    case phoneNumber
    
    var placeholder: String {
        switch self {
        case .email:
            return "i.e. john@apple.com"
        case .password:
            return "i.e. password123"
        case .shortText:
            return "enter a short message..."
        case .longText:
            return "enter a few sentences..."
        case .number:
            return "enter a number..."
        case .phoneNumber:
            return  "+17325556358"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .password, .shortText, .longText:
            return .`default`
        case .number:
            return .numberPad
        case .phoneNumber:
            return .phonePad
        }
    }
    
    var returnKey: UIReturnKeyType {
        return .done
    }
    
    var contentType: UITextContentType? {
        switch self {
        case .email:
            return .emailAddress
        case .password:
            return .password
        case .shortText, .longText, .number:
            return nil
        case .phoneNumber:
            return .telephoneNumber
        }
    }
    
    var validator: ChatTextValidator {
        switch self {
        case .email: return ChatTextValidator.email()
        case .password: return ChatTextValidator.length(atLeast: 1, maximum: 32)
        case .shortText: return ChatTextValidator.length(atLeast: 1, maximum: 280)
        case .longText: return ChatTextValidator.length(atLeast: 1, maximum: 1000)
        case .number: return ChatTextValidator(validateText: { text in
            return text.allSatisfy { character in
                character.isNumber
                
            }
        }, errorMessage: "Please enter a valid number.")
        case .phoneNumber: return ChatTextValidator.phoneNumber()
        }
    }
}

extension UIKeyboardType {
    public init?(type: String) {
        switch type {
        case "default":
            self = .`default`
        case "asciiCapable":
            self = .asciiCapable
        case "numbersAndPunctuation":
            self = .numbersAndPunctuation
        case "URL":
            self = .URL
        case "numberPad":
            self = .numberPad
        case "phonePad":
            self = .phonePad
        case "namePhonePad":
            self = .namePhonePad
        case "emailAddress":
            self = .emailAddress
        case "decimalPad":
            self = .decimalPad
        case "twitter":
            self = .twitter
        case "webSearch":
            self = .webSearch
        case "asciiCapableNumberPad":
            self = .asciiCapableNumberPad
        default:
            return nil
        }
    }
    
    public var rawValueString: String {
        switch self {
        case .`default`:
            return "default"
        case .asciiCapable:
            return "asciiCapable"
        case .numbersAndPunctuation:
            return "numbersAndPunctuation"
        case .URL:
            return "URL"
        case .numberPad:
            return "numberPad"
        case .phonePad:
            return "phonePad"
        case .namePhonePad:
            return "namePhonePad"
        case .emailAddress:
            return "emailAddress"
        case .decimalPad:
            return "decimalPad"
        case .twitter:
            return "twitter"
        case .webSearch:
            return "webSearch"
        case .asciiCapableNumberPad:
            return "asciiCapableNumberPad"
        case .alphabet:
            return "alphabet"
        default:
            return "unknown"
        }
    }
    
    static var all: [UIKeyboardType] {
        return [
            .`default`,
            .asciiCapable,
            .numbersAndPunctuation,
            .URL,
            .numberPad,
            .phonePad,
            .namePhonePad,
            .emailAddress,
            .decimalPad,
            .twitter,
            .webSearch,
            .asciiCapableNumberPad,
            .alphabet,
        ]
        
    }
}

extension UIReturnKeyType {
    public init?(type: String) {
        switch type {
        case "default":
            self = .`default`
        case "go":
            self = .go
        case "google":
            self = .google
        case "join":
            self = .join
        case "next":
            self = .next
        case "route":
            self = .route
        case "search":
            self = .search
        case "send":
            self = .send
        case "yahoo":
            self = .yahoo
        case "done":
            self = .done
        case "emergencyCall":
            self = .emergencyCall
        case "continue":
            self = .continue
        default:
            return nil
        }
    }
    
    static var all: [UIReturnKeyType] {
        return [
            .`default`,
            .go,
            .google,
            .join,
            .next,
            .route,
            .search,
            .send,
            .yahoo,
            .done,
            .emergencyCall,
            .continue
        ]
    }
    
    public var rawValueString: String {
        switch self {
        case .`default`:
            return "default"
        case .go:
            return "go"
        case .google:
            return "google"
        case .join:
            return "join"
        case .next:
            return "next"
        case .route:
            return "route"
        case .search:
            return "search"
        case .send:
            return "send"
        case .yahoo:
            return "yahoo"
        case .done:
            return "done"
        case .emergencyCall:
            return "emergencyCall"
        case .continue:
            return "continue"
        default:
            return "default"
        }
    }
}

extension UITextContentType {
    public init?(type: String) {
        switch type {
        case "name":
            self = .name
        case "namePrefix":
            self = .namePrefix
        case "givenName":
            self = .givenName
        case "middleName":
            self = .middleName
        case "familyName":
            self = .familyName
        case "nameSuffix":
            self = .nameSuffix
        case "nickname":
            self = .nickname
        case "jobTitle":
            self = .jobTitle
        case "organizationName":
            self = .organizationName
        case "location":
            self = .location
        case "fullStreetAddress":
            self = .fullStreetAddress
        case "streetAddressLine1":
            self = .streetAddressLine1
        case "streetAddressLine2":
            self = .streetAddressLine2
        case "addressCity":
            self = .addressCity
        case "addressState":
            self = .addressState
        case "addressCityAndState":
            self = .addressCityAndState
        case "sublocality":
            self = .sublocality
        case "countryName":
            self = .countryName
        case "postalCode":
            self = .postalCode
        case "telephoneNumber":
            self = .telephoneNumber
        case "emailAddress":
            self = .emailAddress
        case "URL":
            self = .URL
        case "creditCardNumber":
            self = .creditCardNumber
        case "username":
            self = .username
        case "password":
            self = .password
        case "newPassword":
            self = .newPassword
        case "oneTimeCode":
            self = .oneTimeCode
        case "shipmentTrackingNumber":
            if #available(iOS 15.0, *) {
                self = .shipmentTrackingNumber
            } else {
                return nil
            }
        case "flightNumber":
            if #available(iOS 15.0, *) {
                self = .flightNumber
            } else {
                return nil
            }
        case "dateTime":
            if #available(iOS 15.0, *) {
                self = .dateTime
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    static var all: [UITextContentType] {
        var values: [UITextContentType] = [
                .name,
                .namePrefix,
                .givenName,
                .middleName,
                .familyName,
                .nameSuffix,
                .nickname,
                .jobTitle,
                .organizationName,
                .location,
                .fullStreetAddress,
                .streetAddressLine1,
                .streetAddressLine2,
                .addressCity,
                .addressState,
                .addressCityAndState,
                .sublocality,
                .countryName,
                .postalCode,
                .telephoneNumber,
                .emailAddress,
                .URL,
                .creditCardNumber,
                .username,
                .password,
                .newPassword,
                .oneTimeCode,
        ]
        
        if #available(iOS 15.0, *) {
            values.append(.shipmentTrackingNumber)
        }
    
        if #available(iOS 15.0, *) {
            values.append(.flightNumber)
        }
        if #available(iOS 15.0, *) {
            values.append(.dateTime)
        }
        return values
    }
}
