import flatpickr from "flatpickr";
import { Japanese } from "flatpickr/dist/l10n/ja.js"

document.addEventListener('DOMContentLoaded', () => {
  flatpickr('.datepicker', { 'locale': Japanese });
});
