<template lang="pug">
.form-actions.is-action-completed.mb-8
  ul.form-actions__items
    li.form-actions__item.is-main
      label.support-checkbox
        .a-button.is-md.is-block.check-button.is-muted-borderd(
          v-if='isActionCompleted',
          @click='changeCompleted')
          i.fas.fa-redo
          | 未対応にする
        .a-button.is-md.is-block.check-button.is-warning(
          v-else,
          @click='changeCompleted')
          i.fas.fa-check
          | 対応済にする
</template>
<script>
import CSRF from 'csrf'
import toast from 'toast'

export default {
  name: 'ActionCompleted',
  mixins: [toast],
  props: {
    isInitialCompleted: { type: Boolean, required: true },
    commentableId: { type: String, required: true }
  },
  data() {
    return {
      isActionCompleted: false
    }
  },
  computed: {
    CompletedLabel() {
      return this.isActionCompleted ? '対応済み' : '未対応'
    }
  },
  created() {
    this.isActionCompleted = this.isInitialCompleted
  },
  methods: {
    changeCompleted() {
      this.isActionCompleted = !this.isActionCompleted
      const params = {
        talk: { action_completed: this.isActionCompleted }
      }

      fetch(`/api/talks/${this.commentableId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(() => {
          this.toast(`${this.CompletedLabel}にしました`)
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
