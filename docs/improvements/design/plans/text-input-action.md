# Fix: Form fields lack next/done keyboard actions to streamline navigation and submit

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/text-input-action
- **Needs new dependency**: none

## Why

Users should be able to type through an entire form and submit it directly using the keyboard action button without tapping each field or the submit button manually.

## Where

```dart
// lib/screens/auth/login_screen.dart:126 — current
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address *",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
```

## The fix

Add `textInputAction: TextInputAction.next` to non-last fields, and `textInputAction: TextInputAction.done` with `onSubmitted` to the final field:
```dart
// target: in login_screen.dart
TextField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  decoration: const InputDecoration(
    labelText: "Email Address *",
    prefixIcon: Icon(Icons.email_outlined),
  ),
),
const SizedBox(height: 16),
TextField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  textInputAction: TextInputAction.done,
  onSubmitted: (_) => _handleLogin(),
  decoration: ...,
),
```

## Steps

1. In `lib/screens/auth/login_screen.dart:126`, add `textInputAction: TextInputAction.next` to email field.
2. In `lib/screens/auth/login_screen.dart:136`, add `textInputAction: TextInputAction.done` and `onSubmitted: (_) => _handleLogin()` to password field.
3. In `lib/screens/citizen/tracking_screen.dart:559`, configure `textInputAction: TextInputAction.next` on ID field and `TextInputAction.search` with `onFieldSubmitted: (_) => _trackApplication()` on phone field.

## Check it

`dart analyze` exits clean.
`grep -c "TextInputAction.next" lib/screens/auth/login_screen.dart` -> 1.
`grep -c "TextInputAction.done" lib/screens/auth/login_screen.dart` -> 1.

## Don't touch

- Multiline grievance details fields (multiline text areas must insert newlines).

## STOP if

- Submitting via keyboard bypasses form validation.

## When you're done

Citizens can fill credentials and submit their login or track their cases entirely from the keyboard.
