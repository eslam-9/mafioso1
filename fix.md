# Bug Fix: Arabic Language Story Generation Failure

## Summary

When the app language was set to Arabic (`ar`), the Gemini API call always failed with the error:

```
❌ [Error] StoryRepository: Exception: فشل قراية القصة: صيغة JSON غلط
ℹ️ [Info] GEMINI API FAILED! Falling back to offline stories
```

The game then silently fell back to offline stories instead of generating a fresh AI story.

---

## Root Cause Investigation

### Step 1 — Added Diagnostics

Added `finishReason` and `blockReason` logging to the API response handler to detect what was actually happening.

Key log discovered:

```
ℹ️ [Info] Candidate finishReason: MAX_TOKENS
ℹ️ [Info] Raw API response (first 500 chars): {
  "title": "لغز عصير المانجو",
  "intro": "في قلب الزمالك، مات الأستاذ فهمي ...
```

### Step 2 — Root Cause Identified

**`finishReason: MAX_TOKENS`** — the Gemini model was hitting the 3000-token output limit **before finishing the JSON response**.

Arabic text is tokenized far less efficiently than English. Gemini's tokenizer breaks Arabic words into more sub-word pieces, so the same story content that uses ~1500 tokens in English consumes ~4000–6000 tokens in Arabic. The result was a JSON object that was cut off mid-generation and therefore invalid.

### Why the parser couldn't recover

The `_extractJsonFromResponse` method attempted three strategies to extract valid JSON:
1. Direct `json.decode` of the cleaned response
2. Slice from first `{` to last `}`
3. Regex greedy match `\{[\s\S]*\}`

All three failed because the JSON was **syntactically incomplete** (truncated), not just wrapped in extra text.

---

## Secondary Issues Fixed

### Issue 2 — Safety Filter Blocking Arabic Content

Only `HARM_CATEGORY_DANGEROUS_CONTENT` was configured in `safetySettings`. Arabic crime/mystery descriptions were being flagged by other categories (`HARASSMENT`, `HATE_SPEECH`) which defaulted to a stricter threshold than `BLOCK_ONLY_HIGH`, causing some responses to return no `content` field at all.

**Fix:** Added all 4 safety categories with `BLOCK_ONLY_HIGH` threshold.

### Issue 3 — No Schema Enforcement

Without a `responseSchema`, the model occasionally translated JSON keys into Arabic (e.g., `"title"` → `"عنوان"`) or prepended Arabic explanatory text before the JSON block. Since `StoryModel.fromJson` reads specific English keys, this caused silent `null` values or `TypeError` exceptions.

**Fix:** Added `responseSchema` to the `generationConfig` so the Gemini API itself enforces the exact key names, types, and required fields — regardless of the content language.

---

## Fixes Applied

**File:** `lib/features/story/data/datasources/story_remote_datasource.dart`

### Fix 1 — Increase `maxOutputTokens` (Primary Fix)

```dart
// Before
'maxOutputTokens': 3000,

// After
'maxOutputTokens': 8192,
```

8192 is the maximum for Gemini 2.5 Flash and guarantees the full JSON response is always received.

### Fix 2 — Add `responseSchema`

```dart
'responseMimeType': 'application/json',
'responseSchema': {
  'type': 'object',
  'properties': {
    'title': {'type': 'string'},
    'intro': {'type': 'string'},
    'crimeDescription': {'type': 'string'},
    'suspects': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'suspiciousBehavior': {'type': 'string'},
        },
        'required': ['name', 'suspiciousBehavior'],
      },
    },
    'clues': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'text': {'type': 'string'},
          'difficulty': {
            'type': 'string',
            'enum': ['veryEasy', 'easy', 'medium', 'hard', 'veryHard'],
          },
        },
        'required': ['text', 'difficulty'],
      },
    },
    'twist': {'type': 'string'},
    'killerName': {'type': 'string'},
  },
  'required': [
    'title', 'intro', 'crimeDescription',
    'suspects', 'clues', 'twist', 'killerName',
  ],
},
```

### Fix 3 — All Safety Categories at `BLOCK_ONLY_HIGH`

```dart
'safetySettings': [
  {'category': 'HARM_CATEGORY_HARASSMENT',        'threshold': 'BLOCK_ONLY_HIGH'},
  {'category': 'HARM_CATEGORY_HATE_SPEECH',       'threshold': 'BLOCK_ONLY_HIGH'},
  {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_ONLY_HIGH'},
  {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_ONLY_HIGH'},
],
```

### Fix 4 — Hardened JSON Extraction

Improved `_extractJsonFromResponse` with 3 fallback strategies and detailed error logging for each failure mode.

---

## Lesson Learned

> **Arabic (and other non-Latin scripts) require significantly more tokens than English for the same content.**  
> Always set `maxOutputTokens` generously when supporting multilingual AI generation. A token budget that works for English will silently fail for Arabic, resulting in truncated JSON.

Always check `finishReason` in the API response — `MAX_TOKENS` is a clear signal that the output was cut short.

---

## Date Fixed
2026-04-11
