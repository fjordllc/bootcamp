const dateTimeFormatter = new Intl.DateTimeFormat('ja-JP', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  weekday: 'short',
  hour: '2-digit',
  minute: '2-digit',
  hour12: false
})

const relativeTimeFormatter = new Intl.RelativeTimeFormat('ja-JP', {
  numeric: 'auto'
})

const pad = (value) => value.toString().padStart(2, '0')

const formatDateTimeParts = (date) => {
  const parts = dateTimeFormatter.formatToParts(date)
  return (type) => parts.find((part) => part.type === type)?.value
}

export const parseDate = (date) => {
  if (date instanceof Date) return date
  return new Date(date + (date.includes('T') ? '' : 'T00:00:00'))
}

export const formatDateTimeLocal = (date = new Date()) => {
  const dateObj = parseDate(date)
  const year = dateObj.getFullYear()
  const month = pad(dateObj.getMonth() + 1)
  const day = pad(dateObj.getDate())
  const hours = pad(dateObj.getHours())
  const minutes = pad(dateObj.getMinutes())
  const seconds = pad(dateObj.getSeconds())

  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}`
}

export const formatDateToJapanese = (date) => {
  const value = formatDateTimeParts(parseDate(date))

  return `${value('year')}年${value('month')}月${value('day')}日(${value(
    'weekday'
  )}) ${value('hour')}:${value('minute')}`
}

export const formatRelativeTime = (date, baseDate = new Date()) => {
  const seconds = Math.round(
    (parseDate(date).getTime() - parseDate(baseDate).getTime()) / 1000
  )
  const absSeconds = Math.abs(seconds)

  if (absSeconds < 60) return relativeTimeFormatter.format(seconds, 'second')

  const minutes = Math.round(seconds / 60)
  if (Math.abs(minutes) < 60)
    return relativeTimeFormatter.format(minutes, 'minute')

  const hours = Math.round(minutes / 60)
  if (Math.abs(hours) < 24) return relativeTimeFormatter.format(hours, 'hour')

  const days = Math.round(hours / 24)
  if (Math.abs(days) < 30) return relativeTimeFormatter.format(days, 'day')

  const months = Math.round(days / 30)
  if (Math.abs(months) < 12)
    return relativeTimeFormatter.format(months, 'month')

  return relativeTimeFormatter.format(Math.round(months / 12), 'year')
}
