<template lang="pug">
.thread__inner.a-card(
  v-if="question === null || practices === null || currentUser === null"
)
  .empty
    .fas.fa-spinner.fa-pulse
    |  ロード中
.thread__inner.a-card(v-else)
  header.thread-header
    .thread-header__upper-side
      a.thread-header__author(:href="`/users/${question.user.id}`")
        | {{ question.user.login_name }}
      .thread-header__date
        time.thread_header_date-value(
          :datetime="updateAtISO8601",
          pubdate="pubdate"
        )
          | {{ updateAt }}
    .thread-practice(v-if="question.practice")
      a.thread-practice__link(:href="`/practices/${question.practice.id}`")
        | {{ question.practice.title }}
    h1.thread-header__title
      span.thread-header__title-icon.is-solved.is-success(
        v-if="question.correct_answer !== null"
      )
        | 解決済
      span.thread-header__title-icon.is-solved.is-danger(v-else)
        | 未解決
      | {{ question.title }}
    .thread-header__lower-side
      watch(:watchableId="questionId", watchableType="Question")
      .thread-header__raw
        a.a-button.is-sm.is-secondary(
          :href="`/questions/${questionId}.md`",
          target="_blank"
        )
          | Raw
  .thread__tags
    tags(
      :tagsInitialValue="question.tag_list"
      :questionId="questionId"
      tagsParamName="question[tag_list]"
      :editAble="editAble"
    )

  .thread__body
    .thread-question__body.a-card(v-if="!editing")
      .thread-question__description.js-target-blank.is-long-text(
        v-html="markdownDescription"
      )
      reaction(
        :reactionable="question",
        :currentUser="currentUser",
        :reactionableId="`Question_${this.questionId}`"
      )
      footer.card-footer(v-if="editAble")
        .card-footer-actions
          ul.card-footer-actions__items
            li.card-footer-actions__item
              button.card-footer-actions__action.a-button.is-md.is-primary.is-block(
                @click="editQuestion"
              )
                i.fas.fa-pen
                  | 内容修正
            li.card-footer-actions__item
              button.js-delete.card-footer-actions__action.a-button.is-md.is-danger.is-block(
                @click="deleteQuestion"
              )
                i.fas.fa-trash-alt
                | 削除
    .thread-question-for(v-show="editing")
      form(name="question")
        .form__items
          .form-item
            .form-item
              .row
                .col-lg-6.col-xs-12
                  .form-item
                    | プラクティス
                    .select-practices
                      select(v-model="selectedId")
                        option(
                          v-for="practice in practices",
                          :value="practice.id"
                        )
                          div {{ practice.categoryAndPracticeName }}
            .form-item
              .row.js-markdown-parent
                .col-md-6.col-xs-12
                  .a-label
                    | タイトル
                  input(v-model="tempTitle", name="question[title]")
            .form-item
              .thread-question-form__tabs.js-tabs
                .thread-question-form__tab.js-tabs__tab(
                  v-bind:class="{ 'is-active': isActive('question') }",
                  @click="changeActiveTab('question')"
                )
                  | コメント
                .thread-question-form__tab.js-tabs__tab(
                  v-bind:class="{ 'is-active': isActive('preview') }",
                  @click="changeActiveTab('preview')"
                )
                  | プレビュー
              .thread-question-form__markdown-parent.js-markdown-parent
                .thread-question-form__markdown.js-tabs__content(
                  v-bind:class="{ 'is-active': isActive('question') }"
                )
                  // - TODO classQuestionId は必要?
                  textarea#js-question-content.a-text-input.js-warning-form.thread-question-form__textarea(
                    v-model="tempDescription",
                    data-preview="#js-question-preview",
                    name="question[description]"
                  )
                .thread-question-form__markdown.js-tabs__content(
                  :class="{ 'is-active': isActive('preview') }"
                )
                  #js-question-preview.js-preview.is-long-text.thread-question-form__preview
            ul.thread-question-form__actions
              li.thread-question-form__action
                button.a-button.is-md.is-warning.is-block(
                  @click="updateQuestion",
                  v-bind:disabled="!validation",
                  type="button"
                )
                  | 更新する
              li.thread-question-form__action
                button.a-button.is-md.is-secondary.is-block(
                  @click="cancel",
                  type="button"
                )
                  | キャンセル
