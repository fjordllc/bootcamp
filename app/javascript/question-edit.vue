<template lang="pug">
.thread
  userIcon(:user='question.user', blockClassSuffix='thread')
  .thread__inner.a-card
    .thread-header.has-count
      a.a-count-badge(href='#comments')
        .a-count-badge__label
          | 回答
        .a-count-badge__value.is-counting(v-if='!isAnswerCountUpdated')
          i.fas.fa-spinner
        .a-count-badge__value(:class='answerCount === 0 ? "is-zero" : ""')
          | {{ answerCount }}
      .thread-header__row
        .thread-header-metas
          .thread-header-metas__start
            .thread-header-metas__meta(v-if='question.wip')
              .a-meta
                span.a-meta__value
                  | 質問作成中
            .thread-header-metas__meta
              a.a-user-name(:href='`/users/${question.user.id}`')
                | {{ question.user.long_name }}
            .thread-header-metas__meta(v-if='!question.wip')
              time.a-meta
                span.a-meta__label
                  | 公開
                span.a-meta__value
                  | {{ publishedAt }}
            .thread-header-metas__meta(v-if='!question.wip')
              .a-meta
                span.a-meta__label
                  | 更新
                time.a-meta__value
                  | {{ updatedAt }}
      .thread-header__row
        .thread-header-title(:class='question.wip ? "is-wip" : ""')
          .thread-header-title__label.is-solved.is-success(
            v-if='question.correct_answer !== null'
          )
            | 解決済
          .thread-header-title__label.is-wip(v-else-if='question.wip')
            | WIP
          .thread-header-title__label.is-solved.is-danger(v-else)
            | 未解決
          h1.thread-header-title__title
            | {{ title }}
      .thread-header__row
        .thread-header-actions
          .thread-header-actions__start
            .thread-header-actions__action
              WatchToggle(:watchableId='question.id', watchableType='Question')
            .thread-header-actions__action
              BookmarkButton(
                :bookmarkableId='question.id',
                bookmarkableType='Question'
              )
          .thread-header-actions__end
            .thread-header-actions__action
              a.a-button.is-sm.is-secondary.is-block(
                :href='`/questions/${question.id}.md`',
                target='_blank'
              )
                | Raw
    .thread-category
      a.thread-category__link(:href='`/practices/${practiceId}`')
        | {{ practiceTitle }}
    .thread__tags
      tags(
        :tagsInitialValue='question.tag_list',
        :questionId='question.id',
        tagsParamName='question[tag_list]'
      )

    .thread__body(v-if='!editing')
      .thread__description.a-long-text.is-md(v-html='markdownDescription')
      .thread-question__reactions
        reaction(
          :reactionable='question',
          :currentUser='currentUser',
          :reactionableId='`Question_${question.id}`'
        )
      footer.card-footer(
        v-if='currentUser.id === question.user.id || isRole("mentor")'
      )
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item
              button.card-main-actions__action.a-button.is-md.is-secondary.is-block(
                @click='startEditing'
              )
                i#new.fas.fa-pen
                | 内容修正
            li.card-main-actions__item.is-sub
              // - vue.jsでDELETE methodのリンクを作成する方法が、
              // - 見つからなかったので、
              // - いい実装方法ではないが、
              // - Rails特定の属性(data-confirm, data-method)を付与して、
              // - 確認ダイアログとDELETE methodのリンクを実装する
              a.js-delete.card-main-actions__muted-action(
                :href='`/questions/${question.id}`',
                data-confirm='本当によろしいですか？',
                data-method='delete'
              )
                | 削除する
          .card-footer__notice(v-show='displayedUpdateMessage')
            p
              | 質問を更新しました
    .thread__body(v-show='editing')
      .thread-form
        form.form(name='question')
          .form__items
            .form-item
              label.a-form-label
                | プラクティス
              .select-practices(v-if='practices === null')
                .empty
                  .fas.fa-spinner.fa-pulse
                  | ロード中
              .select-practices(v-show='practices !== null')
                select.js-select2(
                  v-model='edited.practiceId',
                  v-select2,
                  name='question[practice]'
                )
                  option(
                    v-for='practice in practices',
                    :key='practice.id',
                    :value='practice.id'
                  ) {{ practice.categoryAndPracticeName }}
            .form-item
              .a-form-label
                | タイトル
              input.a-text-input(
                v-model='edited.title',
                name='question[title]'
              )
            .form-item
              .form-tabs.js-tabs
                .form-tabs__tab.js-tabs__tab(
                  :class='{ "is-active": isActive("question") }',
                  @click='changeActiveTab("question")'
                )
                  | 質問文
                .form-tabs__tab.js-tabs__tab(
                  :class='{ "is-active": isActive("preview") }',
                  @click='changeActiveTab("preview")'
                )
                  | プレビュー
              .form-tabs-item__markdown-parent.js-markdown-parent
                .form-tabs-item__markdown.js-tabs__content(
                  :class='{ "is-active": isActive("question") }'
                )
                  textarea#js-question-content.a-text-input.form-tabs-item__textarea(
                    v-model='edited.description',
                    data-preview='#js-question-preview',
                    name='question[description]'
                  )
                .form-tabs-item__markdown.js-tabs__content(
                  :class='{ "is-active": isActive("preview") }'
                )
                  #js-question-preview.js-preview.a-long-text.is-md.form-tabs-item__preview

          .card-main-actions
            ul.card-main-actions__items
              li.card-main-actions__item
                button.a-button.is-md.is-primary.is-block(
                  @click='updateQuestion(true)',
                  :disabled='!validation',
                  type='button'
                )
                  | WIP
              li.card-main-actions__item
                button.a-button.is-md.is-warning.is-block(
                  @click='updateQuestion(false)',
                  :disabled='!validation',
                  type='button'
                )(
                  v-if='question.wip'
                )
                  | 質問を公開
                button.a-button.is-md.is-warning.is-block(
                  @click='updateQuestion(false)',
                  :disabled='!validation',
                  type='button'
                )(
                  v-else
                )
                  | 更新する
              li.card-main-actions__item
                button.a-button.is-md.is-secondary.is-block(
                  @click='cancel',
                  type='button'
                )
                  | キャンセル
