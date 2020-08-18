<template lang="pug">
  .header-show-mobile-nav-items
    .header-show-mobile-nav(v-bind:class="hasCountClass")
      label.header-links__link(for="header-notification-mobile")
        .header-notification-icon
          .header-notification-count(v-if="notificationExist") {{ this.notificationCount }}
          i.fas.fa-bell
      input.a-toggle-checkbox(v-if="notificationExist" type="checkbox" id="header-notification-mobile")
      .header-dropdown
        label.header-dropdown__background(for="header-notification-mobile")
        .header-dropdown__inner.is-notification
          ul.header-dropdown__items
            li.header-dropdown__item(v-for="notification in notifications")
              a.header-dropdown__item-link(:href="notification.path")
                .header-notifications-item__body
                  img.header-notifications-item__user-icon.a-user-icon(:src="notification.avatar_url")
                  .header-notifications-item__message
                    p {{ notification.message }}
                  time.header-notifications-item_created-at {{ notification.created_at }}
          footer.header-dropdown__footer
            a.header-dropdown__footer-link(href="/notifications/unread") 全ての未読通知
            a.header-dropdown__footer-link(href="/notifications") 全ての通知
            a.header-dropdown__footer-link(href="/notifications/allmarks" ref="nofollow" data-method="post") 全て既読にする
    label.header-show-mobile-nav(for="mobile-nav")
      i.fas.fa-bars
</template>
<script>
export default {
  data: () => {
    return {
      notifications: []
    }
  },
  created() {
    fetch(`/api/notifications.json`, {
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
        json.forEach(n => { this.notifications.push(n) })
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  },
  computed: {
    notificationCount() {
      const count = this.notifications.length
      return count > 99 ? '99+' : String(count)
    },
    notificationExist() {
      return this.notifications.length > 0
    },
    hasCountClass() {
      return this.notificationExist ? 'has-count' : 'has-no-count'
    }
  }
}
</script>
