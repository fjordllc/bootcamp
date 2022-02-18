<template lang="pug">
.practice-status-buttons
  .practice-status-buttons__start
    .practice-status-buttons__label
      | ステータス
    ul.practice-status-buttons__items.is-button-group
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-unstarted.js-not-complete(
          v-bind:disabled='statusName === "unstarted"',
          v-bind:class='[statusName === "unstarted" ? "is-active" : "is-inactive"]',
          @click='pushStatus("unstarted")'
        )
          | 未着手
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-started.js-started(
          v-bind:disabled='statusName === "started"',
          v-bind:class='[statusName === "started" ? "is-active" : "is-inactive"]',
          @click='pushStatus("started")'
        )
          | 着手
      li.practice-status-buttons__item(v-if='submission === "true"')
        button.practice-status-buttons__button.a-button.is-md.is-block.is-submitted.js-submitted(
          v-bind:disabled='statusName === "submitted"',
          v-bind:class='[statusName === "submitted" ? "is-active" : "is-inactive"]',
          @click='pushStatus("submitted")'
        )
          | 提出
      li.practice-status-buttons__item
        button.practice-status-buttons__button.a-button.is-md.is-block.is-complete.js-complete(
          v-bind:disabled='statusName === "complete"',
          v-bind:class='[statusName === "complete" ? "is-active" : "is-inactive"]',
          @click='pushStatus("complete")'
        )
          | 完了
  .practice-status-buttons__end(v-if='submission === "false"')
    .practice-status-buttons__note
      | このプラクティスに提出物はありません。終了条件をクリアしたら完了にしてください。
</template>
<script>
import 'whatwg-fetch'

export default {
  props: {
    practiceId: { type: String, required: true },
    status: { type: String, required: true },
    submission: { type: String, required: true }
  },
  data() {
    return {
      statusName: null
    }
  },
  mounted() {
    this.statusName = this.status
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    pushStatus(name) {
      const params = new FormData()
      params.append('status', name)

      fetch(`/api/practices/${this.practiceId}/learning.json`, {
        method: 'PATCH',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: params
      })
        .then((response) => {
          if (response.ok) {
            this.statusName = name
            return this
          } else {
            response.json().then((data) => {
              alert(data.error)
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
<style scoped></style>
