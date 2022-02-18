<template lang="pug">
.admin-table.is-grab
  table.admin-table__table
    thead.admin-table__header
      tr.admin-table__labels
        th.admin-table__label
          | 名前
        th.admin-table__label
          | URLスラッグ
        th.admin-table__label.actions
          | 操作
    tbody.admin-table__items
      tr.admin-table__item(v-for='category in categories', :key='category.id')
        td.admin-table__item-value
          | {{ category.name }}
        td.admin-table__item-value
          | {{ category.slug }}
        td.admin-table__item-value.is-text-align-center
          ul.is-inline-buttons
            li
              a.a-button.is-sm.is-secondary.is-icon.spec-edit(
                :href='`/admin/categories/${category.id}/edit`'
              )
                i.fas.fa-pen
            li
              a.a-button.is-sm.is-danger.is-icon.js-delete(
                @click='destroy(category)'
              )
                i.fas.fa-trash-alt
</template>
<script>
export default {
  props: {
    allCategories: { type: String, required: true }
  },
  data() {
    return {
      categories: JSON.parse(this.allCategories)
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    destroy(category) {
      if (window.confirm('本当によろしいですか？')) {
        fetch(`/api/categories/${category.id}.json`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        })
          .then((response) => {
            if (response.ok) {
              this.categories = this.categories.filter(
                (v) => v.id !== category.id
              )
            }
          })
          .catch((error) => {
            console.warn(error)
          })
      }
    }
  }
}
</script>
