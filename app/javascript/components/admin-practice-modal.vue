<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h2.card-header__title
        | 所属カテゴリー
    .card-body.new-line
      | {{ categoryNames }}
    ul.card-main-actions__items
      li.card-main-actions__item.is-main
        button.a-button.is-primary.is-sm.is-block(@click.prevent='closeModal')
          | 閉じる
</template>
<script>
export default {
  name: "AdminPracticeModal",
  props: {
    val: { type: Object, required: false }
  },
  computed: {
    categoryNames: function() {
      return this.val.category_names.join('\n')
    }
  },
  methods: {
    closeModal() {
      this.$emit('closeModal')
    }
  }
}
</script>
<style>
.new-line {
  white-space: pre-wrap;
}
</style>
