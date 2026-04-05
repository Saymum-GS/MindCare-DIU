Design a complete, responsive web application UI for **MindCare@DIU** — a university mental health screening and support platform for students at Daffodil International University. The design must feel calm, private, trustworthy, and emotionally safe. It is desktop-first with a fully adaptive mobile layout.

---

## DESIGN SYSTEM

**Color Palette**
- Primary background: `#F7F7F4` (warm off-white, never pure white)
- Surface / card background: `#FFFFFF`
- Primary accent: `#4A7C6F` (muted teal-green — calm, not clinical)
- Accent hover: `#3A6359`
- Secondary accent: `#7B9EA6` (soft slate blue — for secondary actions)
- Low-risk indicator: `#5B8C72` (soft green)
- Medium-risk indicator: `#C8894A` (warm amber — never orange-red)
- High-risk indicator: `#B85C5C` (muted rose-red — serious but not alarming)
- Crisis kit accent: `#7B5EA7` (calm violet — distinct but not alarming)
- Text primary: `#1E2A26`
- Text secondary: `#5A6B65`
- Text muted: `#8FA39D`
- Border / divider: `#E2E8E5`
- Disabled state: `#C4CEC9`
- Focus ring: `#4A7C6F` at 40% opacity, 3px offset

**Typography**
- Display headings: DM Serif Display, Regular (400), sizes 36–48px, line-height 1.15
- Section headings (H2, H3): DM Sans, Medium (500), sizes 22–28px, line-height 1.3
- Body copy: DM Sans, Regular (400), 16px, line-height 1.75
- Small / label text: DM Sans, Medium (500), 12–13px, letter-spacing 0.04em
- Screening question text: DM Sans, Regular (400), 20px, line-height 1.6 — must feel conversational, never clinical
- All text must pass WCAG AA contrast

**Spacing System**
- Base unit: 8px
- Component padding: 24px (cards), 32px (sections), 64px (page top padding desktop)
- Card border radius: 16px (main cards), 10px (input fields, chips, tags), 999px (pill buttons)
- Max content width: 1100px, centered
- Column grid: 12-column on desktop, 4-column on tablet, single column on mobile

**Visual Tone**
- Abundant white space — generous breathing room between all elements
- No hard shadows — use 0.5px borders (`#E2E8E5`) and very soft box-shadows (`0 2px 12px rgba(0,0,0,0.05)`)
- No gradients except one allowed instance: a soft warm-to-cool gradient on the landing hero section only
- Rounded, soft shapes throughout — no sharp right-angle cards or harsh UI
- Illustrations: flat, simple, abstract — soft organic shapes representing calm, not literal medical imagery
- No stock photo faces — use abstract shapes, nature references, or geometric calm motifs
- Icon style: 1.5px stroke, rounded caps, Lucide-compatible — never filled icons except for active nav states

**Component Design Principles**
- Every interactive element has three visible states: default, hover, active/selected
- All form inputs have a clear label above (never placeholder-only)
- All buttons have a minimum touch target of 44px height
- Primary CTA: solid fill, `#4A7C6F`, white text, pill shape, 48px height
- Secondary CTA: outlined, `#4A7C6F` border, `#4A7C6F` text, same pill shape
- Destructive/urgent: `#B85C5C` fill — used only for confirmed crisis escalation, never for routine actions
- Disabled buttons: `#C4CEC9` fill, muted text, cursor not-allowed

---

## UX PRINCIPLES

- Every screen must communicate safety and privacy first — reinforce anonymity at key moments
- Cognitive load: no screen should have more than one primary action
- Never use alarming language — result states use soft, factual, supportive copy
- Screening questions appear one at a time (not all at once) — progress bar visible throughout
- Navigation is always visible but never overwhelming — 5 items maximum in main nav
- Crisis kit button is permanently anchored in bottom-right corner of every authenticated screen as a floating action element in calm violet (`#7B5EA7`) with a soft heart-pulse icon — labeled "Need help now?" on desktop
- Empty states are warm and encouraging, never sterile ("Nothing here yet" → "Your content journey starts here")
- Loading states use a soft animated pulse, never a hard spinner
- Error states are reassuring, not alarming — "Something went wrong. Let's try that again."

---

## FULL PAGE & SCREEN LIST

