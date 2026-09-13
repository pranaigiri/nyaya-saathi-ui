# Fix: Phone numbers are typed and presented as unformatted digit strings

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-phone-numbers
- **Needs new dependency**: none

## Why

A 10-digit phone number typed as `9876543210` is difficult to scan for errors. Formatting it as `98765 43210` or `+91 98765 43210` makes verification effortless.

## Where

```dart
// lib/screens/auth/register_screen.dart:275 — current
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number (Optional)",
                    hintText: "10-digit mobile number",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
```

## The fix

Create `lib/core/utils/phone_number_formatter.dart`:
```dart
// target: lib/core/utils/phone_number_formatter.dart
import 'package:flutter/services.dart';

class IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'D'), '');
    if (digits.length > 10) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

Attach formatter to phone fields:
```dart
// target
inputFormatters: [IndianPhoneNumberFormatter()],
```

## Steps

1. Create `lib/core/utils/phone_number_formatter.dart`.
2. In `lib/screens/auth/register_screen.dart:275`, add `inputFormatters: [IndianPhoneNumberFormatter()],`.
3. In `_phoneController.text` extraction, strip whitespace using `.replaceAll(' ', '')`.

## Check it

`dart analyze` exits clean.
`grep -c "IndianPhoneNumberFormatter" lib/screens/auth/register_screen.dart` -> 1.

## Don't touch

- Tracking number formatter.

## STOP if

- Backend rejects phone numbers formatted with spacing (strip spaces before sending to API).

## When you're done

Mobile number input fields format automatically into readable 5-5 digit groups as the citizen types.
