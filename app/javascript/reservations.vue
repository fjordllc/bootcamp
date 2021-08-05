<template lang="pug">
.reservations__outer
  .reservations
    .reservations__calender
      .reservations__calender-header
        .reservations__calender-header-label.is-day
          |
        .reservations__calender-header-label.is-seat(
          v-for='seat in seats',
          :key='seat.id',
          @click='createReservationForOneMonth(seat.id)'
        )
          | {{ seat.name }}
        .reservations__calender-header-label.is-memo
          | メモ
      .reservations__day-items
        .reservations__day-item.date(
          v-for='oneDay in thisMonths',
          v-bind:class='isHoliday(reservationsHolidayJps[oneDay["ymd"]])'
        )
          .reservations__day-item-value.reservations__day.is-day(
            @click='createReservationForOneDay(oneDay["ymd"])'
          ) {{ oneDay["d_jp"] }}
          .reservations__day-item-value.reservations__seat.is-seat(
            v-for='seat in seats',
            :key='seat.id',
            v-bind:id='reservationHashId(oneDay["ymd"], seat.id)'
          )
            #reserve-seat.reservations__seat-action(
              v-if='reservations[`${oneDay["ymd"]}-${seat.id}`] === undefined',
              @click='createReservation(oneDay["ymd"], seat.id)'
            )
              |
            reservation(
              v-else,
              :currentUserId='currentUserId',
              :parentReservation='reservations[`${oneDay["ymd"]}-${seat.id}`]',
              @delete='deleteReservation'
            )
          .reservations__day-item-value.is-memo(
            v-if='adminLogin == 1',
            v-bind:id='memoId(oneDay["ymd"])'
          )
            memo(:memo='memos[oneDay["ymd"]]', :date='oneDay["ymd"]')
          .reservations__day-item-value.is-memo(
            v-else,
            v-bind:id='memoId(oneDay["ymd"])'
          )
            template(v-if='memos[oneDay["ymd"]] === undefined')
              |
            template(v-else)
              | {{ memoBody(oneDay) }}
</template>
<script>
import Reservation from './reservation.vue'
import Memo from './memo.vue'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  components: {
    reservation: Reservation,
    memo: Memo
  },
  props: {
    reservationsBegginingOfThisMonth: { type: String, required: true },
    reservationsEndOfThisMonth: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      thisMonths: [],
      reservation: [],
      reservations: {},
      seats: {},
      reservationsHolidayJps: {},
      memos: {},
      adminLogin: ''
    }
  },
  created: function () {
    this.reservationsHolidayJps = JSON.parse(
      document.querySelector('#js-reservations-data-holiday-jps').innerText
    )
    this.memos = JSON.parse(document.querySelector('#js-memos-data').innerText)
    this.seats = JSON.parse(document.querySelector('#js-seats-data').innerText)

    if (!(document.querySelector('#js-admin-login') == null)) {
      this.adminLogin = document.querySelector('#js-admin-login').innerText
    }

    fetch(
      `/api/reservations.json?beggining_of_this_month=${this.reservationsBegginingOfThisMonth}&end_of_this_month=${this.reservationsEndOfThisMonth}`,
      {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }
    )
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((c) => {
          this.$set(this.reservations, `${c.date}-${c.seat_id}`, c)
        })
      })
      .catch((error) => {
        console.warn('Failed to parsing', error)
      })

    this.thisMonths = this.getDates(
      new Date(this.reservationsBegginingOfThisMonth),
      new Date(this.reservationsEndOfThisMonth)
    )
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getDates: function (startDate, stopDate) {
      const dateArray = []
      let currentDate = startDate
      while (currentDate <= stopDate) {
        const oneDay = {}
        oneDay.ymd = dayjs(new Date(currentDate)).format('YYYY-MM-DD')
        oneDay.d_jp = dayjs(new Date(currentDate)).format('D日(ddd)')
        dateArray.push(oneDay)
        currentDate = dayjs(currentDate).add(1, 'd')
      }
      return dateArray
    },
    createReservation: function (date, seatId) {
      const params = {
        seat_id: seatId,
        date: date
      }
      fetch(`/api/reservations`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (Array.isArray(json)) {
            json.forEach((c) => {
              this.$set(this.reservations, `${c.date}-${c.seat_id}`, c)
            })
          } else {
            if (json.message === undefined) {
              this.$set(this.reservations, `${json.date}-${json.seat_id}`, json)
            } else {
              alert(json.message)
            }
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    deleteReservation: function (id) {
      fetch(`/api/reservations/${id}.json`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          for (const reservation in this.reservations) {
            if (this.reservations[reservation].id === id) {
              this.$delete(this.reservations, reservation)
            }
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    isHoliday(isHoliday) {
      return {
        'is-holiday': isHoliday === 1
      }
    },
    reservationHashId(date, seatId) {
      return `reservation-${date}-${seatId}`
    },
    memoBody(oneDay) {
      return this.memos[oneDay.ymd].body
    },
    memoId(oneDay) {
      return `memo-${oneDay}`
    },
    createReservationForOneMonth(seatId) {
      const multipleDays = []
      if (this.adminLogin === 1) {
        this.thisMonths.forEach((oneDay) => {
          multipleDays.push(oneDay.ymd)
        })
        this.createReservation(multipleDays, seatId)
      }
    },
    createReservationForOneDay(oneDay) {
      const seatIds = []
      if (this.adminLogin === 1) {
        this.seats.forEach((seat) => {
          seatIds.push(seat.id)
        })
        this.createReservation(oneDay, seatIds)
      }
    }
  }
}
</script>