### 1. LANDING PAGE (Pre-login, public)
- Full-width navbar: logo left ("MindCare" wordmark in DM Serif Display + "@DIU" in muted teal), nav links: "How it works" "For students" "Privacy" — right side: "Sign in" (ghost button) + "Get started" (primary pill CTA)
- Hero section: Large serif headline ("Your mental wellbeing, your space."), supporting subheadline (2 lines max, DM Sans 18px regular), two CTAs: "Take the free check-in" (primary) + "Learn how it works" (secondary link), right side: abstract soft illustration (overlapping organic shapes in teal, warm sand, soft green — no faces)
- "How it works" section: horizontal 3-step row with large step numbers (DM Serif Display, 64px, very light teal), each step has an icon, bold label, and 2-line description: Step 1 "Answer a few questions", Step 2 "Understand how you're feeling", Step 3 "Access support that fits you"
- Privacy promise strip: full-width soft teal background band (`#EBF4F1`), left icon (lock), right text: "No name required. No judgment. Your data stays yours." — bold concise statement
- Resource preview section: 3 content cards (teaser of content library) in a horizontal row
- Footer: minimal — logo, privacy policy link, contact email, university affiliation line

### 2. ANONYMOUS REGISTRATION SCREEN
- Centered single-column card (max-width 480px) on warm background
- Top: small lock icon + caption "Your identity is protected"
- Headline: "Create your private space" (DM Serif Display, 32px)
- Sub-copy: "We don't need your name. Just choose a username you'll remember." (14px muted)
- Single input field: "Choose a username" — with helper text below: "This is the only identifier we store."
- Optional: "Or continue with your Student ID" — subtle toggle link below (not a button — a text link)
- If student ID chosen: one masked input field, helper: "Your ID is encrypted and never stored in plain text."
- Primary CTA button: "Create my account" — full width, pill shape
- Below: small text — "Already have an account? Sign in" (link)
- Absolutely no password-strength meters, no email validation, no social login options
- Bottom strip (inside card): "Read our privacy policy" link

### 3. SIGN IN SCREEN
- Same centered card layout as registration
- Headline: "Welcome back"
- One input: username or student ID
- CTA: "Sign in" — full width primary button
- Below CTA: "Forgot your username? Contact support" (link)
- Tone: warm, minimal, no anxiety-inducing security warnings

### 4. CONSENT & ONBOARDING — 3-SCREEN FLOW (Step indicators at top: 3 dots)

