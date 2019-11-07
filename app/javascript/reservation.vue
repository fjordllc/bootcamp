<template lang="pug">
  .reservation
    | {{ parentReservation }}
    button.a-button.is-md.is-warning.is-block(@click="deleteReservation")
      i.fas.fa-trash-alt
      | {{ this.loginName }}
</template>
<script>

export default {
  props: ['parentSeatId', 'parentDate', 'parentReservation'],
  data: () => {
    return {
    }
  },
  created: function() {},
  mounted: function() {},
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    deleteReservation: function() {
      if (window.confirm('削除してよろしいですか？')) {
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
