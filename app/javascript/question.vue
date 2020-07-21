<template lang="pug">
  .thread__inner.a-card
    header.thread-header
      .thread-header__upper-side
        a(:href="`/users/${questionUser.id}`", class= "thread-header__author")
          | {{ questionUser.login_name }}
        .thread-header__date
          | {{ createdAt }}
      h1.thread-header__title
        | {{ question.title }}
      .thread-header__lower-side
        #js-watch(:data-watchable-id="questionId", data-watchable-type="Question")
        .thread-header__raw
          a(:href="`/questions/${question.id}.md`", class= "a-button is-sm is-secondary", target="_blank")
            | Raw
    .report-practices(v-if="question.practice")
      ul.report-practices__items
       li.report-practices__item
          a(:href="`/practices/${question.practice.id}`", class="report-practices__item-link")
            | {{ question.practice.title }}

    .thread__body
      .thread-question__body.a-card(v-if="!editing")
        .thread-question__description.js-target-blank.is-long-text(v-html="markdownDescription")
        reaction(
          :is="reaction",
          :reactionable="question",
          :currentUser="currentUser",
          :reactionableId="reactionableId")
        footer.card-footer(v-if="adminOrQuestionUser")
          .card-footer-actions
            ul.card-footer-actions__items
              li.card-footer-actions__item
                button.card-footer-actions__action.a-button.is-md.is-primary.is-block(@click="editQuestion")
                  i.fas.fa-pen
                    | 内容修正
              li.card-footer-actions__item
                button.js-delete.card-footer-actions__action.a-button.is-md.is-danger.is-block(@click="deleteQuestion")
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
                          option(v-for="practice in practices" :value="practice.id")
                            div {{ practice.option }}
              .form-item
                .row.js-markdown-parent
                  .col-md-6.col-xs-12
                    .a-label
                      | タイトル
                    input(v-model='tempTitle' name="question[title]")
              .form-item
                .thread-question-form__tabs.js-tabs
                  .thread-question-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('question')}" @click="changeActiveTab('question')")
                    | コメント
                  .thread-question-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
                    | プレビュー
                .thread-question-form__markdown-parent.js-markdown-parent
                  .thread-question-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('question')}")
                    markdown-textarea(v-model="tempDescription" :class="classQuestionId" class="a-text-input js-warning-form thread-question-form__textarea js-question-markdown" name="question[description]")
                  .thread-question-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('preview')}")
                    .js-preview.is-long-text.thread-question-form__preview(v-html="markdownDescription")
              ul.thread-question-form__actions
                li.thread-question-form__action
                  button.a-button.is-md.is-warning.is-block(@click="updateQuestion" v-bind:disabled="!validation" type="button")
                    | 更新する
                li.thread-question-form__action
                  button.a-button.is-md.is-secondary.is-block(@click="cancel" type="button")
                    | キャンセル
</template>
<script>
import Reaction from './reaction.vue'
import MarkdownTextarea from './markdown-textarea.vue'
import MarkdownIt from 'markdown-it'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItMention from './packs/markdown-it-mention'
import Watch from './watch'
import Prism from 'prismjs/components/prism-core'
import 'prism_languages'
import Tribute from 'tributejs'
import TextareaAutocomplteEmoji from 'classes/textarea-autocomplte-emoji'
import TextareaAutocomplteMention from 'classes/textarea-autocomplte-mention'
import moment from 'moment'
moment.locale('ja')

