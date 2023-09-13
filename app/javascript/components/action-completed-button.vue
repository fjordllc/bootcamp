<template lang="pug">
.thread-comment-form.is-action-completed
  .thread-comment__author
  .thread-comment-form__form
    .action-completed(v-if='isActionCompleted')
      .action-completed__action
        .a-button.is-sm.is-block.check-button.is-muted-borderd(
          @click='changeCompleted')
          i.fas.fa-check
          | 対応済です
      .action-completed__description
        p
          | お疲れ様でした！
          | 相談者から次のアクションがあった際は、自動で未対応のステータスに変更されます。
          | 再度このボタンをクリックすると、未対応にステータスに戻ります。

    .action-complete(v-else)
      .action-completed__action
        .a-button.is-sm.is-block.check-button.is-warning(
          @click='changeCompleted')
          i.fas.fa-redo
          | 対応済にする
      .action-completed__description
        p
          | 返信が完了し次は相談者からのアクションの待ちの状態になったとき、
          | もしくは、相談者とのやりとりが一通り完了した際は、
          | このボタンをクリックして対応済のステータスに変更してください。
</template>
<script>
import toast from 'toast'
import Bootcamp from '../bootcamp'

export default {
  name: 'ActionCompletedButton',
  mixins: [toast],
  props: {
    isInitialActionCompleted: { type: Boolean, required: true },
    commentableId: { type: Number, required: true }
  },
  data() {
    return {
      isActionCompleted: false
    }
  },
  created() {
    this.isActionCompleted = this.isInitialActionCompleted
  },
  methods: {
    completedLabel() {
      return this.isActionCompleted ? '対応済み' : '未対応'
    },
    changeCompleted() {
      this.isActionCompleted = !this.isActionCompleted
      const params = {
        talk: { action_completed: this.isActionCompleted }
      }

      Bootcamp.patch(`/api/talks/${this.commentableId}`, params)
        .then(() => {
          this.toast(`${this.completedLabel()}にしました`)
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
