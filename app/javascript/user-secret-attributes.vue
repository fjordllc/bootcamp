<template lang="pug">
.user-secret-attributes(v-if='currentUser.mentor && user.student_or_trainee')
  .user-secret-attributes__title
    | メンターだけが見れる情報
  .user-secret-attributes__items(v-if='user.student')
    .user-secret-attributes__item
      | {{ jobSeeker }}
    .user-secret-attributes__item(v-if='user.card')
      | 有料ユーザー
    .user-secret-attributes__item(v-if='user.free')
      | 無料ユーザー
    .user-secret-attributes__item(v-if='user.job')
      | {{ user.job_name }}
    .user-secret-attributes__item(v-if='user.os')
      | {{ user.os_name }}
    .user-secret-attributes__item(v-if='user.experience')
      | {{ user.experience_name }}
    .user-secret-attributes__item(v-if='user.email')
      | {{ user.email }}
  .user-secret-attributes__items
    .user-secret-attributes__item
      .user-secret-attributes__item-label
        | 最終ログイン日時
      .user-secret-attributes__item-value(:class="{ 'is-important': isInactive }")
        | {{ user.updated_at }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      isInactive: !this.user.active
    }
  },
  computed: {
    jobSeeker() {
      return this.user.job_seeker ? '就職を希望' : '就職を希望しない'
    }
  }
}
</script>

