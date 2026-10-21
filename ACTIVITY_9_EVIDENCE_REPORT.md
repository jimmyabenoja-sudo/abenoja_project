# ACTIVITY 9 — EVIDENCE REPORT
**SmartTrack: AI-Based International Travel Monitoring System for CSUCC OIGE**
Course: IT 110 — Web Systems and Technologies | Laboratory Activity No. 9
Student/Group: Jimmy D. Abenoja (same Activity 8 semester-project group)

---

## One-Paragraph Activity 9 Summary

Activity 9 extended the existing Activity 8 Flutter web project — the same repository, folder
structure, and Login/Home screens — without reinitializing the project. A new screen,
`lib/screens/report_form_screen.dart`, was added and registered as the `/report` route in
`lib/routes/app_routes.dart`, and it is reachable from the Home dashboard through a new
"File a Report" quick-action button, so all original navigation remains intact. The form collects
a report title, category, destination/location, and description, and enforces field-level
validation (required fields, minimum lengths) before any submission is accepted. Instead of
duplicating interface code, the screen reuses the Activity 8 shared widgets `AppTextField` (also
used on the Login screen) and `AppButton` (also used for Sign In), which were only extended with
optional parameters so the Login screen works unchanged. The screen implements the four essential
asynchronous UI responses — Loading, Success, Empty, and Error — with `ReportUiState { idle,
loading, success, empty, error }` and a 3-second `Future.delayed` submission; all responses are
**simulated** (no REST API or PostgreSQL yet, and no real database record is saved), with a clearly
labeled "Simulate failure (demo)" switch to reproduce the Error state on demand. Five automated
widget tests pass (`flutter test`), verifying navigation, validation, Loading -> Success, and the
Error -> Retry flow.

## Updated GitHub Repository Link / Commit

- Repository: https://github.com/jimmyabenoja-sudo/abenoja_project
- Branch: `main`
- Activity 9 commit: `e5e1111` — "Add report form and Flutter UI states"
  (direct link: https://github.com/jimmyabenoja-sudo/abenoja_project/commit/e5e1111)
- Previous Activity 8 commit: `22d8849` — "Update README.md" (preserved, same repository)

---

## Six Labeled Screenshots

*(Paste each screenshot below its caption. Capture all of them from the actual project in VS Code
and from the app running in Google Chrome.)*

### Screenshot 1 — Updated screen/widget structure
VS Code Explorer showing the Activity 8 files (main.dart, app.dart, home_screen.dart,
login_screen.dart, widgets/, routes/, constants/, models/, services/) with the new
`lib/screens/report_form_screen.dart`. The folder path/`abenoja_project` is visible in the window.

### Screenshot 2 — Reusable widget used in two contexts + running form
Code showing `AppTextField`/`AppButton` imported and used in `report_form_screen.dart` alongside
their use in `login_screen.dart`, next to a capture of the report form interface running in Google
Chrome showing the four fields and the reused gradient Submit button.

### Screenshot 3 — LOADING
*Trigger: I filled in all four fields with valid data and clicked "Submit Report"; the app entered
the Loading state, showing a spinner inside the now-disabled "Submitting..." button and the message
"Sending your report, please wait..." while the simulated 3-second request was still pending, so
duplicate submissions were blocked.*

### Screenshot 4 — SUCCESS
*Trigger: I let the valid submission finish its simulated 3-second delay, and the app displayed the
green "Report Submitted Successfully" confirmation card with a reference number, the saved report
details, and the "File Another Report" / "View Submitted Reports" next actions.*

### Screenshot 5 — EMPTY
*Trigger: I opened the Report Form from the Home screen's "File a Report" quick action before
filing any report in that session, so the Submitted Reports panel showed the "No reports yet"
no-data response with a "File Your First Report" action — this is the Empty state, not a
validation error.*

### Screenshot 6 — ERROR
*Trigger: I turned on the labeled "Simulate failure (demo)" switch and clicked "Submit Report" with
valid data; after the simulated delay the deliberate simulated failure produced the red
"Submission Failed" explanation with a visible "Retry" button and an "Edit Report" option, and
clicking Retry re-submitted the form.*

---

## Functional Verification Checklist (Section 6)

| Test | Observed outcome |
|---|---|
| Home -> Report Form navigation | "File a Report" quick action on the Home dashboard navigates to `/report`. |
| Invalid form produces field-level validation | Each field shows its own error message (e.g., "Report title is required.", "Please select a category."). |
| Valid submit -> Loading -> Success | 3-second simulated delay with spinner and disabled button, then the green confirmation card. |
| No available report records -> Empty | "No reports yet" panel appears before any report is filed. |
| Simulated failure -> Error -> Retry | Demo switch triggers the red failure card; Retry re-submits the form. |
| Shared button or field widget used in two contexts | `AppTextField` and `AppButton` are used in both the Login screen and the Report Form screen. |

**Note on simulated responses:** all four UI-state responses use `Future.delayed(const
Duration(seconds: 3))` as a stand-in for the future REST API call. No real database record is
saved, and the app states this on-screen ("Responses are simulated until the REST API is connected").
