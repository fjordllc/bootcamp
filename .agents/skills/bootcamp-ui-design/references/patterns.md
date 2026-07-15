# Bootcamp UI Patterns

Inspect source files instead of copying this document as markup. These are maintained examples in the repository.

## Page Structure

- Standard page body and responsive section spacing:
  - `app/assets/stylesheets/application/blocks/page/_page-body.css`
  - `.page-body`, `.page-body__rows`, `.page-body__columns`
- Page headers and actions:
  - `app/views/mentor/practices/practice_quiz/edit.html.slim`
  - `app/views/mentor/practices/practice_quiz/questions/edit.html.slim`

## Forms

- Standard mentor form rhythm and actions:
  - `app/views/mentor/categories/_form.html.slim`
  - `app/views/mentor/coding_tests/_form.html.slim`
  - `app/assets/stylesheets/shared/blocks/form/_form.css`
  - `app/assets/stylesheets/shared/blocks/form/_form-item.css`
  - `app/assets/stylesheets/shared/blocks/form/_form-actions.css`
- Use `.form__items` for a group, `.form-item` between fields, and `.form-actions` after fields.
- Do not add margins to individual labels or buttons until the form primitives have been used correctly.

## Cards

- Card structure:

```slim
.a-card
  header.card-header
    h2.card-header__title Title
  hr.a-border-tint
  .card-body
    .card-body__inner
      / content
```

- Relevant styles:
  - `app/assets/stylesheets/shared/blocks/card/_card-header.css`
  - `app/assets/stylesheets/shared/blocks/card/_card-body.css`
- `.card-body__inner` owns the standard responsive padding. Omitting it makes content touch card edges.

## Tables and Empty States

- Admin tables are standalone because `.admin-table` owns its borders, background, and corner treatment. Do not wrap an admin table in `.a-card`.
- Use a preceding `header.page-body-header` when the table needs a local title or count.
- Reference implementations:
  - `app/views/mentor/categories/index.html.slim`
  - `app/views/mentor/coding_tests/index.html.slim`
  - `app/views/mentor/practices/practice_quiz/edit.html.slim`
- Empty state:
  - `.o-empty-message` in the same file.

## Result and Status Screens

- Status plus repeated result cards:
  - `app/views/practices/practice_quiz/show.html.slim`
  - `app/assets/stylesheets/application/blocks/practice-quiz/_practice-quiz.css`
- Keep status messaging visually separate from question/result cards.

## Screenshot Review

Use realistic development fixtures. At minimum capture:

- desktop: 1440 x 1000;
- mobile: 390 x 844;
- form before submission;
- result or state after submission when applicable;
- management/edit screen for mentor-facing features.

Compare section padding, gaps between sibling sections, content width, heading hierarchy, button placement, table density, and mobile stacking.
