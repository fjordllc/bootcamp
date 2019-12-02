<template lang="pug">
  .reservation
    template(v-if="this.currentUserId == this.userId")
      button.a-button.is-md.is-block.is-danger(@click="deleteReservation")
        | {{ this.loginName }}
    template(v-else)
      button.a-button.is-md.is-block.is-warning
        | {{ this.loginName }}
</template>
<script>

export default {
  props: ['parentSeatId', 'parentDate', 'parentReservation', 'currentUserId'],
  data: () => {
    return {
    }
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    deleteReservation: function() {
      if (window.confirm('予約を削除しますか？')) {
        this.$emit('delete', this.id);
      }
    }
  },
  computed: {
    seatId: function() {
      return this.parentSeatId || null
    },
    date: function() {
      return this.parentDate || null
    },
    id: function() {
      if(!(this.parentReservation === undefined)){
        return this.parentReservation.id
      }
    },
    userId: function() {
      if(!(this.parentReservation === undefined)){
        return this.parentReservation.user_id
      }
    },
    loginName: function() {
      if(!(this.parentReservation === undefined)){
        return this.parentReservation.login_name
      }
    }
  }
}
</script>
