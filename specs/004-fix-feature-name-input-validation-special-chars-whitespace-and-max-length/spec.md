# Spec: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length

## Summary

Validation fixes for the Feature Name input in the New Session dialog:
1. Special characters (anything outside `[a-z0-9-]`) are rejected with an inline error message.
2. Whitespace-only input keeps the submit button disabled.
3. Input is capped at 100 characters via `maxLength`.
4. Valid names (lowercase letters, numbers, hyphens, starting with letter or number) are accepted.

---

## User Story 1 — Special characters are rejected with an inline error

**As a** user creating a session,
**I want** to see an inline error when I type special characters in the Feature Name field,
**So that** I know immediately what characters are allowed.

### AC1

Given the Feature Name input is focused,
When the user types a value containing special characters (e.g. `my_feature!`),
Then an inline error message is shown below the input explaining the allowed characters.

### AC2

Given an inline validation error is visible,
When the user corrects the input to a valid name (e.g. `my-feature`),
Then the inline error message disappears.

---

## User Story 2 — Whitespace-only input keeps submit disabled

**As a** user creating a session,
**I want** the submit button to remain disabled when I enter only whitespace,
**So that** I cannot accidentally create a session with a blank name.

### AC1

Given the Feature Name input contains only whitespace (e.g. `   `),
When the form is rendered,
Then the Create Session button is disabled.

### AC2

Given the Feature Name input is empty,
When the form is rendered,
Then the Create Session button is disabled.

---

## User Story 3 — Feature name input enforces a maximum length of 100 characters

**As a** user creating a session,
**I want** the Feature Name input to refuse input beyond 100 characters,
**So that** names stay within the supported length limit.

### AC1

Given the Feature Name input,
When the user types or pastes more than 100 characters,
Then the input value is capped at 100 characters (excess characters are not accepted).

---

## User Story 4 — Valid feature names are accepted and allow form submission

**As a** user creating a session,
**I want** valid feature names (lowercase letters, numbers, hyphens, starting with letter or number) to be accepted,
**So that** I can create a session when my input is correct.

### AC1

Given a valid feature name is entered (e.g. `018-new-feature`) and a playbook is selected,
When the form is rendered,
Then the Create Session button is enabled and no validation error is shown.
