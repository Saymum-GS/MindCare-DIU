# MindCare@DIU Identity Rules

This document outlines the source of truth for handling user identities throughout the application, to prevent bugs where private names overwrite real identities.

## The Two Identities
Every user has two distinct identity strings.

1. `displayName` (Real Profile Name)
2. `pseudonym` (Chat Pseudonym)

### 1. `displayName`
- **Purpose:** Used as the global identifier for the user in non-anonymous contexts (e.g., Home Screen, Profile Dashboard, Settings).
- **Rule:** This should NEVER be automatically generated from random lists. 
- **Initialization:** For anonymous users, this can default to the initial pseudonym. However, once a user upgrades or creates a secured account, they MUST enter a real name, which becomes the permanent `displayName`.
- **Visibility:** Visible only to the user themselves and Admin/Staff accounts (if permitted).

### 2. `pseudonym`
- **Purpose:** Used STRICTLY as an anonymous alias during peer-support and volunteer chats.
- **Rule:** This is generated via `generatePseudonym()` (e.g., "Brave Tiger"). It can be re-rolled by the user during onboarding or inside settings.
- **Initialization:** Generated automatically upon Anonymous Sign-In or Standard Sign-Up.
- **Visibility:** Visible to the user and any peers/volunteers they connect with in the Chat feature.

## Implementation Guidelines
- **UI Surfaces:** `home_screen.dart`, `student_profile_screen.dart`, and `settings_screen.dart` must always read `doc['displayName']`.
- **Chat Surfaces:** `chat_screen.dart` and `volunteer_home_screen.dart` must always read `doc['pseudonym']` (or `session.studentPseudonym`).
- **Database Writes:** Any function creating a user document MUST require both `displayName` and `pseudonym` separately. They should never be hardcoded to be identical unless it's a pure anonymous account.