</template>
<script>
import Reaction from './reaction.vue'
import WatchToggle from './watch-toggle.vue'
import BookmarkButton from './bookmark-button.vue'
import MarkdownInitializer from './markdown-initializer'
import TextareaInitializer from './textarea-initializer'
import Tags from './question_tags.vue'
import UserIcon from './user-icon.vue'
import confirmUnload from './confirm-unload'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import role from './role'
dayjs.locale(ja)

export default {
  components: {
    WatchToggle: WatchToggle,
    BookmarkButton: BookmarkButton,
    tags: Tags,
    reaction: Reaction,
    userIcon: UserIcon
  },
  directives: {
    select2: {
      inserted(el) {
        $(el).on('select2:select', () => {
          el.dispatchEvent(new Event('change'))
        })
      }
    }
  },
  mixins: [confirmUnload, role],
  props: {
    question: { type: Object, required: true },
    answerCount: { type: Number, required: true },
    isAnswerCountUpdated: { type: Boolean, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      title: this.question.title,
      description: this.question.description,
      practiceId: this.question.practice.id,
      edited: {
        title: this.question.title,
        description: this.question.description,
        practiceId: this.question.practice.id
      },
      editing: false,
      displayedUpdateMessage: false,
      tab: 'question',
      practices: null
    }
  },
  computed: {
    updatedAt() {
      return dayjs(this.question.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    publishedAt() {
      return dayjs(this.question.published_at).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    practiceTitle() {
      const { practices, question, practiceId } = this

      return practices === null
        ? question.practice.title
        : practices.find((practice) => practice.id === practiceId).title
    },
    markdownDescription() {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.description)
    },
    validation() {
      const { title, description } = this.edited
      return title.length > 0 && description.length > 0
    }
  },
  created() {
    this.fetchPractices()
  },
  mounted() {
    TextareaInitializer.initialize(`#js-question-content`)
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchPractices() {
      fetch('/api/practices.json', {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((practices) => {
          this.practices = practices.map((practice) => {
            practice.categoryAndPracticeName = `[${practice.category}] ${practice.title}`
            return practice
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    startEditing() {
      this.editing = true
      this.$nextTick(() => {
        $(`.question-id-${this.question.id}`).trigger('input')
      })
      $('.js-select2').select2({
        closeOnSelect: true
      })
    },
    finishEditing(hasUpdatedQuestion) {
      this.editing = false
      this.displayedUpdateMessage = hasUpdatedQuestion
    },
    isActive(tab) {
      return this.tab === tab
    },
    changeActiveTab(tab) {
      this.tab = tab
    },
    changedQuestion(values) {
      return Object.entries(values).some(([key, val]) => {
        return val !== this[key]
      })
    },
    updateQuestion(wip) {
      this.edited.wip = wip
      if (!this.changedQuestion(this.edited)) {
        // 何も変更していなくても、更新メッセージは表示する
        // 表示しないとユーザーが更新されていないと不安に感じる
        this.finishEditing(true)
        return
      }

      const { title, description, practiceId } = this.edited
      const params = {
        question: {
          title,
          description,
          practice_id: practiceId,
          wip
        }
      }
      fetch(`/api/questions/${this.question.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(() => {
          Object.entries(this.edited).forEach(([key, val]) => {
            this[key] = val
          })
          this.finishEditing(true)
          this.$emit('afterUpdateQuestion')
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    cancel() {
      Object.keys(this.edited).forEach((key) => {
        this.edited[key] = this[key]
      })
      this.finishEditing(false)
    }
  }
}
</script>
