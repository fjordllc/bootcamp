<template lang="pug">
a(:href='user.url', :class='`${threadClass}author-link`')
  img(
    :src='user.avatar_url',
    :alt='user.icon_title',
    :title='user.icon_title',
    :class='[`${threadClass}author-icon`, "a-user-icon", roleClass, daimyoClass]'
  )
</template>

<script>
export default {
  props: {
    user: { type: Object, required: true },
    threadClassSuffix: { type: String, required: true }
  },
  computed: {
    threadClass: function () {
      return `thread${this.threadClassSuffix}__`
    },
    roleClass: function () {
      return `is-${this.user.role}`
    },
    daimyoClass: function () {
      return { 'is-daimyo': this.user.daimyo }
    }
  }
}
</script>
