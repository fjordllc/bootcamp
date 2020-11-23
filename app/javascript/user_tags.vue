<template lang="pug">
  tags(
    :tagsInitialValue="tagsInitialValue"
    :tagsParamName="tagsParamName"
    :tagsPath="path"
    :tagsType="type"
    :tagsEditable="editable"
    :tagsInput="tagsInput"
    :tagsInputId="tagsInputId"
    :updateCallback="update")
</template>

<script>
import Tags from './tags.vue'

export default {
  props: {
    tagsInitialValue: String,
    tagsParamName: String,
    tagsEditable: Boolean,
    tagsInput: Boolean,
    tagsInputId: String,
    userId: String,
    currentUserId: String,
    adminLogin: String
  },
  components: {
    tags: Tags
  },
  data() {
    return {
      path: '/users/tags',
      type: 'User',
      id: ''
    }
  },
  methods: {
    update(tagsValue, token) {
      let params = {
        user: {
          tag_list: tagsValue
        }
      }
      
      return fetch(`/api/users/${this.id}`, {
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
  },
  computed: {
    editable() {
      return this.tagsEditable && (this.userId === this.currentUserId || this.adminLogin === "true")
    }
  }
}
</script>

<style scoped>
  .vue-tags-input .ti-autocomplete {
    z-index: 2;
  }

  .tag-links {
    border-top: none;
    padding: 0
  }
</style>
