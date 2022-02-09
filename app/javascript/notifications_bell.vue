<template lang="pug">
li.header-links__item(v-bind:class='hasCountClass')
  label.header-links__link.test-show-notifications(
    for='header-notification-pc',
    @click='clickBell'
  )
    .header-links__link.test-bell
      .header-notification-icon
        .header-notification-count.a-notification-count.test-notification-count(
          v-show='notificationExist'
        ) {{ this.notificationCount }}
        i.fas.fa-bell
        .header-links__link-label 通知
  input#header-notification-pc.a-toggle-checkbox(
    v-if='notificationExist',
    type='checkbox'
  )
  .header-dropdown
    label.header-dropdown__background(for='header-notification-pc')
    .header-dropdown__inner.is-notification
      ul.header-dropdown__items
        li.header-dropdown__item(v-for='notification in notifications')
          a.header-dropdown__item-link.unconfirmed_link(
            :href='notification.path'
          )
            .header-notifications-item__body
              img.header-notifications-item__user-icon.a-user-icon(
                :src='notification.sender.avatar_url'
              )
              .header-notifications-item__message
                p.test-notification-message {{ notification.message }}
              time.header-notifications-item__created-at {{ createdAtFromNow(notification.created_at) }}
      footer.header-dropdown__footer
        a.header-dropdown__footer-link(href='/notifications?status=unread') 全ての未読通知
        a.header-dropdown__footer-link(href='/notifications') 全ての通知
        a.header-dropdown__footer-link(
          href='/notifications/allmarks',
          ref='nofollow',
          data-method='post'
        ) 全て既読にする
        button.header-dropdown__footer-link(@click='openUnconfirmedItems()') 全て別タブで開く
</template>
<script>
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(relativeTime)

export default {
  data() {
    return {
      notifications: []
    }
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
  },
  created() {
    fetch(`/api/notifications.json?status=unread`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.notifications.forEach((n) => {
          this.notifications.push(n)
        })
      })
      .catch((error) => {
        console.warn(error)
      })
  },
  methods: {
    clickBell() {
      if (!this.notificationExist) {
        location.href = '/notifications'
      }
    },
    createdAtFromNow(createdAt) {
      return dayjs(createdAt).fromNow()
    },
    openUnconfirmedItems() {
      const links = document.querySelectorAll(
        '.header-dropdown__item-link.unconfirmed_link'
      )
      links.forEach((link) => {
        window.open(link.href, '_target', 'noopener')
      })
    }
  }
}
</script>
