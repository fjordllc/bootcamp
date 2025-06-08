/**
 * ISO8601日付を「YYYY年MM月DD日(曜日) HH:mm」形式に変換
 * タイムゾーンを考慮してUTCとして解釈し、日本時間での表示を行う
 * @param {string} date - ISO8601形式の日付文字列
 * @returns {string} フォーマットされた日付文字列
 */
export function formatDateToJapanese(date) {
  const dateObj = new Date(date + (date.includes('T') ? '' : 'T00:00:00'))
  const year = dateObj.getFullYear()
  const month = String(dateObj.getMonth() + 1).padStart(2, '0')
  const day = String(dateObj.getDate()).padStart(2, '0')
  const weekday = dateObj.toLocaleDateString('ja-JP', { weekday: 'short' })
  const hours = String(dateObj.getHours()).padStart(2, '0')
  const minutes = String(dateObj.getMinutes()).padStart(2, '0')

  return `${year}年${month}月${day}日(${weekday}) ${hours}:${minutes}`
}
