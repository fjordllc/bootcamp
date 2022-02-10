<template lang="pug">
.thread-list-item(:class='modelName')
  .thread-list-item__inner
    .thread-list-item__label(v-if='searchable.is_comment_or_answer')
      | {{ searchable.model_name_with_i18n }}
      .thread-list-item__label-option
        | コメント
    .thread-list-item__label(v-else)
      | {{ searchable.model_name_with_i18n }}
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__title
            a.thread-list-item-title__link(:href='searchable.url')
              | {{ searchable.title }}
      .thread-list-item__row
        .thread-list-item__summary
          p(v-html='summary')
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item(
              v-if='!["practice", "page", "user"].includes(searchable.model_name)'
            )
              a.a-user-name(:href='userUrl')
                | {{ searchable.login_name }}
            .thread-list-item-meta__item
              time.a-meta(:datetime='searchable.updated_at', pubdate='pubdate')
                | {{ updatedAt }}
            .thread-list-item-meta__item(
              v-if='searchable.is_comment_or_answer'
            )
              .a-meta
                | （
                a.a-user-name(:href='documentAuthorUserUrl')
                  | {{ searchable.document_author_login_name }}
                | &nbsp;{{ searchable.model_name_with_i18n }}
                | ）
            a(v-if='canDisplayTalk', :href='talkUrl')
              | 相談部屋
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)
export default {
  props: {
    searchable: { type: Object, required: true },
    word: { type: String, required: true }
  },
  computed: {
    modelName() {
      return `is-${this.searchable.model_name}`
    },
    userUrl() {
      return `/users/${this.searchable.user_id}`
    },
    documentAuthorUserUrl() {
      return `/users/${this.searchable.document_author_id}`
    },
    updatedAt() {
      return dayjs(this.searchable.updated_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    canDisplayTalk() {
      return this.searchable.model_name === 'user' && this.searchable.talk_id
    },
    talkUrl() {
      return `/talks/${this.searchable.talk_id}`
    },
    summary() {
      const word = this.word
      const wordsPattern = word
        .trim()
        .replaceAll(/[.*+?^=!:${}()|[\]/\\]/g, '\\$&')
        .replaceAll(/\s+/g, '|')
      const pattern = new RegExp(wordsPattern, 'gi')
      if (word) {
        return this.searchable.summary.replaceAll(
          pattern,
          `<strong class='matched_word'>$&</strong>`
        )
      } else {
        return this.searchable.summary
      }
    }
  }
}
</script>
