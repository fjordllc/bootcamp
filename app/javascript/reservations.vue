<template lang="pug">
  .reservations
    table
      tr
        th
          | 
        th.seat(v-for="seat in seats" :key="seat.id")
          | {{ seat.name }}
        th.memo
          | メモ
      tr.date(v-for="one_day in this_months" v-bind:class="is_holiday(reservationsHolidayJps[one_day['ymd']])")
        td {{ one_day['d_jp'] }}
        td(v-for="seat in seats" :key="seat.id" v-bind:id="reservation_hash_id(one_day['ymd'],(seat.id))")
          button(v-if="reservations[`${one_day['ymd']}-${seat.id}`] === undefined" @click="createReservation(one_day['ymd'], seat.id)").a-button.is-md.is-block.is-secondary
            | 
          reservation(v-else :parentSeatId="seat.id", :parentDate="one_day['ymd']", :currentUserId="currentUserId", :parentReservation="reservations[`${one_day['ymd']}-${seat.id}`]", @delete="deleteReservation")
        td.memo
          | {{ memos[one_day['ymd']] }}
</template>
<script>

import Reservation from './reservation.vue'
import moment from 'moment'

moment.locale('ja');

export default {
  props: {
    reservationsBegginingOfThisMonth: String,
    reservationsEndOfThisMonth: String,
    currentUserId: String
  },
  components: {
    'reservation': Reservation
  },
  data: () => {
    return {
      this_months: [],
      reservation: [],
      reservations: {},
      seats: {},
      reservationsHolidayJps: {},
      memos: {},
      name: "",
    }
  },
  created: function() {
    this.reservationsHolidayJps = JSON.parse(document.querySelector('#js-reservations-data-holiday-jps').innerText);
    this.memos = JSON.parse(document.querySelector('#js-memos-data').innerText);
    this.seats = JSON.parse(document.querySelector('#js-seats-data').innerText);

    fetch(`/api/reservations.json?beggining_of_this_month=${this.reservationsBegginingOfThisMonth}&end_of_this_month=${this.reservationsEndOfThisMonth}`, {
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
      var dateArray = new Array();
      var currentDate = startDate;
      while (currentDate <= stopDate) {
          var one_day = {};
          one_day["ymd"] = moment(new Date (currentDate)).format("YYYY-MM-DD");
          one_day["d_jp"] = moment(new Date (currentDate)).format("D日(ddd)");
          dateArray.push( one_day );
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
          return response.json();
        })
        .then(json => {
          if (json["status"] == 400) {
            alert(json["message"]);
          }else{
            this.$set(this.reservations, `${json.date}-${json.seat_id}`, json);
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error);
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
    is_holiday (isholiday) {
      return {
        "is-holiday": isholiday == 1
      }
    },
    reservation_hash_id (date, seatId) {
      return `reservation-${date}-${seatId}`;
    },
  }
}
</script>
