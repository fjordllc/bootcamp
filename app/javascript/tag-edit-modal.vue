<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h2.card-header__title
        | タグ名変更
    .card-body
      label.a-form-label(for='tag_name')
        | タグ名
      input#tag_name.a-text-input(v-model='name', name='tag[name]')
    footer.card-footer
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item.is-main
            button.a-button.is-primary.is-md.is-block(
              :disabled='validation',
              @click.prevent='updateTag'
            )
              | 変更
          li.card-main-actions__item.is-sub
            .card-main-actions__muted-action(@click.prevent='closeModal')
              | キャンセル
</template>
<script>
export default {
  props: {
    id: { type: String, required: true },
    nameProp: { type: String, required: true }
  },
  data() {
    return {
      name: '',
      initialName: ''
    }
  },
  computed: {
    validation() {
      return this.name === this.initialName || this.name === ''
    }
  },
  mounted() {
    this.name = this.nameProp
    this.initialName = this.nameProp
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    closeModal() {
      this.$emit('closeModal')
    },
    updateTag() {
      if (this.name === '' || this.name === this.initialName) {
        return null
      }
      const params = {
        tag: { name: this.name }
      }
      fetch(`/api/tags/${this.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(() => {
          this.$emit('updateTag', this.name)
          this.closeModal()
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
<style>
.content {
  z-index: 2;
  width: 50%;
  padding: 1em;
  background: #fff;
}
</style>
