# Calculator App

A Flutter calculator app built for CSC 4360 Mobile Application Development.

## Features

**Part I — Core**
- Number buttons 0-9 and decimal point
- Arithmetic operators: addition, subtraction, multiplication, division
- Display area showing current input and result
- Supports two-operand calculations with chained operations

**Part II — Enhanced Features**
- Theme Toggle: switch between light and dark mode using the sun/moon icon
- C / AC: C clears the current entry, AC resets the entire calculator
- Error Handling: catches division by zero, incomplete input, and invalid states
- Button Press Animations: scale effect and ripple feedback on every tap
- Percentage: converts the current number to a percentage (divides by 100)

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x or later.

## Project Structure

All app logic lives in `lib/main.dart`, organized into labeled sections:

- Calculator state variables
- Error helpers
- C / AC handlers
- Input handlers (digits, dot, operators, equals, percent)
- Arithmetic function (`_compute`)
- UI and widget classes (`_Grid`, `CalcButton`)

## GitHub

[https://github.com/Phyvlik/calculator_app_hw_01](https://github.com/Phyvlik/calculator_app_hw_01)
