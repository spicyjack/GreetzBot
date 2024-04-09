//  
//

import Vapor

public enum BotConfigError: Error {
    case missingBotName(_ msg: String)
    case missingTelegramURI(_ msg: String)
    case missingTelegramAPIToken(_ msg: String)
    case missingTestListenPort(_ msg: String)
    case missingAdminChannelID(_ msg: String)
    case cantConvertAdminChannelIDtoInteger(_ msg: String)
}
