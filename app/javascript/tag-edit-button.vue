<template lang="pug">
div
  button.a-button.is-md.is-primary.is-block(@click.prevent='openModal') このタグを編集する
  modal(
    @closeModal='closeModal',
    @updateTag='updateTag',
    v-if='showModal',
    :id='tagId',
    :nameProp='tagName'
  )
</template>

<script>
import Modal from './tag-edit-modal.vue'
import toast from './toast'

export default {
  components: {
    modal: Modal
  },
  mixins: [toast],
  props: {
    tagId: { type: String, required: true },
    tagNameProp: { type: String, required: true }
  },
  data() {
    return {
      tagName: '',
      showModal: false
    }
  },
  mounted() {
    this.tagName = this.tagNameProp
  },
  methods: {
    openModal() {
      this.showModal = true
    },
    closeModal() {
      this.showModal = false
    },
    updateTag(name) {
      this.tagName = name
      this.toast('タグを更新しました')
    }
  }
}
</script>
