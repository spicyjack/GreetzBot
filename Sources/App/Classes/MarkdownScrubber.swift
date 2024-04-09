//
//

import Vapor

public class MarkdownScrubber {
    func escapeMarkdown(_ string: String) -> String {
        let escapedMarkdown = string.replacingOccurrences(
            of: #"([\*_~\|\(\)\[\]\>`#\+\-=\{\}\.\!])"#,
            with: #"\\$1"#,
            options: .regularExpression)

        return escapedMarkdown
    }
}