</template>
<script>
import Reaction from './reaction.vue'
import Watch from './watch.vue'
import MarkdownInitializer from './markdown-initializer'
import TextareaInitializer from './textarea-initializer'
import Tags from './question_tags.vue'
import moment from 'moment'
moment.locale('ja')

export default {
  components: {
    watch: Watch,
    tags: Tags,
    reaction: Reaction,
  },
  props: {
    currentUserId: { type: String, required: true },
    questionId: { type: String, required: true },
  },
  data: () => {
    return {
      tempTitle: '',
      tempDescription: '',
      // practiceIdでは駄目なの?
      selectedId: '',
      editing: false,
      question: null,
      practices: null,
      currentUser: null,
      tab: 'question',
    }
  },
  async created() {
    this.question = await this.fetchQuestion()
    this.currentUser = await this.fetchUser(this.currentUserId)
    this.practices = (await this.fetchPractices(this.question.user.id))
      .map(practice => {
        practice.categoryAndPracticeName = `[${practice.category}] ${practice.title}`
        return practice
      });
    this.setTemporaryData()
  },
  mounted: function () {
    TextareaInitializer.initialize(`#js-question-content`)
  },
  methods: {
    async fetchQuestion() {
      return fetch(`/api/questions/${this.questionId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
          return null
        })
    },
    async fetchUser(id) {
      return fetch(`/api/users/${id}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
        redirect: 'manual',
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
          return null
        })
    },
    async fetchPractices(userId) {
      return fetch(`/api/practices.json?user_id=${userId}`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
          return null
        })
    },
    setTemporaryData() {
      this.tempTitle = this.question.title
      this.tempDescription = this.question.description
      if (this.question.practice) this.selectedId = this.question.practice.id  // ここはなにやっているの
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    isActive: function (tab) {
      return this.tab === tab
    },
    changeActiveTab: function (tab) {
      this.tab = tab
    },
    cancel: function () {
      this.setTemporaryData()
      this.editing = false
    },
    editQuestion: function () {
      this.editing = true
      this.$nextTick(function () {
        $(`.question-id-${this.questionId}`).trigger('input')
      })
    },
    updateQuestion: function () {
      const params = {
        question: {
          title: this.tempTitle,
          description: this.tempDescription,
          practice_id: this.selectedId,
        },
      }
      fetch(`/api/questions/${this.questionId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params),
      })
        .then(() => {
          this.question.title = this.tempTitle
          this.question.description = this.tempDescription
          if (this.question.practice) {
            this.question.practice.id = this.selectedId
            this.question.practice.title = this.practices
              .find(practice => practice.id === this.selectedId)
              .title
          }

          this.editing = false
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    /* Questionいる? */
    deleteQuestion: function () {
      if (window.confirm('削除してよろしいですか？')) {
        fetch(`/api/questions/${this.questionId}.json`, {
          method: 'DELETE',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token(),
          },
          credentials: 'same-origin',
          redirect: 'manual',
        })
          .then(() => {
            location.href = '/questions'
          })
          .catch((error) => {
            console.warn('Failed to parsing', error)
          })
      }
    },
  },
  computed: {
    markdownDescription: function () {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.tempDescription)
    },
    validation: function () {
      return this.tempTitle.length > 0 && this.tempDescription.length > 0
    },
    updateAtISO8601: function() {
      return moment(this.question.update_at).format();
    },
    updateAt: function () {
      return moment(this.question.update_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    editAble: function () {
      return (
        this.question.user.id === this.currentUserId ||
        this.currentUser.role === 'admin'
      )
    },
  },
}
</script>
