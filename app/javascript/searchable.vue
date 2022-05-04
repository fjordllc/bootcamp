<template lang="pug">
.card-list-item(:class='searchableClass')
  .card-list-item__inner
    .card-list-item__label(v-if='searchable.is_comment_or_answer')
      | {{ searchable.model_name_with_i18n }}
      .card-list-item__label-option
        | コメント
    .card-list-item__label(v-else)
      | {{ searchable.model_name_with_i18n }}
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item-title__icon.is-wip(v-if='searchable.wip')
            | WIP
          .card-list-item-title__title
            a.card-list-item-title__link.a-text-link(:href='searchable.url')
              | {{ searchable.title }}
      .card-list-item__row
        .card-list-item__summary
          p(v-html='summary')
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(
              v-if='!["practice", "page", "user"].includes(searchable.model_name)'
            )
              a.a-user-name(:href='userUrl')
                | {{ searchable.login_name }}
            .card-list-item-meta__item
              time.a-meta(:datetime='searchable.updated_at', pubdate='pubdate')
                | {{ updatedAt }}
            .card-list-item-meta__item(v-if='searchable.is_comment_or_answer')
              .a-meta
                | （
                a.a-user-name(:href='documentAuthorUserUrl')
                  | {{ searchable.document_author_login_name }}
                | &nbsp;{{ searchable.model_name_with_i18n }}
                | ）
            .card-list-item-meta__item(
              v-if='isRole("admin") && canDisplayTalk'
            )
              a.a-text-link(:href='talkUrl')
                | 相談部屋
</template>
<script>
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import role from 'role'
dayjs.locale(ja)
export default {
  mixins: [role],
  props: {
    searchable: { type: Object, required: true },
    word: { type: String, required: true }
  },
  data() {
    return {
      currentUser: window.currentUser
    }
  },
  computed: {
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
    },
    searchableClass() {
      if (this.searchable.wip) {
        return `is-wip is-${this.searchable.model_name}`
      } else {
        return `is-${this.searchable.model_name}`
      }
    }
  }
}
</script>
