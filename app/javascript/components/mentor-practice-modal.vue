<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h2.card-header__title
        | 所属カテゴリー
    .card-body(v-for='category_id_name in postPractice.category_ids_names')
      .card__description
        table.admin-table__table
          tbody.admin-table__items
            tr.admin-table__item
              td.admin-table__item-value.is-text-align-left(
                @click.prevent='linkCategory(category_id_name.category_id)')
                | {{ category_id_name.category_name }}
    footer.card-footer
      ul.card-main-actions__items
        li.card-main-actions__item.is-main
          button.a-button.is-primary.is-sm.is-block(
            @click.prevent='closeModal')
            | 閉じる
</template>
<script>
export default {
  name: 'MentorPracticeModal',
  props: {
    postPractice: { type: Object, required: true }
  },
  methods: {
    closeModal() {
      this.$emit('closeModal')
    },
    linkCategory(categoryId) {
      window.location.href = `/mentor/categories/${categoryId}`
    }
  }
}
</script>
