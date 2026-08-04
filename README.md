# MindCare@DIU 🧠✨

Welcome to **MindCare@DIU**, a comprehensive, cross-platform mental health and wellness platform custom-built for university students. Designed to provide seamless, secure, and modern digital support, this application bridges the gap between students, psychologists, and crisis intervention teams.

---

## 🌟 Key Highlights & Architecture

- **Sleek & Modern UI/UX:** A carefully crafted, highly responsive design system providing an intuitive user journey and a visually stunning interface across mobile, web, and desktop.
- **Role-Based Access Control:** Distinct, tailored experiences for Students, Psychologists, Volunteers, and Administrators.
- **Real-Time Data & Chat:** Powered by a robust cloud backend (Firebase) to ensure data, bookings, and chat sessions are synced instantly.
- **Secure by Design:** Strict security architectures, pseudonym generators for anonymity, and Firestore database rules implemented to protect user integrity and privacy.
- **Intelligent Crisis Detection:** Smart, contextual workflows including an automated risk engine and crisis keyword detection to assist in emergency interventions.

---

## 🚀 Core Features

### 🎓 For Students
* **Mood Tracking:** Log daily emotions with an interactive emoji picker and visualize mental health trends over time.
* **Clinical Screening:** Take integrated mental health assessments (e.g., PHQ-9) and receive automated risk result analysis.
* **Professional Bookings:** Browse verified psychologists, view calendars, pick slots, and simulate payments for therapy sessions.
* **Content Library:** Access a curated library of mental health articles, grounding exercises, and videos. Bookmark favorites for offline/quick access.
* **Crisis Support:** Instant access to crisis call lines and step-by-step grounding techniques during panic attacks.

### 🧑‍⚕️ For Psychologists & Volunteers
* **Session Management:** Dedicated calendar views to manage upcoming bookings and track patient history.
* **Clinical Notes:** Securely add and manage session notes and summaries after completing appointments.
* **Chat Sessions:** Real-time messaging with students, complete with session ratings and feedback.

### 🛡️ For Administrators
* **Verification System:** Verify student identities and manage psychologist onboarding.
* **Incident Reports:** Track, audit, and manage crisis incidents flagged by the automated risk engine.
* **Audit Dashboard:** Comprehensive oversight of platform usage, content management, and system health.

---

## 🛠️ Technology Stack

- **Frontend Framework:** Flutter & Dart (Cross-Platform)
- **State Management:** Riverpod 🌊 (Predictable, scalable state handling)
- **Cloud Infrastructure:** Firebase 
  - *Authentication* (Secure Identity Management)
  - *Firestore* (Real-Time NoSQL Database)
  - *Cloud Storage* (Asset Management)
- **Design Methodology:** Custom Component-Based Architecture & Responsive Layouts
- **Security:** In-app Crisis Detectors, Content Moderation, & Strict Firestore Rules

---

## 💻 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
- [Dart SDK](https://dart.dev/get-dart)
- A configured Firebase project.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Saymum-GS/MindCare-DIU.git
   cd MindCare-DIU
   ```

2. **Fetch Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```


*MindCare@DIU — Innovating digital experiences for student mental wellness.*
