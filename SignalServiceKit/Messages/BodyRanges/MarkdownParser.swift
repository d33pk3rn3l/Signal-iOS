//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/// Simple markdown parser that converts basic markdown syntax to MessageBodyRanges styles.
/// Supports: **bold**, *italic*, `code`, ~~strikethrough~~
///
/// This parser is intentionally simple and focused on basic inline formatting only.
/// It does not support block-level elements, nested formatting, or complex markdown features.
public struct MarkdownParser {
    
    /// Parse markdown text and return a MessageBody with appropriate styles applied
    public static func parse(_ text: String) -> MessageBody {
        guard !text.isEmpty else {
            return MessageBody(text: "", ranges: .empty)
        }
        
        var plainText = text
        var styles: [NSRangedValue<MessageBodyRanges.SingleStyle>] = []
        
        // Process patterns in order, updating ranges as we modify the text
        // Order matters: process longer patterns first to avoid conflicts
        
        // 1. Bold: **text**
        (plainText, styles) = processPattern(
            text: plainText,
            pattern: "\\*\\*(.+?)\\*\\*",
            style: .bold,
            existingStyles: styles,
            delimiterLength: 2
        )
        
        // 2. Italic: *text*
        (plainText, styles) = processPattern(
            text: plainText,
            pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)",
            style: .italic,
            existingStyles: styles,
            delimiterLength: 1
        )
        
        // 3. Code/Monospace: `text`
        (plainText, styles) = processPattern(
            text: plainText,
            pattern: "`(.+?)`",
            style: .monospace,
            existingStyles: styles,
            delimiterLength: 1
        )
        
        // 4. Strikethrough: ~~text~~
        (plainText, styles) = processPattern(
            text: plainText,
            pattern: "~~(.+?)~~",
            style: .strikethrough,
            existingStyles: styles,
            delimiterLength: 2
        )
        
        return MessageBody(
            text: plainText,
            ranges: MessageBodyRanges(mentions: [:], styles: styles)
        )
    }
    
    private static func processPattern(
        text: String,
        pattern: String,
        style: MessageBodyRanges.SingleStyle,
        existingStyles: [NSRangedValue<MessageBodyRanges.SingleStyle>],
        delimiterLength: Int
    ) -> (String, [NSRangedValue<MessageBodyRanges.SingleStyle>]) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (text, existingStyles)
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        guard !matches.isEmpty else {
            return (text, existingStyles)
        }
        
        var mutableText = text
        var newStyles = existingStyles
        var offset = 0
        
        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            
            let fullRange = match.range
            let captureRange = match.range(at: 1)
            
            // Calculate adjusted positions after removing delimiters
            let adjustedFullStart = fullRange.location - offset
            let adjustedCaptureStart = captureRange.location - offset
            let adjustedCaptureLength = captureRange.length
            
            // Remove opening delimiter
            let openingRange = NSRange(location: adjustedFullStart, length: delimiterLength)
            mutableText = (mutableText as NSString).replacingCharacters(in: openingRange, with: "")
            
            // Remove closing delimiter (adjust position after removing opening)
            let closingRange = NSRange(
                location: adjustedCaptureStart + adjustedCaptureLength - delimiterLength,
                length: delimiterLength
            )
            mutableText = (mutableText as NSString).replacingCharacters(in: closingRange, with: "")
            
            // Add style for the content range (after removing delimiters)
            let styledRange = NSRange(
                location: adjustedCaptureStart - delimiterLength,
                length: adjustedCaptureLength
            )
            
            // Adjust existing style ranges that come after this change
            newStyles = newStyles.map { styleValue in
                if styleValue.range.location >= adjustedFullStart {
                    return NSRangedValue(
                        styleValue.value,
                        range: NSRange(
                            location: styleValue.range.location - (delimiterLength * 2),
                            length: styleValue.range.length
                        )
                    )
                }
                return styleValue
            }
            
            newStyles.append(NSRangedValue(style, range: styledRange))
            
            // Update offset for next iteration
            offset += delimiterLength * 2
        }
        
        return (mutableText, newStyles)
    }
}
