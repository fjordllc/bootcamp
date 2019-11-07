<template lang="pug">
  .reservations
    | reservations
    br
    | {{ reservations }}
    br
    | seats
    br
    | {{ seats }}
    br
    | this_months
    br
    | {{ this_months }}
    br
    table
      tr.dates(v-for="one_day in this_months")
        td {{ one_day }}
        td.seats(v-for="seat in seats" :key="seat.id")
          button(v-if="reservations[`${one_day}-${seat.id}`] === undefined" @click="createReservation(one_day, seat.id)").a-button.is-md.is-secondary.is-block
            i.fas.fa-pen
            | 予約する
          reservation(v-else :parentSeatId="seat.id", :parentDate="one_day", :parentReservation="reservations[`${one_day}-${seat.id}`]", @delete="deleteReservation")
</template>
<script>

import Reservation from './reservation.vue'
import moment from 'moment'

moment.locale('ja');

export default {
  props: [
    'reservationsBegginingOfThisMonth',
    'reservationsEndOfThisMonth'
  ],
  components: {
    'reservation': Reservation
  },
  data: () => {
    return {
      this_months: [],
      reservation: [],
      reservations: {},
      seats: [],
      name: "",
    }
  },
  created: function() {
    // http://localhost:3000/api/reservations.json?begginingOfThisMonth=%222019-10-1%22&endOfThisMonth=%222019-10-31%22
    fetch(`/api/reservations.json?begginingOfThisMonth=${this.reservationsBegginingOfThisMonth}&endOfThisMonth=${this.reservationsEndOfThisMonth}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(response => {
        return response.json()
      })
      .then(json => {
        json.forEach(c => {
          this.$set(this.reservations, `${c.date}-${c.seat_id}`, c);
        });
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })

    fetch(`/api/seats.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(response => {
        return response.json()
      })
      .then(json => {
        json.forEach(c => { 
          this.seats.push(c)
        });
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
    this.this_months = this.getDates(
      new Date(this.reservationsBegginingOfThisMonth),
      new Date(this.reservationsEndOfThisMonth)
    );
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getDates: function(startDate, stopDate) {
      console.log("e")
      var dateArray = new Array();
      var currentDate = startDate;
      while (currentDate <= stopDate) {
          dateArray.push( moment(new Date (currentDate)).format("YYYY-MM-DD") )
          currentDate = moment(currentDate).add(1, 'd');
      }
      return dateArray;
    },
    createReservation: function(date, seat_id) {
      let params = {
        'seat_id': seat_id,
        'date': date,
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
        .then(response => {
          return response.json()
        })
        .then(json => {
          json.forEach(c => {
            this.$set(this.reservations, `${c.date}-${c.seat_id}`, c);
          });
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    deleteReservation: function(id) {
      fetch(`/api/reservations/${id}.json`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(response => {
          for (var reservation in this.reservations) {
            if (this.reservations[reservation].id == id) {
              this.$delete(this.reservations, reservation);
            }
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
  },
  computed: {}
}
</script>
