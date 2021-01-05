<template lang="pug">
  div
    notification(v-for="(notification, index) in notifications"
      :key="notification.id"
      :notification="notification")
</template>

<script>
import Notification from './notification.vue'

export default {
  components: {
    'notification': Notification
  },
  data: () => {
    return {
      notifications: []
    }
  },
  created() {
    fetch('/api/notifications.json', {
      method: 'GET',
      headers: { 'X-Requested-With': 'XMLHttpRequest', },
      credentials: 'same-origin',
      redirect: 'manual'
    })
        .then(response => {
          return response.json()
        })
        .then(json => {
          json['notifications'].forEach(n => { this.notifications.push(n) })
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
  }
}
</script>
