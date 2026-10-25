---
name: Structure ERP
colors:
  surface: '#f8f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f6'
  surface-container: '#edeef0'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e2e4'
  on-surface: '#191c1e'
  on-surface-variant: '#434654'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f3'
  outline: '#737685'
  outline-variant: '#c3c6d6'
  surface-tint: '#0c56d0'
  primary: '#003d9b'
  on-primary: '#ffffff'
  primary-container: '#0052cc'
  on-primary-container: '#c4d2ff'
  inverse-primary: '#b2c5ff'
  secondary: '#00687b'
  on-secondary: '#ffffff'
  secondary-container: '#50dcff'
  on-secondary-container: '#005f71'
  tertiary: '#7b2600'
  on-tertiary: '#ffffff'
  tertiary-container: '#a33500'
  on-tertiary-container: '#ffc6b2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001848'
  on-primary-fixed-variant: '#0040a2'
  secondary-fixed: '#afecff'
  secondary-fixed-dim: '#48d7f9'
  on-secondary-fixed: '#001f27'
  on-secondary-fixed-variant: '#004e5d'
  tertiary-fixed: '#ffdbcf'
  tertiary-fixed-dim: '#ffb59b'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#812800'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e1e2e4'
  deep-navy: '#091E42'
  slate-gray: '#42526E'
  success-emerald: '#36B37E'
  warning-amber: '#FFAB00'
  error-ruby: '#FF5630'
  surface-white: '#FFFFFF'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 16px
  gutter-md: 12px
  section-gap: 24px
  element-gap: 8px
---

## Brand & Style

The design system for this Hostel/Flat ERP is built on the pillars of **efficiency, trust, and clarity**. It caters to two distinct users: Residents, who require quick access to daily information (meals, transport, payments), and Owners, who need a high-level overview and streamlined management tools for data-heavy tasks.

The chosen style is **Modern Corporate Minimalism**. It utilizes a "Utility-First" approach, where whitespace is used as a functional tool to separate complex data sets like ledgers and schedules without relying on heavy borders or dividers. The aesthetic is professional and "software-as-a-service" (SaaS) inspired, ensuring the app feels like a reliable tool rather than a social platform. 

Key visual characteristics include:
- **Focused Clarity:** Neutral backgrounds with high-contrast typography for immediate legibility.
- **Intentional Accents:** Vibrant colors are reserved strictly for primary actions and status indicators.
- **Structured Depth:** A flat foundation layered with subtle shadows to define interactive surfaces and high-priority cards.

## Colors

The palette is anchored in **Deep Navy (#091E42)** for primary text and navigation elements to establish authority and trust. The **Primary Color (Electric Blue, #0052CC)** is used sparingly for call-to-action buttons, active states, and critical links.

- **Backgrounds:** Use `neutral_color_hex` for the main app background to reduce eye strain. Use `surface-white` for cards and input areas to create a "layered" effect.
- **Status Indicators:** Use `success-emerald` for "Approved" or "Paid" states, `warning-amber` for "Pending," and `error-ruby` for "Rejected" or "Overdue."
- **Typography:** Primary headers should use `deep-navy`, while secondary body text and labels use `slate-gray` to maintain a clear visual hierarchy.

## Typography

This design system uses **Inter** exclusively to ensure maximum legibility across dense data tables and mobile screens. Inter’s tall x-height makes it ideal for small labels and numeric data in the Payment Ledger and Mess Menu.

- **Numerical Data:** For currency and UTR numbers, use `fontWeight: 600` to ensure they are easily scannable.
- **Hierarchy:** Use `label-sm` with uppercase transformation for section headers (e.g., "TODAY'S MENU" or "PENDING ACTIONS") to provide structure without adding visual bulk.
- **Contrast:** Ensure all body text uses `slate-gray` and headlines use `deep-navy` to guide the user's eye from the title to the content.

## Layout & Spacing

The layout follows a **fluid grid system** designed for mobile-first interaction. It prioritizes "breathability" to prevent data-heavy modules from feeling overwhelming.

- **Grid:** A standard 4-column mobile grid with 16px side margins. 
- **The Ledger Rule:** For lists like the Payment Ledger or Cab Timings, use a 12px gutter between list items and 16px internal padding within cards to ensure touch targets are accessible (minimum 44px height).
- **Whitespace:** Use generous 24px gaps between major sections (e.g., separating "Dues Summary" from "Recent Transactions") to create a natural rhythm.
- **Owner Dashboard:** On larger screens (tablets), the layout should transition to a 2-column card layout to allow owners to see "Pending Payments" and "Open Tickets" side-by-side.

## Elevation & Depth

To maintain a minimalistic feel while ensuring components are interactive, the design system uses **Tonal Layering** and **Soft Shadows**.

- **Level 0 (Base):** `neutral_color_hex`. Used for the main background.
- **Level 1 (Cards/Surfaces):** `surface-white`. Used for all content containers. Use a subtle border (1px, #EBECF0) instead of a shadow to keep the UI "flat."
- **Level 2 (Interactive):** Used for primary buttons and active cards. Apply a soft ambient shadow: `box-shadow: 0px 4px 12px rgba(9, 30, 66, 0.08)`.
- **Level 3 (Modals/Overlays):** Used for payment confirmation sheets and ticket details. Apply a more pronounced shadow: `box-shadow: 0px 8px 24px rgba(9, 30, 66, 0.16)`.

## Shapes

The shape language is **friendly yet professional**. The `roundedness: 2` (8px-12px) setting provides a modern softened corner that feels approachable without the "playfulness" of fully rounded pill shapes.

- **Components:** Buttons and input fields use a consistent 8px radius.
- **Cards:** Larger containers (like the Mess Menu grid) use a 12px radius to clearly define section boundaries.
- **Status Pills:** Badges for "Paid" or "Pending" should use a 16px (fully rounded) radius to distinguish them from interactive buttons.

## Components

### Buttons
- **Primary:** Solid `primary_color_hex` with white text. 8px border radius.
- **Secondary:** Transparent background with `primary_color_hex` border and text.
- **Critical:** Solid `error-ruby` for actions like "Delete Resident" or "Reject Payment."

### Cards
- White background, 1px light gray border, and 12px corner radius. 
- Use a vertical accent bar (4px wide) on the left side of cards to indicate status (e.g., green for paid dues).

### Input Fields
- Background-colored (`neutral_color_hex`) or white with a 1px border. 
- Focus state: Border changes to `primary_color_hex` with a 2px outer glow.
- Helper text: Use `label-md` in `slate-gray`.

### Status Chips
- Small, low-saturation backgrounds with high-saturation text.
- Example: "Pending" = Background: `#FFFAE6`, Text: `warning-amber`.

### Data Tables (Mess Menu / Ledger)
- Avoid vertical lines. Use horizontal zebra-striping (alternating `surface-white` and `neutral_color_hex`) or 1px horizontal dividers only.
- Headers should be sticky and use `label-sm` typography.

### Lists (Tickets / Cabs)
- Each item should be a card with a clear title (`headline-sm`) and a metadata row (`label-md`).
- Use icons sparingly to denote categories (e.g., a wrench for "Plumbing" tickets).
