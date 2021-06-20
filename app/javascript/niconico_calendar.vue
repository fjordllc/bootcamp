<template lang="pug">
  .a-card
    header.card-header.is-sm
      h2.card-header__title
        | ニコニコカレンダー
    .card-body
      .calendar__head
        .calendar__pager--previous(@click='previousMonth')
          | <
        | {{ calendarMonth }}月
        .calendar__pager--next(@click='nextMonth')
          | >
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
        tbody.niconico-calendar__body
</template>

<script>
export default {
  props: {
    userId: {type: String, required: true}
  },
  data() {
    return {
      reports: [],
      currentYear: new Date().getFullYear(),
      currentMonth: new Date().getMonth() + 1,
      calendarYear: new Date().getFullYear(),
      calendarMonth: new Date().getMonth() + 1,
    }
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
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
  },
  computed: {
    calendarReports() {
      return this.reports.filter(report =>
          report.reported_on.includes(`${this.calendarYear}-${this.formatMonth(this.calendarMonth)}`)
      )
    },
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
        return this.calendarMonth--
      }
    },
    nextMonth() {
      if (this.calendarMonth === 12) {
        this.calendarMonth = 1
        this.calendarYear++
      } else {
        return this.calendarMonth++
      }
    }
  }
}
</script>

<style scoped>

</style>
