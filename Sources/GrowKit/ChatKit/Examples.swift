//
//  Examples.swift
//  
//
//  Created by Zachary Shakked on 10/7/22.
//

import Foundation

public enum Examples {
    
    public static func pmfSurvey(appName: String) -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("Hey! Just wanted to ask you a few quick questions about \(appName)"),
            ChatQuestion(message: "Is that ok?", options: [
                ChatOption("Sure", chats: [
                    ChatQuestion(message: "How would you feel if you could no longer use \(appName)?", options: [
                        ChatOption("Very Disappointed", chats: []),
                        ChatOption("Somewhat Disappointed", chats: []),
                        ChatOption("Not Disappointed", chats: []),
                    ]),
                    ChatTextInput(message: "What is the main benefit you receive from using \(appName)?", inputType: .longText, required: true),
                    ChatTextInput(message: "How did you discover \(appName)?", inputType: .longText, required: true),
                    ChatTextInput(message: "What would you use as an alternative to \(appName) if it no longer existed?", inputType: .longText, required: true),
                    ChatTextInput(message: "How can we improve \(appName) to better meet your needs?", inputType: .longText, required: true),
                    ChatTextInput(message: "What type of person do you think would benefit most from \(appName)?", inputType: .longText, required: true),
                    ChatMessage("Thank you so much for taking the time to answer!"),
                    ChatInstruction(.dismiss),
                ]),
                ChatOption("Not Right Now", chats: [
                    ChatMessage("No problem. Have a good day."),
                    ChatInstruction(.dismiss),
                ])
            ])
        ]
        
        let sequence = ChatSequence(id: "examples-pmf-survey", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func subscriptionCancellation() -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("Hey, I understand you're thinking of cancelling your subscription"),
            ChatQuestion(message: "If you don't mind me asking, how come?", options: [
                ChatOption("Too Expensive", chats: [
                    ChatMessage("Ah, I totally get that. Well..."),
                    ChatQuestion(message: "I actually can offer you a special discount if you'd be interested. How's 40% off?", options: [
                        ChatOption("Sounds Great!", chats: [
                            ChatMessage("Awesome"),
                            ChatMessage("Let me get that started for you..."),
                            ChatInstruction(.purchaseProduct("product_discount"))
                        ]),
                        ChatOption("No, Thanks", chats: [
                            ChatMessage("Ah, sorry."),
                            ChatTextInput(message: "Can you at least tell me what price would be fair?", inputType: .number, required: true),
                            ChatMessage("Thank you, I'll let you go."),
                            ChatInstruction(.openURL(URL(string: "https://support.apple.com/en-us/HT202039")!))
                        ])
                    ])
                ]),
                ChatOption("Not Useful", chats: [
                    ChatQuestion(message: "Are you sure? We have a ton of really great support articles I'd love to show you that will help you find value in the app.", options: [
                        ChatOption("Sounds Good", chats: [
                            ChatMessage("Here you go!"),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials")!))
                        ]),
                        ChatOption("No, Thanks", chats: [
                            ChatTextInput(message: "Can you at least tell us what would make the app more useful?", inputType: .longText, required: true),
                            ChatMessage("Thanks for taking the time to do that. I'll let you go."),
                            ChatInstruction(.openURL(URL(string: "https://support.apple.com/en-us/HT202039")!))
                        ])
                    ]),
                    
                ]),
                ChatOption("Other", chats: [
                    ChatQuestion(message: "I actually can offer you a special discount if you'd be interested. How's 40% off?", options: [
                        ChatOption("Sounds Great!", chats: [
                            ChatMessage("Awesome"),
                            ChatMessage("Let me get that started for you..."),
                            ChatInstruction(.purchaseProduct("product_discount"))
                        ]),
                        ChatOption("No, Thanks", chats: [
                            ChatMessage("Ah, sorry."),
                            ChatTextInput(message: "Can you at least tell us what would make the app more useful?", inputType: .longText, required: true),
                            ChatMessage("Thank you, I'll let you go."),
                            ChatInstruction(.openURL(URL(string: "https://support.apple.com/en-us/HT202039")!))
                        ])
                    ])
                ]),
            ]),
            ChatInstruction(.showCancelButton),
        ]
        let sequence = ChatSequence(id: "examples-subscription-cancellation", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func netPromoterScore() -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("Hey, just a quick question from our team."),
            ChatQuestion(message: "How likely would you be to recommend Hashtag Expert to a friend (10 means very likely and 1 means not likely at all)?", options: [
                ChatOption("10", chats: []),
                ChatOption("9", chats: []),
                ChatOption("8", chats: []),
                ChatOption("7", chats: []),
                ChatOption("6", chats: []),
                ChatOption("5", chats: []),
                ChatOption("4", chats: []),
                ChatOption("3", chats: []),
                ChatOption("2", chats: []),
                ChatOption("1", chats: []),
            ]),
            ChatTextInput(message: "Oh interesting. Can I ask why you chose %@?", inputType: .longText, required: true),
            ChatInstruction(.showCancelButton),
        ]
        let sequence = ChatSequence(id: "examples-nps-survey", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func howdYouHearAboutUs() -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("Hey, welcome to the app! So happy to have you."),
            ChatMessage("Super quick question, then I promise I'll let you get back to the app."),
            ChatQuestion(message: "How'd you hear about us? It would help us so much if you could tell us :)", options: [
                ChatOption("Facebook", chats: [
                    ChatMessage("Ah no way!"),
                    ChatQuestion(message: "Was it from an ad or a post from an influencer?", options: [
                        ChatOption("Ad", chats: [
                            ChatTextInput(message: "What did the ad look like?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Influencer", chats: [
                            ChatTextInput(message: "Which influencer was it?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Other", chats: [
                            ChatTextInput(message: "Anyway you could describe to me? It would help so much...", inputType: .longText, required: true),
                        ])
                    ])
                ]),
                ChatOption("Instagram", chats: [
                    ChatMessage("Ah no way!"),
                    ChatQuestion(message: "Was it from an ad or a post from an influencer?", options: [
                        ChatOption("Ad", chats: [
                            ChatTextInput(message: "What did the ad look like?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Influencer", chats: [
                            ChatTextInput(message: "Which influencer was it?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Other", chats: [
                            ChatTextInput(message: "Anyway you could describe to me? It would help so much...", inputType: .longText, required: true),
                        ])
                    ])
                ]),
                ChatOption("TikTok", chats: [
                    ChatMessage("Ooo I love TikTok!"),
                    ChatQuestion(message: "Was it from an ad or a for you page post?", options: [
                        ChatOption("Ad", chats: [
                            ChatTextInput(message: "What did the ad look like?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Video", chats: [
                            ChatTextInput(message: "It'd make my day if you could share the TikTok video link with me :)", inputType: .longText, required: true),
                        ])
                    ])
                ]),
                ChatOption("Twitter", chats: [
                    ChatMessage("Twitter! I love Twitter."),
                    ChatQuestion(message: "Was it from a twitter thread or was someone talking about the app?", options: [
                        ChatOption("Thread", chats: [
                            ChatTextInput(message: "Any chance you could link me the thread?", inputType: .longText, required: true),
                        ]),
                        ChatOption("Other", chats: [
                            ChatTextInput(message: "Anything else you could tell me about it?", inputType: .longText, required: true),
                        ]),
                    ])
                ]),
                ChatOption("Other", chats: [
                    ChatTextInput(message: "Anything else you could tell me about how you heard about us? (It helps us so much, seriously!)", inputType: .longText, required: true),
                ]),
            ]),
            ChatMessage("Thank you so much for taking the time!"),
            ChatMessage("I'll let you get back to the app now. You're a lifesaver!"),
            ChatInstruction(.rainingEmojis("🥳")),
            ChatInstruction(.showCancelButton),
        ]
        let sequence = ChatSequence(id: "examples-attribution-survey", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func scheduled() -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("You should be seeing this 30 seconds after you pressed the button. If you closed the app, you should've received a notification (unless you denied the notification)."),
            ChatMessage("If you opened the app, but not from the notification, it should still pop up.")
        ]
        let sequence = ChatSequence(id: "scheduled", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func chatWithFounder() -> ChatSequence {
        let chats: [Chat] = [
            ChatMessage("Hey! This is Zach, the founder of Hashtag Expert!"),
            ChatMessage("Ok, so recently I've been trying to understand how people have been using Hashtag Expert"),
            ChatMessage("Your time is valuable, so I'll be brief."),
            ChatMessage("I'd love to chat with you for about 15 minutes about your experience with the app."),
            ChatMessage("I'm also happy to compensate you for your time with a $25 Amazon gift card."),
            ChatQuestion(message: "Will you chat?", options: [
                ChatOption("Sure", chats: [
                    ChatMessage("You are the best!"),
                    ChatQuestion(message: "What's the easiest for you?", options: [
                        ChatOption("Phone Call", chats: [
                            ChatMessage("Great."),
                            ChatTextInput(message: "What's your phone number?", inputType: .phoneNumber, required: true),
                        ]),
                        ChatOption("Zoom Call", chats: [
                            ChatMessage("Sure, I'll open up my Calendly link for you - feel free to pick a time that works for you."),
                            ChatInstruction(.openURL(URL(string: "https://calendly.com/zach-shakked/30-minute-demo")!))
                        ]),
                        ChatOption("Email", chats: [
                            ChatMessage("Sure, happy to coordinate over email."),
                            ChatTextInput(message: "What's your email?", inputType: .email, required: true),
                            ChatMessage("Great, I'll shoot you an email at %@ to coordinate. Talk soon!"),
                        ])
                    ])
                ]),
                ChatOption("No, Sorry", chats: [
                    ChatMessage("No problem at all. Enjoy using the app. I'll let you get back to it!")
                ])
            ]),
            ChatInstruction(.showCancelButton),
        ]
        let sequence = ChatSequence(id: "chatWithFounder", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
    
    public static func supportBot() -> ChatSequence {
        let anythingElse: ChatQuestion = ChatQuestion(message: "Is there anything else I can help you with?", options: [
            ChatOption("Yes", chats: [
                ChatInstruction(.loopEnd("support"))
            ]),
            ChatOption("Nope :)", chats: [
                ChatInstruction(.rainingEmojis("😄")),
                ChatMessage("Ok great! Glad I was able to help you."),
                ChatMessage("If there's anything else, you can always come right back here."),
                ChatMessage("Have a great day!"),
                ChatInstruction(.delay(3.0)),
                ChatInstruction(.dismiss),
            ])
        ])
        
        let contactSupport: [Chat] = [
            ChatMessage("Sorry I wasn't able to directly answer your question."),
            ChatMessage("Let me put you in touch with support directly so you can ask them."),
            ChatInstruction(.openURL(URL(string: "https://command-services.typeform.com/c/RJxRZ4e6")!))
        ]
        
        let chats: [Chat] = [
            ChatMessage("Hey, welcome to support."),
            ChatInstruction(.loopStart("support")),
            ChatRandomMessage(["What can I help you with today?", "Which of these can I help you with?", "Here are a few topics:", "Here are some things I can help you with:"]),
            ChatQuestion(message: "", options: [
                ChatOption("Billing & Subscriptions", chats: [
                    ChatMessage("Sure! No problem."),
                    ChatQuestion(message: "Which of these applies?", options: [
                        ChatOption("Manage Subscription", chats: [
                            ChatMessage("Sure, let me open that up for you."),
                            ChatInstruction(.openURL(URL(string: "https://apps.apple.com/account/subscriptions")!))
                        ]),
                        ChatOption("Subscription Status", chats: [
                            ChatMessage("Sure, let me check on that for you..."),
                            ChatInstruction(.delay(3.0)),
                            ChatMessage("Aha, you have a Pro subscription that expires in 29 days. You don't have auto-renew turned on.")
                        ]),
                        ChatOption("Restore Purchases", chats: [
                            ChatMessage("One moment..."),
                            ChatInstruction(.delay(3.0)),
                            ChatInstruction(.restorePurchases),
                            ChatMessage("Your purchases have been restored!"),
                            ChatInstruction(.rainingEmojis("💸"))
                        ]),
                        ChatOption("Cancel Subscription", chats: subscriptionCancellation().chats),
                        ChatOption("Refunds", chats: [
                            ChatMessage("Oh no, I'm so sorry you got charged. We're going to help you get your money back ASAP."),
                            ChatMessage("I'm going to open up the refund request form for you now..."),
                            ChatMessage("Simply mark the transaction from Hashtag Expert you'd like to get refunded and it should be back in a few days."),
                            ChatMessage("If not, come back here and we'll help you out."),
                            ChatInstruction(.openURL(URL(string: "https://reportaproblem.apple.com")!))
                        ]),
                    ]),
                    anythingElse
                ]),
                ChatOption("Hashtags & Tutorials", chats: [
                    ChatQuestion(message: "Sure, here are a couple topics I can help you with:", options: [
                        ChatOption("Generating Hashtags", chats: [
                            ChatMessage("Here's a super helpful article on %@."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials/how-to-generate-a-group-of-hashtags")!))
                        ]),
                        ChatOption("How to Pick Hashtags", chats: [
                            ChatMessage("Ah, I wrote this really helpful article about that. Check it out."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials/the-four-rules-of-hashtags")!))
                        ]),
                        ChatOption("Trending Tab", chats: [
                            ChatMessage("No prob! Here's how to use the trending tab."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials/trending-hashtags")!))
                        ]),
                        ChatOption("Collections", chats: [
                            ChatMessage("Collections are super cool. Let me show you how to use them."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials/collections-app-feature-hashtag-expert")!))
                        ]),
                        ChatOption("All Articles", chats: [
                            ChatMessage("We have a bunch of great resources!"),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials")!))
                        ]),
                        ChatOption("Other", chats: contactSupport),
                    ]),
                    anythingElse
                ]),
                ChatOption("Instagram", chats: [
                    ChatMessage("We have a lot of super helpful resources on how to use Instagram effectively."),
                    ChatQuestion(message: "Want me to show you them?", options: [
                        ChatOption("Yes", chats: [
                            ChatMessage("Ah, I wrote this really helpful article about that. Check it out."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/tutorials/the-four-rules-of-hashtags")!))
                        ]),
                        ChatOption("Nope", chats: [
                            anythingElse
                        ]),
                        ChatOption("Other", chats: contactSupport),
                    ]),
                ]),
                ChatOption("Connect Facebook Account", chats: [
                    ChatMessage("Connecting your Facebook account to Hashtag Expert is a great way to get advanced analytics."),
                    ChatMessage("We admit, they don't make it easy and it can be a bit confusing."),
                    ChatMessage("Let me help you out a bit"),
                    ChatMessage("So basically, you need to make sure that your Instagram account is a business or creator account. Then, it must be connected to a corresponding Facebook page."),
                    ChatMessage("Then, in Hashtag Expert, you log in using THAT Facebook account."),
                    ChatMessage("This will allow us to show you more personalized hashtags, your best time to post, and other analytics in the app."),
                    ChatQuestion(message: "Did that answer your question or are you still having issues?", options: [
                        ChatOption("Yes", chats: [
                            ChatMessage("Fantastic!"),
                        ]),
                        ChatOption("No", chats: [
                            ChatMessage("Dang. Sorry about that. Here's a link to our FAQs which has more helpful info."),
                            ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/faq")!))
                        ]),
                        ChatOption("Contact Support", chats: contactSupport),
                    ]),
                    anythingElse
                ]),
                ChatOption("FAQs", chats: [
                    ChatMessage("We have a great FAQ."),
                    ChatMessage("Let me take you there"),
                    ChatInstruction(.openURL(URL(string: "https://www.hashtag.expert/faq")!)),
                    anythingElse
                ]),
                ChatOption("Other", chats: [
                    ChatMessage("Let me put you in touch with a support agent."),
                    ChatMessage("One moment..."),
                    ChatInstruction(.openURL(URL(string: "https://command-services.typeform.com/c/RJxRZ4e6")!)),
                    anythingElse
                ]),
            ]),
        ]
        
        
        let sequence = ChatSequence(id: "supportbot", chats: chats)
        sequence.readingSpeed = 1.8
        return sequence
    }
}
