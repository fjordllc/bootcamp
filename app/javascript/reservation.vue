<template lang="pug">
  .reservation
    template(v-if="this.currentUserId == this.userId")
      #cancel-reservation.reservations__seat-action.is-reserved.is-me(@click="deleteReservation")
        | {{ this.label }}
    template(v-else)
      #cancel-reservation.reservations__seat-action.is-reserved.is-not-me
        | {{ this.label }}
</template>
<script>
export default {
  props: ['parentReservation', 'currentUserId'],
  methods: {
    deleteReservation: function() {
      if (confirm('予約を削除しますか？')) {
        this.$emit('delete', this.id);
      }
    }
  },
  computed: {
    id: function() {
      if (typeof this.parentReservation !== null) {
        return this.parentReservation.id
      }
    },
    userId: function() {
      if (typeof this.parentReservation !== null) {
        return this.parentReservation.user_id
      }
    },
    label: function() {
      if (typeof this.parentReservation !== null) {
        return this.parentReservation.admin ? 'X' : this.parentReservation.login_name
      }
    }
  }
}
</script>
