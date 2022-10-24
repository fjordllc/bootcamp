<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h2.card-header__title
        | 所属カテゴリー
    .card-body.new-line(v-for='category_id_name in postPractice.category_ids_names')
      td.admin-table__item-value(@click.prevent='linkCategory(category_id_name.category_id)')
        | {{ category_id_name.category_name }}
    ul.card-main-actions__items
      li.card-main-actions__item.is-main
        button.a-button.is-primary.is-sm.is-block(@click.prevent='closeModal')
          | 閉じる
</template>
<script>
export default {
  name: "AdminPracticeModal",
  props: {
    postPractice: { type: Object, required: false }
  },
  methods: {
    closeModal() {
      this.$emit('closeModal')
    },
    linkCategory(category_id) {
      window.location.href = `/admin/categories/${category_id}`
    }
  }
}
</script>
<style>
.new-line {
  white-space: pre-wrap;
}
</style>
