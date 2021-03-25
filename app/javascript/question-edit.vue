<template lang="pug">
.thread
  userIcon(:user="question.user", threadClassSuffix="")
  .thread__inner.a-card
    header.thread-header
      .thread-header__upper-side
        a.thread-header__author(:href="`/users/${question.user.id}`")
          | {{ question.user.login_name }}
        .thread-header__date
          time.thread_header_date-value(
            :datetime="updatedAtISO8601",
            pubdate="pubdate"
          )
            | {{ updatedAt }}
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
        watch(:watchableId="question.id", watchableType="Question")
        .thread-header__raw
          a.a-button.is-sm.is-secondary(
            :href="`/questions/${question.id}.md`",
            target="_blank"
          )
            | Raw
    .thread__tags
      tags(
        :tagsInitialValue="question.tag_list",
        :questionId="question.id",
        tagsParamName="question[tag_list]",
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
          :reactionableId="`Question_${this.question.id}`"
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
                      .select-practices(v-if="practices === null")
                        .empty
                          .fas.fa-spinner.fa-pulse
                          | ロード中
                      .select-practices(v-else)
                        select(v-model="edited.practiceId")
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
                    input(v-model="edited.title", name="question[title]")
              .form-item
                .thread-question-form__tabs.js-tabs
                  .thread-question-form__tab.js-tabs__tab(
                    :class="{ 'is-active': isActive('question') }",
                    @click="changeActiveTab('question')"
                  )
                    | コメント
                  .thread-question-form__tab.js-tabs__tab(
                    :class="{ 'is-active': isActive('preview') }",
                    @click="changeActiveTab('preview')"
                  )
                    | プレビュー
                .thread-question-form__markdown-parent.js-markdown-parent
                  .thread-question-form__markdown.js-tabs__content(
                    :class="{ 'is-active': isActive('question') }"
                  )
                    textarea#js-question-content.a-text-input.js-warning-form.thread-question-form__textarea(
                      v-model="edited.description",
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
                    :disabled="!validation",
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
import UserIcon from './user-icon.vue'
import moment from 'moment'
moment.locale('ja')

export default {
  components: {
    watch: Watch,
    tags: Tags,
    reaction: Reaction,
    userIcon: UserIcon,
  },
  props: {
    initialQuestion: { type: Object, required: true },
    currentUser: { type: Object, required: true },
  },
  data: () => {
    return {
      edited: {
        title: '',
        description: '',
        practiceId: ''
      },
      editing: false,
      question: null,
      practices: null,
      tab: 'question',
    }
  },
  created() {
    this.question = this.initialQuestion
    this.setEditedData()
    this.fetchPractices(this.question.user.id)
  },
  mounted() {
    TextareaInitializer.initialize(`#js-question-content`)
  },
  methods: {
    fetchPractices(userId) {
      fetch(`/api/practices.json?user_id=${userId}`, {
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
            practice.categoryAndPracticeName = `[${practice.category}] ${practice.title}`
            return practice
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    setEditedData() {
      ['title', 'description'].forEach(key => {
        this.edited[key] = this.question[key]
      })

      const { practice } = this.question
      if (practice !== undefined) {
        this.edited['practiceId'] = practice.id
      }
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
      this.setEditedData()
      this.editing = false
    },
    editQuestion: function () {
      this.editing = true
      this.$nextTick(function () {
        $(`.question-id-${this.question.id}`).trigger('input')
      })
    },
    updateQuestion: function () {
      const { title, description, practiceId } = this.edited
      const params = {
        question: {
          title,
          description,
          practice_id: practiceId
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
        .then(() => {
          ['title', 'description'].forEach(key => {
            this.question[key] = this.edited[key]
          })

          const { practice } = this.question
          if (practice !== undefined) {
            practice.id = this.edited.practiceId
            // find(practice  だと const { practice } と
            // 重複するので利用していない
            practice.title = this.practices.find(
              (obj) => obj.id === practice.id
            ).title
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
      return markdownInitializer.render(this.edited.description)
    },
    validation: function () {
      const { title, description } = this.edited
      return title.length > 0 && description.length > 0
    },
    updatedAtISO8601: function() {
      return moment(this.question.updated_at).format();
    },
    updatedAt: function () {
      return moment(this.question.updated_at).format(
        "YYYY年MM月DD日(dd) HH:mm"
      )
    },
    editAble: function () {
      return (
        this.question.user.id === this.currentUser.id ||
        this.currentUser.role === 'admin'
      )
    },
  },
}
</script>
