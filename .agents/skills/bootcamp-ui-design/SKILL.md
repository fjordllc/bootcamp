---
name: bootcamp-ui-design
description: Design, implement, or review user-facing Rails/Slim screens in fjordllc/bootcamp so spacing, layout, forms, cards, actions, responsive behavior, and visual hierarchy match the existing Bootcamp UI. Use for new pages, UI changes, CSS changes, design reviews, screenshot comparisons, or requests to make a page feel consistent with Bootcamp.
---

# Bootcamp UI Design

Use existing Bootcamp structures as the design system. Prefer composition of established classes over new page-specific spacing rules.

## Workflow

1. Identify the page type: detail, list, form, result/status, or empty state.
2. Read [references/patterns.md](references/patterns.md) and inspect the listed source examples for that page type.
3. Search for existing components and classes before editing CSS:
   - `rg "<class-name>" app/views app/assets/stylesheets`
   - `rg -l "<similar-content>" app/views`
4. Implement the smallest structural change that reuses existing primitives.
5. Render realistic fixture data at desktop and mobile widths.
6. Capture screenshots and compare them with the selected reference pages.
7. Iterate until spacing, hierarchy, width, and actions feel consistent.
8. Run focused tests, Slim-Lint, Stylelint when CSS changes, and `git diff --check`.

## Required UI Checks

- Use `.page-main`, `.page-main-header`, `.page-body`, and `.container` consistently with comparable pages.
- Use `.page-body__rows` when direct page sections need the standard vertical gap.
- Put card content inside `.card-body > .card-body__inner`; `.card-body` alone does not provide standard padding.
- Use `.form__items`, `.form-item`, and `.form-actions` for form rhythm and action placement.
- Use existing container widths (`.is-md`, `.is-lg`, `.is-xl`) based on comparable pages.
- Keep primary, cancel, and destructive actions in their established `form-actions__item` roles.
- Verify long Japanese text, empty states, validation errors, and realistic row counts.
- Verify at 1440px desktop and 390px mobile widths. Do not approve from desktop alone.
- Avoid arbitrary margin or padding values when an existing structural class provides the spacing.
- If new CSS is necessary, explain which existing primitive was insufficient and use project variables.

## Visual Review Output

Report:

- reference pages used;
- reused layout and component classes;
- desktop and mobile screenshots captured;
- remaining intentional differences;
- focused tests and linters run.

Do not describe a screen as Bootcamp-like without rendering and inspecting it.
