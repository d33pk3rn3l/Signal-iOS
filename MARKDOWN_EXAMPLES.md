# Markdown Rendering Examples

This document shows real examples of how markdown syntax is rendered in Signal iOS.

## Basic Formatting Examples

### Bold Text

**Input:**
```
This is **important** information!
```

**Output:**
```
This is important information!
     ^^^^^^^^^^^
     (bold)
```

---

### Italic Text

**Input:**
```
Please read this *carefully*.
```

**Output:**
```
Please read this carefully.
                 ^^^^^^^^^
                 (italic)
```

---

### Code/Monospace

**Input:**
```
Run the `git status` command.
```

**Output:**
```
Run the git status command.
        ^^^^^^^^^^
        (monospace)
```

---

### Strikethrough

**Input:**
```
This is ~~wrong~~ correct.
```

**Output:**
```
This is wrong correct.
        ^^^^^
        (strikethrough)
```

---

## Combined Examples

### Multiple Styles in One Message

**Input:**
```
**Important:** Please review the *documentation* and run `npm install`.
```

**Output:**
```
Important: Please review the documentation and run npm install.
^^^^^^^^^                     ^^^^^^^^^^^^^             ^^^^^^^^^^^
(bold)                        (italic)                  (monospace)
```

---

### Adjacent Styles

**Input:**
```
**bold***italic*
```

**Output:**
```
bolditalic
^^^^
(bold)
    ^^^^^^
    (italic)
```

---

### Technical Example

**Input:**
```
To fix the bug:
1. Update **all dependencies**
2. Run `npm test` 
3. Check *error logs*
```

**Output:**
```
To fix the bug:
1. Update all dependencies
           ^^^^^^^^^^^^^^^^
           (bold)
2. Run npm test
       ^^^^^^^^
       (monospace)
3. Check error logs
          ^^^^^^^^^^
          (italic)
```

---

## Real-World Message Examples

### Development Discussion

**Input:**
```
Found a bug in **AuthManager**. The `validateToken()` method is failing. 
Need to check *why* it's happening.
```

**Output:**
```
Found a bug in AuthManager. The validateToken() method is failing.
               ^^^^^^^^^^^     ^^^^^^^^^^^^^^^
               (bold)          (monospace)
Need to check why it's happening.
              ^^^
              (italic)
```

---

### Code Review Comment

**Input:**
```
**LGTM!** Just update the `README.md` and change ~~confusing~~ *unclear* variable names.
```

**Output:**
```
LGTM! Just update the README.md and change confusing unclear variable names.
^^^^^                 ^^^^^^^^^         ^^^^^^^^^
(bold)                (monospace)       (strikethrough)
                                                 ^^^^^^^
                                                 (italic)
```

---

### Task Assignment

**Input:**
```
**TODO:**
- Fix `DatabaseManager` bug
- Update *all* tests
- Remove ~~old~~ deprecated code
```

**Output:**
```
TODO:
^^^^^
(bold)
- Fix DatabaseManager bug
      ^^^^^^^^^^^^^^^
      (monospace)
- Update all tests
         ^^^
         (italic)
- Remove old deprecated code
         ^^^
         (strikethrough)
```

---

## Edge Cases

### Unmatched Delimiters

**Input:**
```
**Not closed and *also not closed
```

**Output:**
```
**Not closed and *also not closed
(no formatting applied - delimiters remain)
```

---

### Empty Text

**Input:**
```
(empty string)
```

**Output:**
```
(empty string)
(no formatting applied)
```

---

### Plain Text

**Input:**
```
Just plain text with no markdown at all.
```

**Output:**
```
Just plain text with no markdown at all.
(no formatting applied)
```

---

### Single Character

**Input:**
```
**a**
```

**Output:**
```
a
^
(bold)
```

---

## Messages with Existing Formatting

### Already Formatted Message

When a message already has explicit Signal formatting (sent with the native rich text editor), markdown parsing is **NOT** applied to preserve the original formatting.

**Input (with existing bold range):**
```
Hello world
(with bold range: 6-11)
```

**Output:**
```
Hello world
      ^^^^^
      (bold - from original formatting)
```

Even if the text contains markdown syntax, it's not parsed:
```
Hello **world**
      ^^^^^
      (bold - from original formatting, asterisks not parsed)
```

---

## Display Locations

Currently, markdown rendering is applied in:

1. **Conversation List Preview**
   - Shows the last message in each conversation
   - Markdown is rendered for visual preview

2. **Notification Preview**
   - Shows message content in notifications
   - Markdown is stripped but formatting metadata is preserved

---

## Integration with Signal Features

### Works With Mentions
Markdown can be combined with Signal's mention system:

**Input:**
```
@Alice please review the **pull request** with `git diff` command.
```

**Output:**
```
@Alice please review the pull request with git diff command.
^^^^^^                    ^^^^^^^^^^^^     ^^^^^^^^
(mention)                 (bold)           (monospace)
```

---

### Preserves Native Formatting
Messages sent with Signal's native formatting toolbar are not affected:

- If you format text as bold using the toolbar, it stays bold
- Markdown in such messages is treated as literal text
- No double-formatting occurs

---

## Technical Notes

1. **Processing Order:**
   - Bold (`**`) processed first (longest delimiter)
   - Italic (`*`) processed second
   - Code (`` ` ``) processed third
   - Strikethrough (`~~`) processed last

2. **Range Adjustment:**
   - As delimiters are removed, all subsequent ranges are adjusted
   - This ensures accurate positioning of styles

3. **Safety:**
   - Only applied to plain text messages
   - Existing formatted messages are left unchanged
   - Unmatched delimiters are left as-is (safe fallback)

4. **Performance:**
   - Single pass through text for each style
   - Regex matching is efficient for typical message lengths
   - Results are cached by the existing hydration system
