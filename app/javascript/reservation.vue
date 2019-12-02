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
      if(typeof this.parentReservation !== null){
        return this.parentReservation.id
      }
    },
    userId: function() {
      if(typeof this.parentReservation !== null){
        return this.parentReservation.user_id
      }
    },
    loginName: function() {
      if(typeof this.parentReservation !== null){
        return this.parentReservation.login_name
      }
    }
  }
}
</script>
