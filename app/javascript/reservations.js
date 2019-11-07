import Vue from 'vue'
import Reservations from './reservations.vue'

document.addEventListener('DOMContentLoaded', () => {
  const reservations = document.getElementById('js-reservations')
  if (reservations) {
    const reservationsBegginingOfThisMonth = reservations.getAttribute('data-reservations-beggining-of-this-month')
    const reservationsEndOfThisMonth = reservations.getAttribute('data-reservations-end-of-this-month')

    console.log(reservationsBegginingOfThisMonth)
    console.log(reservationsEndOfThisMonth)

    new Vue({
      render: h => h(Reservations, { props: {
        reservationsBegginingOfThisMonth: reservationsBegginingOfThisMonth,
        reservationsEndOfThisMonth: reservationsEndOfThisMonth
      } })
    }).$mount('#js-reservations')
  }
})
