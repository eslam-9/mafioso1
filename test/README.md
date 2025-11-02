# Testing Guide

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/viewmodels/game_setup_viewmodel_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Structure

```
test/
├── viewmodels/
│   ├── game_setup_viewmodel_test.dart
│   ├── game_viewmodel_test.dart
│   ├── role_reveal_viewmodel_test.dart
│   └── story_viewmodel_test.dart
```

## Test Coverage

Current test coverage includes:
- ✅ GameSetupViewModel - Complete test suite
- ✅ GameViewModel - Vote logic and game state tests
- ✅ RoleRevealViewModel - Role assignment and navigation tests
- ⚠️ StoryViewModel - Basic tests (requires mock setup)

## Setting Up Mocks

For tests requiring mocks (e.g., StoryViewModel), you need to:

1. Run build_runner to generate mocks:
```bash
flutter pub run build_runner build
```

2. Use `@GenerateMocks` annotation in test files:
```dart
@GenerateMocks([StoryRepository, GeminiService])
```

## Adding New Tests

When adding new tests:
1. Follow existing test structure
2. Use descriptive test names
3. Test both success and error cases
4. Use `setUp` and `tearDown` for test fixtures
5. Group related tests using `group()`

## Best Practices

- Test one thing per test
- Use meaningful assertions
- Test edge cases
- Test error conditions
- Keep tests independent
- Use mock objects for external dependencies

