# Markdown Support in Signal iOS

## Overview

Signal iOS now includes a simple markdown parser that can convert basic markdown syntax into the existing MessageBodyRanges styling system. This provides an easy way to add formatting to messages without requiring explicit formatting controls.

## Supported Syntax

The markdown parser supports these basic formatting options:

- `**text**` - **Bold text**
- `*text*` - *Italic text*  
- `` `text` `` - `Monospace/code text`
- `~~text~~` - ~~Strikethrough text~~

## Usage

### Basic Parsing

To parse markdown in a plain text string:

```swift
let messageBody = MarkdownParser.parse("Hello **world**!")
// Result: MessageBody with text "Hello world!" and bold style on "world"
```

### Integration with MessageBody

For existing MessageBody instances, use the convenience method:

```swift
let messageBody = MessageBody(text: "**Bold** and *italic*", ranges: .empty)
let formatted = messageBody.applyingMarkdownFormatting()
// Result: MessageBody with appropriate bold and italic styles applied
```

This method is safe to use on any MessageBody - it will only apply markdown parsing if the message doesn't already have explicit formatting, preserving Signal's native rich text.

### Display Integration

To integrate markdown rendering into message display:

```swift
// Before hydrating a message body for display:
let messageBody = MessageBody(text: body, ranges: ranges ?? .empty)
    .applyingMarkdownFormatting()  // Apply markdown if no existing formatting
    .hydrating(mentionHydrator: ContactsMentionHydrator.mentionHydrator(transaction: tx))
```

## Design Principles

1. **Simple**: Only basic inline formatting, no complex syntax
2. **Safe**: Won't break existing formatted messages
3. **Minimal**: Leverages existing MessageBodyRanges infrastructure
4. **Non-invasive**: Applied at display time, doesn't modify stored messages

## Implementation Details

- The parser uses regular expressions to find markdown patterns
- Delimiters are removed from the text
- Ranges are adjusted automatically to account for removed delimiters
- Only applies to plain text messages (messages without existing formatting)
- Fully tested with comprehensive unit tests

## Examples

```swift
// Single style
MarkdownParser.parse("Use `git commit` to save changes")
// → "Use git commit to save changes" with monospace on "git commit"

// Multiple styles
MarkdownParser.parse("**Important**: Read *carefully*")
// → "Important: Read carefully" with bold and italic styles

// Adjacent styles
MarkdownParser.parse("**bold***italic*")
// → "bolditalic" with appropriate styles

// Unmatched delimiters are preserved
MarkdownParser.parse("**Not closed")
// → "**Not closed" with no styling
```

## Testing

Comprehensive tests are available in `MarkdownParserTests.swift`, covering:
- All supported markdown styles
- Edge cases (empty strings, unmatched delimiters)
- Multiple and adjacent styles
- Real-world message examples

Run tests:
```bash
xcodebuild test -workspace Signal.xcworkspace -scheme SignalServiceKitTests
```