export default {
  components: {
    'markdown-textarea': MarkdownTextarea,
    'js-watch': Watch,
  },
  props: {
    currentUserId: { type: String, required: true },
    questionUserId: { type: String, required: true },
    questionId: { type: String, required: true },
    adminLogin: { type: Boolean, required: true },
  },
  data: () => {
    return {
      tempTitle: '',
      tempDescription: '',
      selectedId: '',
      editing: false,
      questions: [],
      question: [],
      practices: [],
      currentUser: {},
      questionUser: {},
      reaction: null,
      tab: 'question',
    }
  },
  computed: {
    markdownDescription: function () {
      const md = new MarkdownIt({
        html: true,
        breaks: true,
        linkify: true,
        langPrefix: 'language-',
        highlight: (str, lang) => {
          if (lang && Prism.languages[lang]) {
            try {
              return Prism.highlight(str, Prism.languages[lang], lang)
            } catch (__) {}
          }
          return ''
        },
      })
      md.use(MarkdownItEmoji).use(MarkdownItMention)
      return md.render(this.tempDescription)
    },
    classQuestionId: function () {
      return `question-id-${this.question.id}`
    },
    validation: function () {
      return this.tempDescription.length > 0
    },
    reactionableId: function () {
      return `Question_${this.question.id}`
    },
    createdAt: function () {
      return moment(this.question.created_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    adminOrQuestionUser: function () {
      return (
        this.questionUserId === this.currentUserId || this.adminLogin === true
      )
    },
  },
  async created() {
    await this.setQuestion()
    await this.setUser(this.currentUserId, this.currentUser)
    await this.setUser(this.questionUserId, this.questionUser)
    await this.setPractices()
    this.setTemporaryData()
    this.setQuestions()
    this.reaction = Reaction
  },
  mounted: function () {
    $('textarea').textareaAutoSize()
    const textareas = document.querySelectorAll(
      `.question-id-${this.question.id}`
    )
    const emoji = new TextareaAutocomplteEmoji()
    const mention = new TextareaAutocomplteMention()
    mention.fetchValues((json) => {
      mention.values = json
      const collection = [emoji.params(), mention.params()]
      const tribute = new Tribute({ collection: collection })
      tribute.attach(textareas)
    })
  },
  methods: {
    async setQuestion() {
      await fetch(`/api/questions/${this.questionId}.json`, {
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
        .then((json) => {
          this.question = json
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    async setUser(id, user) {
      await fetch(`/api/users/${id}.json`, {
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
        .then((json) => {
          for (var key in json) {
            this.$set(user, key, json[key])
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    async setPractices() {
      await fetch('/api/categories.json', {
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
        .then((json) => {
          this.categories = json
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
      await fetch('/api/practices.json', {
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
        .then((practices) => {
          this.practices = practices.map((practice) => {
            var targets = {}
            targets.id = practice.id
            targets.title = practice.title
            this.categories.forEach((category) => {
              if (category.id === practice.category_id) {
                targets.option = `[${category.name}] ${practice.title}`
              }
            })
            return targets
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    setTemporaryData() {
      this.tempTitle = this.question.title
      this.tempDescription = this.question.description
      if (this.question.practice) this.selectedId = this.question.practice.id
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
        $(`.question-id-${this.question.id}`).trigger('input')
      })
    },
    updateQuestion: function () {
      if (this.tempDescription.length < 1) {
        return null
      }
      const params = {
        question: {
          title: this.tempTitle,
          description: this.tempDescription,
          practice_id: this.selectedId,
        },
      }
      fetch(`/api/questions/${this.question.id}`, {
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
        .then((response) => {
          this.question.title = this.tempTitle
          this.question.description = this.tempDescription
          if (this.question.practice) {
            this.question.practice.id = this.selectedId
            this.question.practice.title = this.practiceTitle()
          }

          this.editing = false
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    deleteQuestion: function () {
      if (window.confirm('削除してよろしいですか？')) {
        fetch(`/api/questions/${this.question.id}.json`, {
          method: 'DELETE',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token(),
          },
          credentials: 'same-origin',
          redirect: 'manual',
        })
          .then((response) => {
            this.questions.forEach((question, i) => {
              if (question.id === this.question.id) {
                this.questions.splice(i, 1)
              }
            })
            location.href = '/questions'
          })
          .catch((error) => {
            console.warn('Failed to parsing', error)
          })
      }
    },
    setQuestions: function () {
      fetch(`/api/questions.json`, {
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
        .then((json) => {
          json.forEach((q) => {
            this.questions.push(q)
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    practiceTitle: function () {
      const practice = this.practices
        .filter((practice) => {
          return practice.id === this.selectedId
        })
        .shift()
      return practice.title
    },
  },
}
</script>
