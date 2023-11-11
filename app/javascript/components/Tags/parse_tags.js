export default function parseTags(value) {
  if (value === '') return []

  return value.split(',').map((value) => value)
}
