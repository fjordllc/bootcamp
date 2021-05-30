<template lang="pug">
tags(
  :tagsInitialValue='tagsInitialValue',
  :tagsParamName='tagsParamName',
  :tagsPath='path',
  :tagsType='type',
  :tagsEditable='editable',
  :tagsEditing='editing',
  :tagsInputId='tagsInputId',
  :tagsTypeId='userId',
  :lowerTagsType='lowerType'
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
    userId: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  computed: {
    editing() {
      return false
    },
    editable() {
      return this.currentUserId === this.userId
    },
    path() {
      return '/users/tags'
    },
    type() {
      return 'User'
    },
    lowerType() {
      return 'user'
    }
  }
}
</script>
