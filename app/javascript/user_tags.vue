<template lang="pug">
tags(
  :tagsInitialValue='tagsInitialValue',
  :tagsParamName='tagsParamName',
  :tagsPath='path',
  :tagsType='type',
  :tagsEditable='editable',
  :tagsEditing='editing',
  :tagsInputId='tagsInputId',
  :updateCallback='updateTag'
)
</template>

<script>
import Tags from './tags.vue'

export default {
  components: {
    tags: Tags
  },
  props: {
    tagsInitialValue: { type: String, required: true },
    tagsParamName: { type: String, required: true },
    tagsInputId: { type: String, required: true },
    userId: { type: String, required: true }
  },
  computed: {
    editing() {
      return true
    },
    editable() {
      return false
    },
    path() {
      return '/users/tags'
    },
    type() {
      return 'User'
    }
  },
  methods: {
    updateTag(tagsValue, token) {
      const params = {
        user: {
          tag_list: tagsValue
        }
      }
      return fetch(`/api/users/${this.userId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      }).catch((error) => {
        console.warn('Failed to parsing', error)
      })
    }
  }
}
</script>
