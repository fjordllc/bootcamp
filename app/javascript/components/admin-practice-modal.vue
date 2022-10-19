<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h2.card-header__title
        | 所属カテゴリー
    .card-body
        | {{ practice.category_names }}
    ul.card-main-actions__items
      li.card-main-actions__item.is-main
        button.a-button.is-primary.is-sm.is-block(@click.prevent='closeModal')
          | 閉じる
</template>
<script>
export default {
  props: {
    practice: { type: Array, required: true }
  },
  methods: {
    closeModal() {
      this.$emit('closeModal')
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
