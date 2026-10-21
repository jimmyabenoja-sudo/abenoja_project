# Activity 9 — Post-Laboratory Reflection Answers
# (SmartTrack: AI-Based International Travel Monitoring System for CSUCC OIGE)

## 1. How does report_form_screen.dart extend your Activity 8 project without replacing its existing Home and Login screens?

report_form_screen.dart was added as a brand-new file under lib/screens/ while the Activity 8 files
(main.dart, app.dart, home_screen.dart, login_screen.dart, widgets/, routes/, constants/, models/,
and services/) were kept intact. The only changes made to existing files were additive: the route
'/report' was registered in app_routes.dart, and a new "File a Report" quick-action button was added
to the Home dashboard's Quick Actions card. The Login screen was not touched at all, and the Home
screen keeps its original navigation, sidebar, stat cards, records, and announcements. The app still
starts at the Login screen and still opens the same dashboard after Sign In, so Activity 9 extends
the project as a second checkpoint rather than a replacement.

## 2. Which shared widget did your group reuse, and what benefit does that provide?

We reused both shared widgets: AppButton (lib/widgets/app_button.dart) and AppTextField
(lib/widgets/app_text_field.dart). AppTextField is used for the Report Title, Destination, and
Description fields in the report form, and it is still used for the Email and Password fields on the
Login screen. AppButton is used for the "Submit Report" action in the report form and for the
"Sign In" action on the Login screen. We only added optional parameters (hint, maxLines, enabled,
and validator for AppTextField; busy for AppButton) so the original Login screen works unchanged.
The benefit is consistency and maintainability: the branded gradient look stays identical across
screens, a fix or style change is made once in one file instead of many, and less duplicate code
has to be written and tested.

## 3. How does your report form prevent invalid input and duplicate submissions?

Invalid input is prevented with a Form keyed by _formKey and a validator on every field. The title
requires at least 5 characters, the Category dropdown must be selected, the Destination is required,
and the Description requires at least 10 characters. When the user taps Submit Report,
_formKey.currentState!.validate() runs first, and if anything is invalid the submission stops and
each field shows its own red validation message under the field. Duplicate submissions are prevented
in two ways: the submitReport() method returns immediately while the state is already loading, and
the shared AppButton receives busy: true, which disables the button and replaces the icon with a
progress spinner, so tapping it repeatedly while the simulated 3-second request is pending has no
effect.

## 4. How did you reproduce the Loading, Success, Empty, and Error responses? Which were simulated?

All four responses were reproduced live in the running Flutter Web app in Chrome:
- LOADING: filled the form with valid data and tapped Submit Report; the button showed a spinner
  with the label "Submitting..." and a "Sending your report, please wait..." message appeared while
  the request was pending.
- SUCCESS: let the 3-second Future.delayed finish; a green confirmation card appeared with
  "Report Submitted Successfully", a reference number, the saved report details, and next actions
  ("File Another Report" and "View Submitted Reports").
- EMPTY: opened the Report Form from the Home screen before any report was filed; the Submitted
  Reports panel showed "No reports yet" with a "File Your First Report" action.
- ERROR: turned on the "Simulate failure (demo)" switch, submitted a valid form, and the submission
  failed after the delay; a red "Submission Failed" card appeared with an explanation, a Retry
  button, and an "Edit Report" option.
All responses were simulated: the submission uses Future.delayed(const Duration(seconds: 3)) as a
stand-in for a real network call, and the failure is a deliberate simulated exception. No real
database record was saved, and the app states this on the screen ("Responses are simulated until the
REST API is connected").

## 5. What must be changed when the real REST API and PostgreSQL database are connected later?

Only the data layer needs to change; the screens and widgets can stay as they are. Specifically:
(1) implement the placeholder ApiClient in lib/services/ using http or dio to call the real REST
endpoints; (2) replace the Future.delayed simulation inside submitReport() with an ApiClient call
that POSTs the report (title, category, destination, description) to the backend; (3) remove the
"_simulateFailure" demo switch and instead map genuine HTTP failures (timeouts, 4xx/5xx responses,
and validation errors returned by the server) to the existing error state; (4) load the Submitted
Reports panel from a GET endpoint, possibly converting the responses into a model class in
lib/models/ similar to the existing Traveler model, so the Empty state appears automatically when
the server returns zero records; and (5) store the PostgreSQL connection string and credentials on
the server side only, never inside the Flutter app. The Loading, Success, Empty, and Error states
already match the four responses needed for handling real API results.

---
# Functional Verification Checklist (Section 6) — completed

Home -> Report Form navigation ......... Working: "File a Report" quick action on the Home
                                         dashboard navigates to /report.
Invalid form produces field-level validation .. Working: each field shows its own error message
                                         (e.g., "Report title is required.").
Valid submit -> Loading -> Success ...... Working: 3-second simulated delay with spinner, then the
                                         green confirmation card.
No available report records -> Empty ... Working: "No reports yet" panel before any report is
                                         filed.
Simulated failure -> Error -> Retry ..... Working: demo switch triggers the red failure card; Retry
                                         re-submits the form.
Shared button or field widget used in two contexts .. Working: AppTextField and AppButton are used
                                         in both the Login screen and the Report Form screen.
