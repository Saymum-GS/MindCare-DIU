# MindCare@DIU

A comprehensive mental health screening and support platform for university students at Daffodil International University.

## Features

### Public Pages
- **Landing Page** - Welcoming introduction with service overview
- **Authentication** - Anonymous registration and sign-in (username-based, privacy-focused)
- **Onboarding Flow** - 3-step consent and introduction process

### Authenticated Features
- **Dashboard** - Personalized home with quick actions and mood tracking
- **Mental Health Screening** - GAD-7 (anxiety) and PHQ-9 (depression) assessments
- **Results & Recommendations** - Risk-level-based results with appropriate support paths
- **Content Library** - Curated articles, audio, and video resources
- **Mood Tracker** - Daily mood logging with history visualization
- **Psychologist Directory** - Browse and book sessions with university counselors
- **Crisis Kit/Safety Plan** - Always-accessible support resources and coping strategies
- **Profile & Settings** - Account management and privacy controls

## Design System

### Colors
- Primary background: `#F7F7F4` (warm off-white)
- Surface: `#FFFFFF`
- Primary accent: `#4A7C6F` (muted teal-green)
- Crisis accent: `#7B5EA7` (calm violet)
- Risk indicators: Low (`#5B8C72`), Medium (`#C8894A`), High (`#B85C5C`)

### Typography
- Display headings: DM Serif Display
- Body & UI: DM Sans
- Emphasis on readability, warmth, and approachability

### Layout
- Desktop-first, fully responsive design
- Max content width: 1100px
- Generous white space and soft shadows
- Rounded corners (16px cards, 10px inputs, pill buttons)

## User Flow

1. Landing → Register (anonymous)
2. Onboarding (3 steps: consent, features, crisis resources)
3. Dashboard → Take check-in
4. Screening questions (one at a time)
5. Results page (low/medium/high risk)
6. Access resources, track mood, or book psychologist

## Privacy & Safety Features

- **Anonymous by design** - Only username stored, no email required
- **Privacy-first messaging** - Reinforced at key moments
- **Crisis FAB** - Floating action button always visible (violet, bottom-right)
- **High-risk support** - Immediate psychologist booking + crisis contacts
- **No clinical language** - Supportive, warm, non-judgmental tone throughout

## Technical Stack

- React 18
- React Router 7 (Data mode)
- Tailwind CSS v4
- TypeScript
- LocalStorage for state persistence (mock auth & data)

## Running the Project

```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm build
```

## Key Components

- `Navbar` - Responsive navigation with mobile menu
- `CrisisFAB` - Floating crisis button (with pulse animation for high-risk users)
- `MobileNav` - Bottom tab bar for mobile
- `Card` - Consistent card component with soft shadows
- `Button` - Primary, secondary, ghost, and crisis variants

## Accessibility

- WCAG AA contrast ratios
- 44px minimum touch targets
- Keyboard navigation support
- Focus states on all interactive elements
- No color-only information conveyance

## Notes

This is a demonstration/prototype built for Figma Make. In a production environment:
- Replace LocalStorage with proper backend (e.g., Supabase)
- Implement real authentication and session management
- Add proper data encryption
- Integrate with university counseling systems
- Implement email notifications for booking confirmations
- Add proper error handling and validation
- Ensure HIPAA/data protection compliance

---

**Built with care for student mental health** 💚
