<template lang="pug">
.admin-table.is-grab
  table.admin-table__table
    thead.admin-table__header
      tr.admin-table__labels
        th.admin-table__label
          | プラクティス
        th.admin-table__label
          | 所属カテゴリー
        th.admin-table__label
          | 提出物
        th.admin-table__label
          | 日報
        th.admin-table__label
          | Q&A
        th.admin-table__label.actions
          | 編集
    tbody.admin-table__items
      tr.admin-table__item(v-for='practice in practices', :key='practice.id')
        td.admin-table__item-value
          a(:href='`/practices/${practice.id}`')
            | {{ practice.title }}
        td.admin-table__item-value.is-text-align-right
          .a-text-link(@click='openModal(practice)')
            | {{ practice.categories_practice.size }}
        td.admin-table__item-value.is-text-align-right(
          v-if='practice.submission')
          a(:href='`/practices/${practice.id}/products`')
            | {{ practice.products.size }}
        td.admin-table__item-value.is-text-align-center(v-else)
          span.admin-table__item-blank
            | 不要
        td.admin-table__item-value.is-text-align-right
          a(:href='`/practices/${practice.id}/reports`')
            | {{ practice.reports.size }}
        td.admin-table__item-value.is-text-align-right
          a(:href='`/practices/${practice.id}/questions`')
            | {{ practice.questions.size }}
        td.admin-table__item-value.is-text-align-center
          ul.is-inline-buttons
            li
              a.a-button.is-sm.is-secondary.is-icon(
                :href='`/mentor/practices/${practice.id}/edit`')
                i.fa-solid.fa-pen
      modal(
        @closeModal='closeModal',
        :postPractice='postPractice',
        v-if='showModal')
</template>
<script>
import CSRF from 'csrf'
import mentorPracticeModalVue from './mentor-practice-modal.vue'

export default {
  name: 'MentorPractices',
  components: {
    modal: mentorPracticeModalVue
  },
  data() {
    return {
      practices: [],
      showModal: false
    }
  },
  created() {
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
    getPractices() {
      fetch(`/api/mentor/practices`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
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
