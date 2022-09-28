<template lang="pug">
.admin-table.is-grab
  table.admin-table__table
    thead.admin-table__header
      tr.admin-table__labels
        th.admin-table__label
          | プラクティス名
        th.admin-table__label
          | 所属カテゴリー数
        th.admin-table__label
          | 提出物数
        th.admin-table__label
          | 日報数
        th.admin-table__label
          | Q&A数
        th.admin-table__label.actions
          | 編集
    tbody.admin-table__items
      tr.admin-table__item(v-for='practice in practices', :key='practice.id')
        td.admin-table__item-value
          a(:href='`practices/${practice.id}`')
            | {{ practice.title }}
        td.admin-table__item-value
          | {{ practice.category_id }}
        td.admin-table__item-value
          | {{ `提出物不要` }}
        td.admin-table__item-value
          | {{ `日報一覧` }}
        td.admin-table__item-value
          | {{ `Q&A数` }}
        td.admin-table__item-value.is-text-align-center
          ul.is-inline-buttons
            li
              a.a-button.is-sm.is-secondary.is-icon.spec-edit(
                :href='`/admin/practices/${practice.id}/edit`'
              )
                i.fa-solid.fa-pen
            li
              a.a-button.is-sm.is-danger.is-icon.js-delete(
                @click='destroy(practice)'
              )
                i.fa-solid.fa-trash-alt
</template>
<script>
export default {
  props: {
    allAdminPractices: { type: String, required: true }
  },
  data() {
    return {
      practices: JSON.parse(this.allAdminPractices)
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    destroy(practice) {
      if (window.confirm('本当によろしいですか？')) {
        fetch(`/api/practices/${practice.id}.json`, {
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
              this.practices = this.practices.filter(
                (v) => v.id !== practice.id
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
