//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import XCTest

@testable import SignalServiceKit

final class MarkdownParserTests: XCTestCase {
    
    typealias SingleStyle = MessageBodyRanges.SingleStyle
    
    // MARK: - Basic Formatting Tests
    
    func testBoldText() {
        let result = MarkdownParser.parse("Hello **world**!")
        
        XCTAssertEqual(result.text, "Hello world!")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.bold))
        XCTAssertEqual(collapsedStyle.range, NSRange(location: 6, length: 5))
    }
    
    func testItalicText() {
        let result = MarkdownParser.parse("Hello *world*!")
        
        XCTAssertEqual(result.text, "Hello world!")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.italic))
        XCTAssertEqual(collapsedStyle.range, NSRange(location: 6, length: 5))
    }
    
    func testMonospaceText() {
        let result = MarkdownParser.parse("Use `code` here")
        
        XCTAssertEqual(result.text, "Use code here")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.monospace))
        XCTAssertEqual(collapsedStyle.range, NSRange(location: 4, length: 4))
    }
    
    func testStrikethroughText() {
        let result = MarkdownParser.parse("This is ~~wrong~~ text")
        
        XCTAssertEqual(result.text, "This is wrong text")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.strikethrough))
        XCTAssertEqual(collapsedStyle.range, NSRange(location: 8, length: 5))
    }
    
    // MARK: - Multiple Styles Tests
    
    func testMultipleStyles() {
        let result = MarkdownParser.parse("**Bold** and *italic* text")
        
        XCTAssertEqual(result.text, "Bold and italic text")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 2)
        
        let boldStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(boldStyle.value.style.contains(.bold))
        XCTAssertEqual(boldStyle.range, NSRange(location: 0, length: 4))
        
        let italicStyle = result.ranges.collapsedStyles[1]
        XCTAssertTrue(italicStyle.value.style.contains(.italic))
        XCTAssertEqual(italicStyle.range, NSRange(location: 9, length: 6))
    }
    
    func testAllStyles() {
        let result = MarkdownParser.parse("**bold** *italic* `code` ~~strike~~")
        
        XCTAssertEqual(result.text, "bold italic code strike")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 4)
        
        XCTAssertTrue(result.ranges.collapsedStyles[0].value.style.contains(.bold))
        XCTAssertTrue(result.ranges.collapsedStyles[1].value.style.contains(.italic))
        XCTAssertTrue(result.ranges.collapsedStyles[2].value.style.contains(.monospace))
        XCTAssertTrue(result.ranges.collapsedStyles[3].value.style.contains(.strikethrough))
    }
    
    // MARK: - Edge Cases
    
    func testEmptyString() {
        let result = MarkdownParser.parse("")
        
        XCTAssertEqual(result.text, "")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 0)
    }
    
    func testNoMarkdown() {
        let result = MarkdownParser.parse("Plain text with no markdown")
        
        XCTAssertEqual(result.text, "Plain text with no markdown")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 0)
    }
    
    func testUnmatchedDelimiters() {
        let result = MarkdownParser.parse("**Not closed and *also not closed")
        
        // Unmatched delimiters should remain as-is
        XCTAssertEqual(result.text, "**Not closed and *also not closed")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 0)
    }
    
    func testAdjacentStyles() {
        let result = MarkdownParser.parse("**bold***italic*")
        
        XCTAssertEqual(result.text, "bolditalic")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 2)
        
        let boldStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(boldStyle.value.style.contains(.bold))
        XCTAssertEqual(boldStyle.range, NSRange(location: 0, length: 4))
        
        let italicStyle = result.ranges.collapsedStyles[1]
        XCTAssertTrue(italicStyle.value.style.contains(.italic))
        XCTAssertEqual(italicStyle.range, NSRange(location: 4, length: 6))
    }
    
    func testSingleCharacter() {
        let result = MarkdownParser.parse("**a**")
        
        XCTAssertEqual(result.text, "a")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.bold))
        XCTAssertEqual(collapsedStyle.range, NSRange(location: 0, length: 1))
    }
    
    // MARK: - Real World Examples
    
    func testMessageWithMixedFormatting() {
        let result = MarkdownParser.parse("Check out this **important** update: `npm install` for the *latest* version!")
        
        XCTAssertEqual(result.text, "Check out this important update: npm install for the latest version!")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 3)
        
        // Verify bold
        let boldStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(boldStyle.value.style.contains(.bold))
        
        // Verify monospace
        let codeStyle = result.ranges.collapsedStyles[1]
        XCTAssertTrue(codeStyle.value.style.contains(.monospace))
        
        // Verify italic
        let italicStyle = result.ranges.collapsedStyles[2]
        XCTAssertTrue(italicStyle.value.style.contains(.italic))
    }
    
    func testCodeBlock() {
        let result = MarkdownParser.parse("Run `git commit -m \"message\"` to commit")
        
        XCTAssertEqual(result.text, "Run git commit -m \"message\" to commit")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 1)
        
        let collapsedStyle = result.ranges.collapsedStyles[0]
        XCTAssertTrue(collapsedStyle.value.style.contains(.monospace))
        XCTAssertTrue(result.text.contains("git commit"))
    }
    
    func testMultipleBoldWords() {
        let result = MarkdownParser.parse("**First** word and **second** word")
        
        XCTAssertEqual(result.text, "First word and second word")
        XCTAssertEqual(result.ranges.collapsedStyles.count, 2)
        
        let firstBold = result.ranges.collapsedStyles[0]
        XCTAssertTrue(firstBold.value.style.contains(.bold))
        XCTAssertEqual(firstBold.range, NSRange(location: 0, length: 5))
        
        let secondBold = result.ranges.collapsedStyles[1]
        XCTAssertTrue(secondBold.value.style.contains(.bold))
        XCTAssertEqual(secondBold.range, NSRange(location: 15, length: 6))
    }
}
