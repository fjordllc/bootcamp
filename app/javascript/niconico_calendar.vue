<template lang="pug">
  .a-card(v-else)
    header.card-header.is-sm
      h2.card-header__title
        | ニコニコカレンダー
    .card-body(v-if='!loaded')
      | ロード中
    .card-body(v-else)
      .calendar__head
        .calendar__head--previous(
          v-show='!oldestMonth()'
          @click='previousMonth'
        ) <
        .calendar__head--year--month {{ calendarYear }}年{{ calendarMonth }}月
        .calendar__head--next(
          v-show='!newestMonth()'
          @click='nextMonth'
          ) >
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
          v-for='weekObj in calendarWeeksAry',
          :key='weekObj.weekIndex'
          )
          tr.niconico-calendar__week
            td.niconico-calendar__day(
              v-for='date in weekObj.week'
              :key='date.weekDay'
              :class="emotionClass(date)"
            )
              a.niconico-calendar__day-inner(
                v-if='date.id'
                :href='`/reports/${date.id}`'
              )
                .niconico-calendar__day-label {{ date.date }}
                .niconico-calendar__day-value
                  img.niconico-calendar__emotion-image(
                    :src='`/images/emotion/${date.emotion}.svg`'
                    :alt='date.emotion'
                  )
              .niconico-calendar__day-inner(v-else)
                .niconico-calendar__day-label {{ date.date }}
                .niconico-calendar__day-value
                  i.fas.fa-minus(v-if='date.date')
</template>

<script>
export default {
  props: {
    userId: {type: String, required: true}
  },
  data() {
    return {
      reports: [],
      currentYear: this.getCurrentYear(),
      currentMonth: this.getCurrentMonth(),
      calendarYear: this.getCurrentYear(),
      calendarMonth: this.getCurrentMonth(),
      loaded: null,
    }
  },
  computed: {
    calendarReports() {
      return this.reports.filter(report =>
          report.reported_on.includes(`${this.calendarYear}-${this.formatMonth(this.calendarMonth)}`)
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
        let result = null
        if ((result = this.calendarReports.find(report =>
            Number(report.reported_on.split('-')[2]) === date))) {
          result.date = date
          calendar.push(result)
        } else {
          calendar.push({date: date})
        }
      }
      return calendar
    },
    calendarWeeksAry() {
      const weeksAry = []
      let week = []
      let weekIndex = 1
      let weekDay = 0
      this.calendarDates.forEach(function (date, i, ary) {
        !date ? date = {weekDay: weekDay} : date.weekDay = weekDay
        week.push(date)
        weekDay++
        if (week.length === 7 || i === ary.length - 1) {
          const weekObj = {weekIndex: weekIndex, week: week}
          weeksAry.push(weekObj)
          weekIndex++
          week = []
          weekDay = 0
        }
      })
      return weeksAry
    },
  },
  mounted() {
    fetch(
        `/api/niconico_calendars/${this.userId}.json`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
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
          console.warn('Failed to parsing', error)
        })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    formatMonth(month) {
      return month.toString().padStart(2, '0')
    },
    previousMonth() {
      if (this.calendarMonth === 1) {
        this.calendarMonth = 12
        this.calendarYear--
      } else {
        this.calendarMonth--
      }
    },
    nextMonth() {
      if (this.calendarMonth === 12) {
        this.calendarMonth = 1
        this.calendarYear++
      } else {
        this.calendarMonth++
      }
    },
    emotionClass(date) {
      return date.emotion ? `is-${date.emotion}` : 'is-blank'
    },
    oldestMonth() {
      const firstReportDate = this.reports[0].reported_on
      const firstReportYear = Number(firstReportDate.split('-')[0])
      const firstReportMonth = Number(firstReportDate.split('-')[1])
      return firstReportYear === this.calendarYear && firstReportMonth === this.calendarMonth
    },
    newestMonth() {
      return this.currentYear === this.calendarYear && this.currentMonth === this.calendarMonth
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    getCurrentMonth() {
      return new Date().getMonth() + 1
    }
  }
}
</script>

<style scoped>

</style>
