import Vue from 'vue'
import Reservations from './reservations.vue'

document.addEventListener('DOMContentLoaded', () => {
  const reservations = document.getElementById('js-reservations')
  if (reservations) {
    const reservationsBegginingOfThisMonth = reservations.getAttribute('data-reservations-beggining-of-this-month')
    const reservationsEndOfThisMonth = reservations.getAttribute('data-reservations-end-of-this-month')
    const currentUserId = reservations.getAttribute('data-current-user-id')

    new Vue({
      render: h => h(Reservations, { props: {
        reservationsBegginingOfThisMonth: reservationsBegginingOfThisMonth,
        reservationsEndOfThisMonth: reservationsEndOfThisMonth,
        currentUserId: currentUserId
      } })
    }).$mount('#js-reservations')
  }
})
