<template lang="pug">
a(:href='user.url', :class='`${blockClass}user-link`')
  img(
    :src='user.avatar_url',
    :alt='user.icon_title',
    :title='user.icon_title',
    :class='[`${blockClass}user-icon`, "a-user-icon", roleClass, daimyoClass]'
  )
</template>

<script>
export default {
  props: {
    user: { type: Object, required: true },
    blockClassSuffix: { type: String, required: true }
  },
  computed: {
    blockClass: function () {
      return `${this.blockClassSuffix}__`
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
