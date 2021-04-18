<template lang="pug">
.reservation
  template(v-if='this.currentUserId == this.userId')
    #cancel-reservation.reservations__seat-action.is-reserved.is-me(
      @click='deleteReservation'
    )
      | {{ this.label }}
  template(v-else)
    #cancel-reservation.reservations__seat-action.is-reserved.is-not-me(
      @click='linkToUser'
    )
      | {{ this.label }}
</template>
<script>
export default {
  props: ['parentReservation', 'currentUserId'],
  computed: {
    id: function () {
      return this.parentReservation !== null ? this.parentReservation.id : null
    },
    userId: function () {
      return this.parentReservation !== null
        ? this.parentReservation.user_id
        : null
    },
    label: function () {
      if (this.parentReservation === null) {
        return null
      }

      return this.parentReservation.admin
        ? 'X'
        : this.parentReservation.login_name
    }
  },
  methods: {
    deleteReservation: function () {
      if (confirm('予約を削除しますか？')) {
        this.$emit('delete', this.id)
      }
    },
    linkToUser: function () {
      location.href = `/users/${this.parentReservation.user_id}`
    }
  }
}
</script>
