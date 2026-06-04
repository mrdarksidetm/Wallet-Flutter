---
name: Wallet Atelier
colors:
  primary: "#0061A4"
  primaryDim: "#004689"
  tertiary: "#535F7E"
  surface: "#FBF9F9"
  surfaceContainer: "#EFEDEE"
  onSurface: "#313234"
  income: "#10B981"
  expense: "#EF4444"
  primaryDark: "#A9C7FF"
  surfaceDark: "#1A1C1E"
---

# Design System: Wallet Atelier
**Project ID:** Wallet-Flutter-Improv

## 1. Visual Theme & Atmosphere
The Wallet Atelier design system is a high-fidelity implementation of **Material 3 Expressive**, tailored for a premium personal finance experience. It moves away from generic UI standards by employing an "Editorial" philosophy that prioritizes typography, curated color palettes, and a sophisticated surface hierarchy. The atmosphere is intentional and airy, designed to make complex financial data feel approachable and elegant.

The system is built on a **Dynamic Seed** architecture, where the primary Blue (`#0061A4`) serves as the anchor, but the entire interface can shift tonally based on user personalization. It emphasizes **Depth through Surfaces** rather than shadows, using a tiered system of container colors (Container, Low, High, Highest) to create a sense of structural organization and focus. The overall feel is one of "Responsive Precision"—a workspace that is both highly functional and visually rhythmic.

## 2. Color Palette & Roles
### Primary Foundation
- **Primary** (`#0061A4`): The main brand anchor. Used for high-emphasis actions and active states.
- **Primary Dim** (`#004689`): A deeper variant used for gradients and shadow-replacement depth.
- **Surface** (`#FBF9F9`): A warm off-white that forms the base of the app, avoiding the clinical feel of pure white.
- **Surface Container** (`#EFEDEE`): Used for secondary layouts and navigation backgrounds.

### Accent & Interactive
- **Tertiary** (`#535F7E`): A Blue-grey used for secondary accents, providing a cooler counterpoint to the primary blue.
- **On Surface** (`#313234`): The primary text and icon color, curated for high legibility without harsh black contrast.

### Typography & Text Hierarchy
- **Text Muted** (`#94A3B8`): Used for captions, secondary labels, and hint text to maintain clear information hierarchy.

### Functional States
- **Income** (`#10B981`): A vibrant Emerald used exclusively for positive financial growth and success states.
- **Expense** (`#EF4444`): A sharp Rose Red used for spending, negative trends, and errors.

## 3. Typography Rules
### Hierarchy & Weights
The system uses **Google Sans Flex**, a variable font that allows for hyper-fine control over weights and grades without increasing layout shift.
- **Display (L/M/S)**: 57/45/36pt. Used for hero balance numbers and primary screen titles.
- **Headline (L/M/S)**: 32/28/24pt. Used for section headers and large card titles.
- **Title (L/M/S)**: 22/16/14pt. Used for medium-emphasis labels and list item headers.
- **Body (L/M/S)**: 16/14/12pt. The workhorse for all standard data and descriptive text.
- **Label (L/M/S)**: 14/12/11pt. Small, high-density metadata and utility text.

### Spacing Principles
- **Letter Spacing**: Tightening on larger display styles (`-0.25`) for impact; generous on small labels (`0.5`) for legibility.
- **Line Height**: Relaxed for body text to improve readability; tighter for headlines to create a compact, "news" feel.

## 4. Component Stylings
### Buttons
- **Filled**: High-contrast, uses the Primary color with `OnPrimary` text. Geometry follows the global roundness (24dp+).
- **Outlined (Expressive)**: Replaces the standard border with a `SurfaceContainerHighest` background. This creates a "soft button" feel that is easier on the eyes than a hard border.

### Cards & Containers
- **Atelier Cards**: 0 elevation (flat). Separation is achieved via `SurfaceContainerHighest` background against the base `Surface`. 
- **Geometry**: Generous corner radii (24dp to 32dp), creating a friendly, organic aesthetic.
- **Padding**: Large internal gutters (16dp-20dp) to ensure content "breathes."

### Navigation
- **Navigation Bar**: Uses `SurfaceContainer` background with a pill-shaped indicator for active states.
- **App Bar**: Transparent by default, allowing the background colors to flow seamlessly into the status area. Bold, 20pt titles.

### Inputs & Forms
- **Filled Inputs**: Uses `SurfaceContainerHighest` for the background with no borders. This maintains a clean, modern look while clearly defining the interactable area.

## 5. Layout Principles
### Grid & Structure
- **8dp Baseline Grid**: All spacing, sizing, and alignment is rounded to the nearest 8dp unit.
- **Max Width**: Designed for mobile-first with adaptive scaling for tablets and desktops.

### Whitespace Strategy
- **Generous Gutters**: Consistent 16dp horizontal margins for all primary content.
- **Vertical Rhythm**: Large gaps between functional blocks to reduce cognitive load during financial management.

### Alignment & Visual Balance
- **Asymmetric Accents**: Occasional use of off-grid elements or staggered entries (via `flutter_animate`) to break the monotony of standard grids.

## 6. Design System Notes for Stitch Generation
### Language to Use
- When generating screens, use terms like: **"Atelier Editorial," "Airy Layout," "Depth-via-Surfaces," "Sophisticated Blue Palette," "Variable Typography."**
- Avoid terms like: "Flat design," "Shadow-heavy," "Minimalist."

### Color References
- Primary Blue: `#0061A4`
- Warm Surface: `#FBF9F9`
- Emerald Income: `#10B981`
- Rose Expense: `#EF4444`

### Component Prompts
- *"Create an Atelier-style financial card with a SurfaceContainerHighest background and 24dp roundness."*
- *"Design a list item using Google Sans Flex Body Large for the title and Muted Text for the metadata."*

### Incremental Iteration
- Always prioritize **Surface Hierarchy** for separation before considering shadows or borders.
- Ensure all interactive elements (buttons/inputs) share the same high-roundness geometry.
