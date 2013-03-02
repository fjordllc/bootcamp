$ ->
  time = $('nav#time')
  setInterval =>
    date = new Date
    time[0].innerHTML =
      "<div class=\"date\">#{date.getFullYear()}/#{date.getMonth()}/#{date.getDate()}</div>
      <div class=\"time\">#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}</div>"
  , 100
