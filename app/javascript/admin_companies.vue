<template lang="pug">
  //- = paginate @companies ページング追加する
  .container.is-padding-horizontal-0-sm-down
    .admin-table
      table.admin-table__table
        thead.admin-table__header
          tr.admin-table__labels
            th.admin-table__label
              | 名前
            th.admin-table__label
              | ロゴ
            th.admin-table__label
              | ウェブサイト
            th.admin-table__label.actions
              | リンク
            th.admin-table__label.actions
              | 操作
        tbody.admin-table__items
          tr.admin-table__item(
            v-for='company in companies',
            :key='company.id'
          )
            td.admin-table__item-value
              | {{ company.name }}
            td.admin-table__item-value.is-text-align-center
              img.admin-table__item-logo-image(:src='company.logo_url')
            td.admin-table__item-value
              | {{ company.website }}
            td.admin-table__item-value.is-text-align-center
              a.a-button.is-sm.is-secondary.is-icon(
                :href='company.adviser_sign_up_url'
              )
                i.fas.fa-user-plus
            td.admin-table__item-value.is-text-align-center
              ul.is-inline-buttons
                li
                  a.a-button.is-sm.is-secondary.is-icon.spec-edit(
                    :href='`/admin/companies/${company.id}/edit`'
                  )
                    i.fas.fa-pen
                li
                  a.a-button.is-sm.is-danger.is-icon.js-delete(
                    @click='destroy(company)'
                  )
                    i.fas.fa-trash-alt
  //- = paginate @companies ページング追加する


</template>
<script>
export default {
  data() {
    return {
      companies: []
    }
  },
  created() {
    this.getCompaniesPage()
  },
  methods: {
    token() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') : ''
    },
    getCompaniesPage() {
      fetch('/api/admin/companies', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => response.json())
        .then((json) => {
          this.companies = json.companies
          this.loaded = true
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    destroy(company) {
      console.log(this.companies)
      console.log(this.company)
      if (window.confirm('本当によろしいですか？')) {
        fetch(`/api/admin/companies/${company.id}.json`, {
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
                // eslint-disable-next-line vue/no-mutating-props
                console.log(this.companies);
                this.companies = this.companies.filter(
                  (v) => v.id !== company.id
                )
              } else {
                alert('削除に失敗しました')
              }
            })
            .catch((error) => {
              console.warn('Failed to parsing', error)
            })
    }}}}


</script>