**Consent Screen (Step 1 of 3)**
- Large soft illustration (abstract open hands or gentle natural forms)
- Headline: "Before we begin"
- Bulleted list of 4 items in plain English (not legal language): what the app does, what it does not do (it's not a clinical diagnosis), what data is stored, how to delete your account
- Checkbox: "I understand and agree" — must be checked to proceed
- Primary CTA: "I understand, let's continue"

**What to expect (Step 2 of 3)**
- Icon grid (2x2): check-in, content library, mood tracking, psychologist support — each with a title and 1-line description
- Headline: "Here's what MindCare offers"
- CTA: "Looks good"

**Crisis resources intro (Step 3 of 3)**
- Headline: "One thing before you start"
- Body: "If you're ever in distress, help is always one tap away — no matter where you are in the app."
- Show the crisis button as it appears in the app (violet pill, "Need help now?" label) — as a visual preview
- List 2 emergency contacts (DIU counseling line, national helpline) already visible here
- CTA: "Take me to my dashboard"

### 5. DASHBOARD (Post-login home screen)
- Top: persistent navbar — logo left, main nav center (5 items: Home, Check-in, Content, Mood, Psychologists), right: avatar/username chip + "Need help now?" violet pill button
- Left sidebar (desktop only, collapsible): same nav in vertical format, with icons
- Welcome banner: "Good morning, [username]" — warm, personal without being clinical
- If first visit: prominent hero card — "Start with a check-in" — teal background card with serif headline, supporting line, large CTA "Take the check-in →"
- If returning user with previous screening: show last screening summary card (small, date + risk level badge + "Retake check-in" link)
- Mood log widget: "How are you feeling today?" — 5 emoji buttons in a row (very sad → very good), inline, no modal. Below: last 7 days mood as a minimal dot row
- Content recommendations: horizontal scroll row of 3 content cards, labeled "Suggested for you" (based on last risk level, no algorithm label)
- Quick access strip: 3 icon buttons — "Check-in", "Find a psychologist", "Safety plan" — labeled, pill-shaped, soft background color
- Crisis kit FAB: floating violet pill button anchored bottom-right, visible at all times

### 6. MENTAL HEALTH SCREENING — CHECK-IN FLOW

**Screening selector screen**
- Headline: "Which check-in would you like to take?" (DM Serif Display)
- Two large selection cards side by side: "Anxiety check-in (GAD-7)" and "Mood & depression check-in (PHQ-9)" — each with icon, 1-line description, duration tag ("~2 minutes"), and "Start" CTA
- Below cards: "Not sure? Start with anxiety." — soft recommendation text
- Option: "Take both" — secondary link below cards

**Question screen (repeated for each question)**
- Progress bar at top: thin teal bar, "Question 3 of 7" label right-aligned
- Back arrow top-left (exit with confirmation modal)
- Question text: large, centered, conversational — DM Sans 20px regular, max 2 lines — e.g. "Over the past 2 weeks, how often have you felt nervous or anxious?"
- Answer options: 4 vertical radio-button cards, full width — "Not at all", "Several days", "More than half the days", "Nearly every day" — each is a tappable card (48px min height, soft border, selected state: teal fill with white text and checkmark icon)
- No Next button — auto-advance 300ms after selection (with subtle animation), but show "Continue →" button as fallback that appears after 1.5 seconds
- Bottom: "I'd like to skip this check-in" — very small muted link

**Transition screen (between GAD-7 and PHQ-9 if taking both)**
- Brief pause screen: soft illustration, "That's the first part done. Take a breath." — 3 seconds auto-advance or "Continue when ready" button

### 7. RESULTS & RECOMMENDATIONS SCREEN

**Low risk result**
- Top: large soft green checkmark illustration (abstract, not literal)
- Badge: `LOW` — soft green pill badge, text "Your check-in is complete"
- Headline (DM Serif Display, 32px): "You seem to be doing well."
- Body (16px, 2 lines): "Your score suggests you're managing well right now. That can change — and we're here whenever you need us."
- Divider
- "What might help" section: 2 content cards (filtered to low-risk content), "Browse more →" link
- Mood tracker nudge: "Want to track how you feel day to day?" — small card with CTA
- Bottom: "Retake in 2 weeks" — muted suggestion, not a button

**Medium risk result**
- Top: soft amber/warm illustration (abstract — gentle light shape, not alarming)
- Badge: `MEDIUM` — warm amber pill
- Headline: "It sounds like things have been tough."
- Body: "Your answers suggest you might be experiencing some anxiety or low mood. You don't have to manage this alone."
- Three action cards in a row: "Read helpful content", "Track your mood", "Talk to a psychologist" — the third card is slightly more prominent (soft teal border emphasis)
- Crisis kit reminder strip at bottom: "If things feel urgent, your safety plan is always here." with violet link

**High risk result — CRITICAL DESIGN STATE**
- This screen has a distinct visual treatment — NOT alarming, but clearly prioritized
- Top background: very soft rose tint (`#FDF2F1`) instead of default off-white — subtle warmth, not danger-red
- No alarming badge — instead: a soft violet care icon (heart or hands)
- Headline (DM Serif Display, 28px): "Thank you for being honest with yourself."
- Body: "Your answers suggest you may be going through something significant. You don't need to handle this alone, and reaching out is a sign of strength."
- LARGE primary CTA (full width, 56px, teal): "Talk to a psychologist today"
- SECONDARY CTA: "View your safety plan" — violet outlined pill, full width
- Below: collapsible section "Immediate support" — pre-expanded — shows: DIU counseling phone number (bold, large), national helpline, one-tap call button for each
- Small text at bottom: "Your check-in result is private. Only you can see this."
- Crisis kit FAB remains visible — same violet

### 8. CONTENT LIBRARY — LIST VIEW
- Page header: "Resources for you" — DM Serif Display 36px, sub-label "Curated for your wellbeing"
- Filter bar: horizontal pill chip row — "All", "Anxiety", "Exam stress", "Sleep", "Low mood", "Relationships" — active chip: teal fill, white text; inactive: white fill, teal border
- Format filter (secondary row): "All formats", "Articles", "Audio", "Video" — same chip style, smaller
- Results grid: 3-column desktop, 2-column tablet, 1-column mobile
- Content card: 280px wide — cover image area (solid tinted block with category color if no image), format badge (top-left: "Article" / "Audio" / "Video"), bookmark icon (top-right, outlined, fills on save), title (DM Sans 16px medium, 2 lines max), topic chip, read time or duration label (small muted text), no author credit
- Empty state: soft illustration (open book, abstract), "No results for this filter. Try another topic." — with "Show all" link
- Pagination: simple numbered pagination, not infinite scroll (reduces cognitive overload)

### 9. CONTENT DETAIL VIEW
- Breadcrumb: "Content → [Topic]" at top, small muted text
- Back arrow
- Format badge + topic chip at top
- Title: DM Serif Display, 32px
- Duration / read time label
- Bookmark button: outlined heart icon, top right
- For articles: clean prose layout, max 680px content width, 18px body text, generous paragraph spacing
- For audio: large play button centered, progress scrubber bar (teal), time display — minimal player, no queue or playlist
- For video: full-width embedded player (16:9 ratio), no autoplay
- Below content: "More like this" — 3 content cards in a row
- Bottom: soft strip — "Feeling like you need more support?" — CTA to psychologist directory

### 10. MOOD TRACKER — FULL VIEW
- Page header: "Your mood journal"
- Today's log (if not done): "How are you feeling today?" — 5 large emoji buttons in a row — centered, generous spacing, each 64px circle — on selection: selected emoji enlarges (120%), others dim; optional text field appears below ("Add a note (optional)") — "Save" CTA appears
- If already logged today: confirmation state — "Logged for today ✓" in soft teal, show selected emoji large
- Below: "Your recent mood" section — last 14 days as a row of small emoji dots with date labels below — tapping any dot shows a mini popover with that day's note
- No charts or trend analysis in MVP — just the dot row
- Rescreen nudge (if last screening was 14+ days ago): soft banner — "It's been a while. Want to take a quick check-in?" with "Yes, let's go" CTA — dismissable with X

### 11. PSYCHOLOGIST DIRECTORY
- Page header: "Find support" — DM Serif Display, sub-label "Our university psychologists are here for you"
- Introductory callout strip: soft teal background, icon, text — "Sessions are confidential. Booking is just a request — no commitment."
- Psychologist cards: 2-column grid desktop, 1-column mobile — each card: photo placeholder (soft teal circle with initials monogram), name, title/specialization chips (pill tags: "Anxiety", "Academic stress", "Grief"), availability label ("Available this week" in green, or "Next available [date]"), "Request a session" CTA button (secondary outlined)
- Clicking a card opens a detail panel (right drawer on desktop, full screen on mobile): full bio (2–3 paragraphs), specializations listed, availability calendar picker (week view, clickable day slots: available = teal, unavailable = muted gray)

### 12. BOOKING REQUEST FLOW — 3 STEPS

**Step 1: Select a time slot**
- Week view calendar: 7 columns (Mon–Sun), available slots shown as teal pill chips inside each day, unavailable slots shown as light gray text — clicking a slot selects it (filled teal, white text, checkmark)
- Selected slot shown in a confirmation summary chip at the top right
- CTA: "Choose this time →"

**Step 2: Add a message (optional)**
- Headline: "Anything you'd like them to know beforehand?"
- Large textarea (4 rows min): placeholder text — "For example: I've been feeling anxious about exams lately." — soft border, rounded
- Helper text below: "This is optional and shared only with your psychologist."
- Character count (max 500) — bottom right of textarea
- Primary CTA: "Send my request"
- Secondary link: "Skip and send without a message"

**Step 3: Confirmation screen**
- Large soft checkmark illustration (abstract green circle)
- Headline: "Your request has been sent."
- Summary block: psychologist name, selected time slot, message preview (if added)
- Body: "Your psychologist will confirm your session by email. This usually takes 1–2 business days."
- Two CTAs: "Back to home" (primary) + "Browse resources while you wait" (secondary link)

### 13. CRISIS KIT / SAFETY PLAN (Always-accessible page)

**Entry: via FAB ("Need help now?" violet pill) or from nav**
- This page has a distinct calm background: very soft lavender tint (`#F5F3FA`)
- NO alarming red anywhere on this page
- Top: soft violet header band — "You reached out. That matters." — DM Serif Display, white text
- Section 1 — "Right now, you can": three action cards: "Take a slow breath" (links to short audio), "Read coping strategies" (inline expand), "Call for support" (links to Section 3)
- Section 2 — "Signs that things are getting harder": bulleted list in plain language — 5–6 items — what to watch for — framed supportively, not as a diagnostic checklist
- Section 3 — "Immediate support contacts": two large cards (full width): DIU Counseling Center (phone number, hours, large teal "Call now" button), National Mental Health Helpline (phone number, large outlined "Call now" button) — phone numbers in 32px DM Serif Display for immediate readability
- Section 4 — "Coping strategies": 4 collapsible accordion items — breathing exercise, grounding technique, distraction strategy, self-compassion prompt — each expands inline with step-by-step instructions
- Footer of this page: "This page is always here for you. You don't have to be in crisis to use it."
- No login required to view this page — accessible from the public landing too

### 14. PROFILE & SETTINGS (Minimal)
- Page header: "Your account"
- Username display (not editable)
- Account creation date
- Toggle: "Sync mood data to server" — off by default, with explanation text
- Link: "Download my data" — initiates email with data export
- Link: "Delete my account" — opens confirmation modal with clear consequences explained
- Section: "About this app" — version, privacy policy link, contact link
- Sign out button — ghost button, bottom of page
- Absolutely no profile photo, no display name customization, no social features

### 15. ADMIN PANEL (Structural reference only — separate authenticated route `/admin`)
- Distinct visual theme: same type system, but sidebar layout with lighter nav background (`#F0F4F2`)
- Sidebar nav items: Dashboard, Content, Psychologists, Booking Requests, Users (view-only count)
- Content management: data table — title, type, topic tags, risk level, status (published/draft), actions (edit, unpublish)
- Add content form: title, type dropdown, upload field, topic tag multiselect, min/max risk level selector, publish toggle
- Psychologist management: profile cards with edit and toggle availability
- Booking requests table: student ID (anonymized), psychologist, requested slot, status (pending/confirmed/completed), confirm/reject action buttons

---

## NAVIGATION STRUCTURE

**Desktop layout**
- Top navbar (64px): logo left, 5 primary nav items center (Home, Check-in, Content, Mood, Psychologists), "Need help now?" violet FAB chip right + username avatar
- On authenticated interior pages: optional left sidebar (240px, collapsible) with the same 5 items as icon + label — sidebar collapses to icon-only on smaller desktops

**Mobile layout**
- Top bar: hamburger left, logo center, crisis icon right (violet heart — always visible)
- Bottom tab bar (5 tabs): Home, Check-in, Content, Mood, Psychologists — icon + small label — active tab: teal icon + teal underline indicator

**Navigation hierarchy**
- Level 1 (always accessible): Crisis Kit, Home/Dashboard
- Level 2 (primary flows): Check-in, Content, Mood, Psychologists
- Level 3 (secondary flows): Content detail, Psychologist detail, Booking flow, Screening questions
- Level 4 (settings / account): Profile, Settings — accessible from avatar menu only

**Flow: Entry → Support (critical path)**
Landing → Register → Onboarding (3 screens) → Dashboard → Check-in → Results → [Low: Content] [Medium: Content + Psychologist CTA] [High: Crisis Kit + Urgent Booking CTA]

---

## STATES SPECIFICATION

**Empty states**
- Dashboard first visit: warm onboarding hero card replaces dashboard content
- Content library no results: abstract open-book illustration + encouraging message + "Show all" CTA
- Mood tracker no history: "Your mood history starts today" — no empty chart — just the daily log widget

**Loading states**
- All loading: subtle breathing pulse animation on a muted teal soft rectangle (skeleton loader) — no spinners
- Screening question transition: 200ms fade between questions — no hard cut
- Booking confirmation: animated soft checkmark drawing itself on submit

**Error states**
- Network error: inline banner below navbar — soft amber background, icon, "We couldn't connect. Check your connection and try again." — retry button — not a modal, never blocks the whole screen
- Form validation: inline below each field — small muted red text, no red borders (avoid color-alone error indication) — also accompanied by a small warning icon
- Session expired: full-screen gentle notice — "Your session ended for your privacy. Sign in again." — primary CTA to sign in — preserves last screen context if possible

**High-risk state (system-wide)**
- When a student has a high-risk result on record: the "Need help now?" FAB changes to display a subtle pulse animation (CSS animation, not distracting) on the violet background — to gently increase salience without alarming
- Dashboard shows a persistent (but dismissable) soft card above the fold: "We noticed your last check-in flagged some concerns. Your safety plan and psychologist booking are ready whenever you are." — with two ghost CTAs
- This state resets once the student books a session OR manually dismisses the card

---

## RESPONSIVE BREAKPOINTS
- Desktop: 1280px+ (12-column grid, sidebar navigation, 2–3 column content grids)
- Tablet: 768px–1279px (8-column grid, top navigation only, 2-column content grids)
- Mobile: below 768px (4-column grid, bottom tab bar, single column content, full-screen modals)

---

## ACCESSIBILITY REQUIREMENTS
- All color combinations pass WCAG AA minimum (4.5:1 for body, 3:1 for large text)
- All interactive elements have visible focus states (3px teal outline)
- No information conveyed by color alone — always accompanied by icon or text
- All form inputs have visible labels above (no placeholder-only)
- Touch targets minimum 44x44px on all interactive elements
- Screening question radio cards are keyboard-navigable
- Crisis Kit page is accessible without JavaScript