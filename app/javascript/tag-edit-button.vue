<template lang="pug">
.page-main-header-actions__item
  .a-button.is-sm.is-secondary.is-block(@click.prevent='openModal')
    i.fas.fa-cog
    | タグ名変更
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
      this.toast('タグ名を変更しました')
    }
  }
}
</script>
