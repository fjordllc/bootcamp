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
          a(:href='`/practices/${practice.id}`')
            | {{ practice.title }}
        button.a-button.is-sm.is-secondary.is-block(
          @click.prevent='openModal(practice)'
        )
          | {{ practice.categories_practice.size }}
        modal(
          @closeModal='closeModal',
          :postPractice='postPractice',
          v-if='showModal'
        )
          | {{ practice.categories_practice.size }}
        td.admin-table__item-value(v-if='practice.submission')
          a(:href='`/practices/${practice.id}/products`')
            | {{ practice.products.size }}
        td.admin-table__item-value(v-else)
          | {{ `提出物不要` }}
        td.admin-table__item-value
          a(:href='`/practices/${practice.id}/reports`')
            | {{ practice.reports.size }}
        td.admin-table__item-value
          a(:href='`/practices/${practice.id}/questions`')
            | {{ practice.questions.size }}
        td.admin-table__item-value.is-text-align-center
          a(:href='`/practices/${practice.id}/edit`')
            | {{ `編集` }}
</template>
<script>
import adminPracticeModalVue from './admin-practice-modal.vue'

export default {
  name: 'AdminPractices',
  components: {
    modal: adminPracticeModalVue
  },
  data() {
    return {
      practices: [],
      showModal: false
    }
  },
  computed: {
    url() {
      return `/api/admin/practices`
    }
  },
  created() {
    window.onpopstate = () => {
      this.getPractices()
    }
    this.getPractices()
  },
  methods: {
    openModal(practice) {
      this.showModal = true
      this.postPractice = practice
    },
    closeModal() {
      this.showModal = false
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getPractices() {
      fetch(this.url, {
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
          this.practices = []
          json.practices.forEach((r) => {
            this.practices.push(r)
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
