export function toggleDeleteButtonVisibility(
  editToggle,
  deleteButtons
) {
  const displayStyle = editToggle.checked ? 'block' : 'none'
  for (const button of deleteButtons) {
    button.style.display = displayStyle
  }
}
