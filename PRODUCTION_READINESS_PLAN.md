# Mafioso Game - Production Readiness Implementation Plan

## Overview
This document tracks the implementation of the production readiness plan based on the analysis in `ai/plan_for_production.md`. The plan addresses 15 issues across three phases.

## Phase Status
- [x] Phase 1: Critical Security & Crash Fixes
- [ ] Phase 2: Architecture & Correctness Fixes
- [ ] Phase 3: Feature Completeness & Polish

## Phase 1: Critical Security & Crash Fixes (Current Focus)
### Tasks:
1. [x] Remove `.env` from bundled assets & secure API keys
2. [x] Make DI graceful when keys are missing
3. [x] Add null-safe JSON parsing in StoryModel
4. [x] Fix `finishReason` field for Groq
5. [x] Fix uncaught throws in GameBloc

## Phase 2: Architecture & Correctness Fixes
### Tasks:
1. [x] Remove data model imports from domain layer
2. [x] Remove localization from domain entity
3. [x] Fix `dart:io` web incompatibility
4. [x] Localize ErrorHandler
5. [x] Guard Android release signing config

## Phase 3: Feature Completeness & Polish
### Tasks:
1. [ ] Wire up `AiProviderCubit` or remove it
2. [ ] Persist theme preference
3. [ ] Rename "grok" to "groq" throughout codebase
4. [ ] Enable R8/ProGuard for release builds

## Verification
After each phase, we will verify:
- Build success: `flutter build apk --release`
- No `.env` in APK
- Offline startup works
- AI story generation works with valid keys
- Groq fallback works
- Offline fallback works
- Full game loop completes
- Theme persistence works
- Translation check passes
- Web build succeeds

## Notes
Last updated: April 24, 2026