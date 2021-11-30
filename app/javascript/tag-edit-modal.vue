<template lang="pug">
.overlay(@click.self='closeModal')
  .content
    label(for='tag_name') タグ編集
    input#tag_name(v-model='name', name='tag[name]')
    button(:disabled='validation', @click.prevent='updateTag') 更新
    button(@click.prevent='closeModal') キャンセル
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
.overlay {
  z-index: 1;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.content {
  z-index: 2;
  width: 50%;
  padding: 1em;
  background: #fff;
}
</style>
