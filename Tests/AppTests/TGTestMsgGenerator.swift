//  
//

import Foundation
@testable import App

class TGTestMsgGenerator {
    // Test Message Generator attributes to be set in an init() method
    // - User ID
    // - Update (Message) ID
    // - IDIncrement - (Default: 7) what to increment the update ID by
    // - MessageDate (Int32)
    // - DateIncrement - (Default: 3) what to increment the Int32 date value by
    var msgDate: Int32
    var updateID: Int64
    var msgID: Int64
    var userID: Int64

    // https://stackoverflow.com/questions/24539679/how-do-i-create-an-array-of-tuples
    var testDatesAndUpdateIDs: [(Int32, Int64)] = []

    init(date msgDate: Int32 = 160000000,
         updateID: Int64 = 7654321,
         msgID: Int64 = 2345678,
         userID: Int64 = 123456) {
        self.msgDate = msgDate
        self.updateID = updateID
        self.msgID = msgID
        self.userID = userID
    }

    // MARK: - Update date/update ID/message ID
    func updateDynamicMsgValues() {
        // store the current values so tests can retrieve them later
        self.testDatesAndUpdateIDs.append((self.msgDate, self.updateID))

        // then increment them for the next time a message is sent
        self.msgDate += 1
        self.updateID += 1
        self.msgID += 1
    }

    // MARK: - Chat/From generators
    func generateTGChat() -> TGChat {
        return TGChat(id: self.userID,
                      type: "private",
                      first_name: "Bob",
                      last_name: "Blowfish",
                      username: "b_blowfish")
    }

    func generateTGUser() -> TGUser {
        return TGUser(id: self.userID,
                      is_bot: false,
                      first_name: "Bob",
                      last_name: "Blowfish",
                      username: "b_blowfish",
                      language_code: "en")
    }

    // MARK: - Message/Command generation functions
    func generateOnlyMessage(_ message: String) -> TGMessage {
        let testMsg =  TGMessage(message_id: self.msgID,
                                 from: self.generateTGUser(),
                                 date: self.msgDate,
                                 chat: self.generateTGChat(),
                                 text: message)
        self.updateDynamicMsgValues()
        return testMsg
    }

    func generatePrivateMessage(_ message: String) -> TGUpdateMessage {
        let testMsg = TGMessage(message_id: self.msgID,
                                from: self.generateTGUser(),
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: message)
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    func generatePrivateMessageFromLastNameIsNil(_ message: String) -> TGUpdateMessage {
        var testTGUser = self.generateTGUser()
        testTGUser.last_name = nil
        let testMsg = TGMessage(message_id: self.msgID,
                                from: testTGUser,
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: message)
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    func generatePrivateMessageFromUsernameIsNil(_ message: String) -> TGUpdateMessage {
        var testTGUser = self.generateTGUser()
        testTGUser.username = nil
        let testMsg = TGMessage(message_id: self.msgID,
                                from: testTGUser,
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: message)
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    func generatePrivateMessageFromLanguageCodeIsNil(_ message: String) -> TGUpdateMessage {
        var testTGUser = self.generateTGUser()
        testTGUser.language_code = nil
        let testMsg = TGMessage(message_id: self.msgID,
                                from: testTGUser,
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: message)
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    func generateCommandMessage(_ command: String) -> TGUpdateMessage {
        let testMsg = TGMessage(message_id: self.msgID,
                                from: self.generateTGUser(),
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: "/\(command)")
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    func generateCommandWithArgMessage(_ command: String,
                                       arg argument: String) -> TGUpdateMessage {
        let testMsg = TGMessage(message_id: self.msgID,
                                from: self.generateTGUser(),
                                date: self.msgDate,
                                chat: self.generateTGChat(),
                                text: "/\(command) \(argument)")
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, message: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    // MARK: Channel Post Generators
    func generateChannelPost(_ message: String) -> TGUpdateMessage {
        let testChat = TGChat(id: self.userID,
                              type: "channel",
                              title: "SuperTestChannel")

        let testMsg = TGMessage(message_id: self.msgID,
                                from: self.generateTGUser(),
                                sender_chat: testChat,
                                date: self.msgDate,
                                chat: testChat,
                                text: message)
        let testUpdMsg = TGUpdateMessage(update_id: self.updateID, channel_post: testMsg)
        self.updateDynamicMsgValues()
        return testUpdMsg
    }

    // MARK: AsyncTelegramClient Message Generators
    func generateAsyncSendMessage(text: String) -> TGSendMessage {
        let testChat = self.generateTGChat()
        self.updateDynamicMsgValues()
        return TGSendMessage(chat_id: testChat.id,
                             text: text)
    }

    // MARK: Spy Reply Message Generators
    func generatePrivateReplyMsg(method: String, text: String) -> TGUpdateReply {
        let testChat = self.generateTGChat()
        self.updateDynamicMsgValues()
        return TGUpdateReply(method: method,
                             chat_id: testChat.id,
                             text: text)
    }

    func generatePrivateReplyMsgWithMsgID(method: String, text: String) -> TGUpdateReply {
        let testChat = self.generateTGChat()
        self.updateDynamicMsgValues()
        return TGUpdateReply(method: method,
                             chat_id: testChat.id,
                             message_id: self.msgID,
                             text: text)
    }

    // MARK: API Response Generators
    func generateSendMessageResponse(successful: Bool, text: String) -> TGResponseSendMessage {
        let testChat = self.generateTGChat()
        self.updateDynamicMsgValues()
        let sendMessage = TGSendMessage(chat_id: testChat.id, text: text)
        return TGResponseSendMessage(ok: successful, result: sendMessage)
    }
}
