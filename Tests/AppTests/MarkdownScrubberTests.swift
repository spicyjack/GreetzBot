//
//

@testable import App
import XCTest

final class MarkdownScrubberTests: XCTestCase {
    var testScrubber: MarkdownScrubber!

    override func setUpWithError() throws {
        testScrubber = MarkdownScrubber()
    }

    func test_escapeMarkdown_withSimpleText_shouldReturnEscapedText() {
        let testStrings = ["one*", "two_", "three~", "four|", "five(",
                           "six)", "seven[", "eight]", "nine>", "ten`",
                           "eleven#", "twelve+", "thirteen-", "fourteen=",
                           "fifteen{", "sixteen}", "seventeen.", "eighteen!"
        ]
        for testText in testStrings {
            let scrubbedText = testScrubber.escapeMarkdown(testText)
            switch testText {
                case "one*":
                    XCTAssertEqual("one\\*", scrubbedText)
                case "two_":
                    XCTAssertEqual("two\\_", scrubbedText)
                case "three~":
                    XCTAssertEqual("three\\~", scrubbedText)
                case "four|":
                    XCTAssertEqual("four\\|", scrubbedText)
                case "five(":
                    XCTAssertEqual("five\\(", scrubbedText)
                case "six)":
                    XCTAssertEqual("six\\)", scrubbedText)
                case "seven[":
                    XCTAssertEqual("seven\\[", scrubbedText)
                case "eight]":
                    XCTAssertEqual("eight\\]", scrubbedText)
                case "nine>":
                    XCTAssertEqual("nine\\>", scrubbedText)
                case "ten`":
                    XCTAssertEqual("ten\\`", scrubbedText)
                case "eleven#":
                    XCTAssertEqual("eleven\\#", scrubbedText)
                case "twelve+":
                    XCTAssertEqual("twelve\\+", scrubbedText)
                case "thirteen-":
                    XCTAssertEqual("thirteen\\-", scrubbedText)
                case "fourteen=":
                    XCTAssertEqual("fourteen\\=", scrubbedText)
                case "fifteen{":
                    XCTAssertEqual("fifteen\\{", scrubbedText)
                case "sixteen}":
                    XCTAssertEqual("sixteen\\}", scrubbedText)
                case "seventeen.":
                    XCTAssertEqual("seventeen\\.", scrubbedText)
                case "eighteen!":
                    XCTAssertEqual("eighteen\\!", scrubbedText)

                default:
                    XCTFail("Processed invalid test string: \(scrubbedText)")
            }
        }
    }

    func test_escapeMarkdown_withComplexText_shouldReturnEscapedText() {
        let testString = "*bold _italic bold ~italic bold strikethrough "
            + "||italic bold strikethrough spoiler||~ __underline italic "
            + "bold___ bold*"

        // both of these 'escapedTestString' strings do the same thing
        let escapedTestString = "\\*bold \\_italic bold \\~italic bold "
            + "strikethrough \\|\\|italic bold strikethrough spoiler\\|\\|\\~ "
            + "\\_\\_underline italic bold\\_\\_\\_ bold\\*"
//        let escapedTestString = #"\*bold \_italic bold \~italic bold "#
//            + #"strikethrough \|\|italic bold strikethrough spoiler\|\|\~ "#
//            + #"\_\_underline italic bold\_\_\_ bold\*"#

        let scrubbedText = testScrubber.escapeMarkdown(testString)
        dump("Escaped markdown: \(scrubbedText)")
        XCTAssertEqual(escapedTestString, scrubbedText)
    }

//    func test_replacingRegex_shouldReplaceTextInString() throws {
//        let testString = "*bold _italic bold ~italic bold strikethrough "
//        + "||italic bold strikethrough spoiler||~ __underline italic "
//        + "bold___ bold*"
//        let escapedTestString = #"\*bold \_italic bold \~italic bold "#
//                    + #"strikethrough \|\|italic bold strikethrough spoiler\|\|\~ "#
//                    + #"\_\_underline italic bold\_\_\_ bold\*"#
//        let regex = try Regex("(_)")
//        let escapedMarkdown = testString.replacing(regex,
//                                                   with: "x$1")
//
//        print("Escaped markdown: \(escapedMarkdown)")
//    }
}
