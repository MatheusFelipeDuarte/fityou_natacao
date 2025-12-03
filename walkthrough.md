# Walkthrough - New Design Implementation (AquaNível)

I have implemented the new design style based on the `DESIGN MAY` directory. The app now features an Aqua/Blue theme with gradients, bubbles, and the Poppins font.

## Changes

### 1. Dependencies
- Added `google_fonts` to `pubspec.yaml`.

### 2. Theme
- **Colors (`lib/theme/app_colors.dart`)**: Updated the color palette to "AquaNível" (Blue/Cyan/Yellow).
  - `primary`: #01579B (Dark Blue)
  - `primaryLight`: #4FC3F7 (Light Blue)
  - `secondary`: #26C6DA (Cyan)
  - `accent`: #FFD54F (Yellow)
  - Defined gradient colors for Light and Dark modes.
- **Typography (`lib/theme/app_typography.dart`)**: Switched to `GoogleFonts.poppins`.
- **Theme Data (`lib/theme/app_theme.dart`)**: Updated `light()` and `dark()` themes to use the new colors, rounded corners (16px), and styled components.

### 3. UI Components
- **AppBackground (`lib/ui/widgets/app_background.dart`)**: Created a new widget that applies the gradient background and "bubble" decorations, imitating the `Layout.js` design.
- **AppDrawer (`lib/ui/widgets/app_drawer.dart`)**: Updated the header gradient and colors to match the new theme.

### 4. Pages
Updated the following pages to use `AppBackground` and transparent AppBars for a seamless look:
- `StudentSearchPage`
- `StudentsPage`
- `LoginPage`
- `StudentDetailPage`
- `StudentFormPage`
- `ProfilePage`
- `InactiveStudentsPage`
- `StudentEvaluationPage`

### 5. Light Theme Enforcement
- **Global Theme**: Enforced `ThemeMode.light` in `main.dart`.
- **Refactoring**: Removed hardcoded dark theme colors from `StudentsPage`, `InactiveStudentsPage`, and `StudentEvaluationPage`, replacing them with `AppColors` light variants (e.g., `lightSurface`, `lightTextPrimary`).
- **Search Bars**: Updated search bar styles to be white with light text.

## Verification
- The app should now display the blue gradient background with bubbles.
- Buttons and cards should have rounded corners (16px).
- Text should be in Poppins font.
- The primary color should be Blue/Cyan instead of Orange.
