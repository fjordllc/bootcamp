<template lang="pug">
.a-card
  header.card-header.is-sm
    h2.card-header__title
      | ニコニコカレンダー
  hr.a-border-tint
  .card-body(v-if='!loaded')
    .card__description
      | ロード中
  .card-body(v-else-if='reports.length === 0')
    .card__description
      | 日報はありません。
  .card-body(v-else)
    .card__description
      .niconico-calendar-nav
        .niconico-calendar-nav__previous(
          v-if='!oldestMonth()',
          @click='previousMonth')
          i.fa-solid.fa-angle-left
        .niconico-calendar-nav__previous.is-blank(v-else)
        .niconico-calendar-nav__year--month {{ calendarYear }}年{{ calendarMonth }}月
        .niconico-calendar-nav__next(v-if='!newestMonth()', @click='nextMonth')
          i.fa-solid.fa-angle-right
        .niconico-calendar-nav__next.is-blank(v-else)
      table.niconico-calendar
        thead.niconico-calendar__header
          tr
            th.niconico-calendar__header-day.is-sunday
              | 日
            th.niconico-calendar__header-day
              | 月
            th.niconico-calendar__header-day
              | 火
            th.niconico-calendar__header-day
              | 水
            th.niconico-calendar__header-day
              | 木
            th.niconico-calendar__header-day
              | 金
            th.niconico-calendar__header-day.is-saturday
              | 土
        tbody.niconico-calendar__body(
          v-for='week in calendarWeeks',
          :key='week.id')
          tr.niconico-calendar__week
            td.niconico-calendar__day(
              v-for='date in week.value',
              :key='date.weekDay',
              :class='[emotionClass(date), todayClass(date)]')
              a.niconico-calendar__day-inner(
                v-if='date.id',
                :href='`/reports/${date.id}`')
                .niconico-calendar__day-label {{ date.date }}
                .niconico-calendar__day-value
                  img.niconico-calendar__emotion-image(
                    :src='`/images/emotion/${date.emotion}.svg`',
                    :alt='date.emotion')
              a.niconico-calendar__day-inner(
                v-else-if='date.date && isPastDate(date.date)',
                :href='`/reports/new?reported_on=${calendarYear}-${calendarMonth}-${date.date}`')
                .niconico-calendar__day-label {{ date.date }}
                .niconico-calendar__day-value
                  i.fas.fa-minus(v-if='date.date')
              .niconico-calendar__day-inner(v-else)
                .niconico-calendar__day-label {{ date.date }}
                .niconico-calendar__day-value
                  i.fa-solid.fa-minus(v-if='date.date')
</template>

<script>
import CSRF from 'csrf'

export default {
  props: {
    userId: { type: String, required: true }
  },
  data() {
    return {
      reports: [],
      currentYear: this.getCurrentYear(),
      currentMonth: this.getCurrentMonth(),
      calendarYear: this.getCurrentYear(),
      calendarMonth: this.getCurrentMonth(),
      today: this.getCurrentDay(),
      loaded: null
    }
  },
  computed: {
    calendarReports() {
      return this.reports.filter((report) =>
        report.reported_on.includes(
          `${this.calendarYear}-${this.formatMonth(this.calendarMonth)}`
        )
      )
    },
    firstWday() {
      const firstDay = new Date(this.calendarYear, this.calendarMonth - 1, 1)
      return firstDay.getDay()
    },
    lastDate() {
      const lastDay = new Date(this.calendarYear, this.calendarMonth, 0)
      return lastDay.getDate()
    },
    calendarDates() {
      const calendar = []
      if (this.firstWday > 0) {
        for (let blank = 0; blank < this.firstWday; blank++) {
          calendar.push(null)
        }
      }
      for (let date = 1; date <= this.lastDate; date++) {
        const result = this.calendarReports.find(
          (report) => this.reportDate(report) === date
        )
        if (result) {
          result.date = date
          calendar.push(result)
        } else {
          calendar.push({ date: date })
        }
      }
      return calendar
    },
    calendarWeeks() {
      const weeksAry = []
      let value = []
      let id = 1
      let weekDay = 0
      this.calendarDates.forEach(function (date, i, ary) {
        !date ? (date = { weekDay: weekDay }) : (date.weekDay = weekDay)
        value.push(date)
        weekDay++
        if (value.length === 7 || i === ary.length - 1) {
          weeksAry.push({ id: id, value: value })
          id++
          value = []
          weekDay = 0
        }
      })
      return weeksAry
    }
  },
  mounted() {
    this.loadState()
    fetch(`/api/niconico_calendars/${this.userId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((r) => {
          this.reports.push(r)
        })
        this.loaded = true
      })
      .catch((error) => {
        console.warn(error)
      })
  },
  methods: {
    formatMonth(month) {
      return month.toString().padStart(2, '0')
    },
    previousMonth() {
      this.loaded = false
      if (this.calendarMonth === 1) {
        this.calendarMonth = 12
        this.calendarYear--
      } else {
        this.calendarMonth--
      }
      this.$nextTick(() => (this.loaded = true))
      this.saveState()
    },
    nextMonth() {
      this.loaded = false
      if (this.calendarMonth === 12) {
        this.calendarMonth = 1
        this.calendarYear++
      } else {
        this.calendarMonth++
      }
      this.$nextTick(() => (this.loaded = true))
      this.saveState()
    },
    emotionClass(date) {
      return date.emotion ? `is-${date.emotion}` : 'is-blank'
    },
    todayClass(date) {
      if (
        this.calendarYear !== this.currentYear ||
        this.calendarMonth !== this.currentMonth
      )
        return
      if (date.date === this.today) return 'is-today'
    },
    oldestMonth() {
      const firstReportDate = this.reports[0].reported_on
      const firstReportYear = Number(firstReportDate.split('-')[0])
      const firstReportMonth = Number(firstReportDate.split('-')[1])
      return (
        firstReportYear === this.calendarYear &&
        firstReportMonth === this.calendarMonth
      )
    },
    newestMonth() {
      return (
        this.currentYear === this.calendarYear &&
        this.currentMonth === this.calendarMonth
      )
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    getCurrentMonth() {
      return new Date().getMonth() + 1
    },
    getCurrentDay() {
      return new Date().getDate()
    },
    reportDate(report) {
      return Number(report.reported_on.split('-')[2])
    },
    loadState() {
      const params = new URLSearchParams(location.search)
      const yearMonth = params.get('niconico_calendar') || ''
      const match = /(\d{4})-(\d{2})/.exec(yearMonth)
      if (!match) {
        return
      }

      const year = parseInt(match[1])
      const month = parseInt(match[2])
      if (new Date(year, month).getTime() > Date.now()) {
        return
      }

      this.calendarYear = year
      this.calendarMonth = month
    },
    saveState() {
      const year = String(this.calendarYear)
      const month = String(this.calendarMonth).padStart(2, '0')
      const params = new URLSearchParams(location.search)
      params.set('niconico_calendar', `${year}-${month}`)
      history.replaceState(history.state, '', `?${params}${location.hash}`)
    },
    isPastDate(date) {
      if (this.calendarYear > this.currentYear) return false
      if (this.calendarYear < this.currentYear) return true
      if (this.calendarMonth > this.currentMonth) return false
      if (this.calendarMonth < this.currentMonth) return true
      if (date > this.today) return false
      return true
    }
  }
}
</script>
