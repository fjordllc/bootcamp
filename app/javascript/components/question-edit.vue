<template lang="pug">
.question.page-content
  header.page-content-header
    .page-content-header__start
      .page-content-header__user
        userIcon(:user='question.user', blockClassSuffix='page-content-header')
    .page-content-header__end
      a.a-count-badge(href='#comments')
        .a-count-badge__label
          | 回答
        .a-count-badge__value.is-counting(v-if='!isAnswerCountUpdated')
          i.fa-solid.fa-spinner
        .a-count-badge__value(:class='answerCount === 0 ? "is-zero" : ""')
          | {{ answerCount }}

      .page-content-header__row
        .page-content-header__before-title
          a.a-category-link(
            :href='`/practices/${practiceId}`',
            v-if='practiceId !== null')
            | {{ practiceTitle }}
        h1.page-content-header__title(:class='question.wip ? "is-wip" : ""')
          span.a-title-label.is-solved.is-success(
            v-if='question.correct_answer !== null')
            | 解決済
          span.a-title-label.is-wip(v-else-if='question.wip')
            | WIP
          span.a-title-label.is-solved.is-danger(v-else)
            | 未解決
          | {{ title }}

      .page-content-header__row
        .page-content-header-metas
          .page-content-header-metas__start
            .page-content-header-metas__meta(v-if='question.wip')
              .a-meta
                span.a-meta__value
                  | 質問作成中
            .page-content-header-metas__meta
              a.a-user-name(:href='`/users/${question.user.id}`')
                | {{ question.user.long_name }}
            .page-content-header-metas__meta(v-if='!question.wip')
              time.a-meta
                span.a-meta__label
                  | 公開
                span.a-meta__value
                  | {{ publishedAt }}
            .page-content-header-metas__meta(v-if='!question.wip')
              .a-meta
                span.a-meta__label
                  | 更新
                time.a-meta__value
                  | {{ updatedAt }}

      .page-content-header__row
        .page-content-header-actions
          .page-content-header-actions__start
            .page-content-header-actions__action
              WatchToggle(:watchableId='question.id', watchableType='Question')
            .page-content-header-actions__action
              BookmarkButton(
                :bookmarkableId='question.id',
                bookmarkableType='Question')
          .page-content-header-actions__end
            .page-content-header-actions__action
              a.a-button.is-sm.is-secondary.is-block(
                :href='`/questions/${question.id}.md`',
                target='_blank')
                | Raw

      .page-content-header__row
        .page-content-header__tags
          tags(
            :tagsInitialValue='question.tag_list.join(",")',
            :tagsTypeId='String(question.id)',
            tagsParamName='question[tag_list]',
            tagsType='Question',
            :tagsEditable='true')

  .a-card(v-if='!editing')
    .card-body
      .card__description
        .a-long-text.is-md(v-html='markdownDescription')
    reaction(
      :reactionable='question',
      :currentUser='currentUser',
      :reactionableId='`Question_${question.id}`')
    hr.a-border-tint
    footer.card-footer(
      v-if='currentUser.id === question.user.id || isRole("mentor")')
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item
            button.card-main-actions__action.a-button.is-sm.is-secondary.is-block(
              @click='startEditing')
              i#new.fa-solid.fa-pen
              | 内容修正
          li.card-main-actions__item.is-sub.is-only-mentor(
            v-if='isRole("mentor")')
            // - vue.jsでDELETE methodのリンクを作成する方法が、
            // - 見つからなかったので、
            // - いい実装方法ではないが、
            // - Rails特定の属性(data-confirm, data-method)を付与して、
            // - 確認ダイアログとDELETE methodのリンクを実装する
            a.js-delete.card-main-actions__muted-action(
              :href='`/questions/${question.id}`',
              data-confirm='自己解決した場合は削除せずに回答を書き込んでください。本当に削除しますか？',
              data-method='delete')
              | 削除する
          li.card-main-actions__item.is-sub(v-else)
            label.card-main-actions__muted-action(for='modal-delete-request')
              | 削除申請
        .card-footer__notice(v-show='displayedUpdateMessage')
          p
            | 質問を更新しました

  .a-card(v-show='editing')
    .thread-form
      form.form(name='question')
        .form__items
          .form-item
            label.a-form-label
              | プラクティス
            .select-practices(v-if='practices === null')
              .empty
                .fa-solid.fa-spinner.fa-pulse
                | ロード中
            .select-practices(v-show='practices !== null')
              select#js-choices-single-select(
                v-model='edited.practiceId',
                name='question[practice]')
                option(value='')
                  | プラクティス選択なし
                option(
                  v-for='practice in practices',
                  :key='practice.id',
                  :value='practice.id') {{ practice.title }}
          .form-item
            .a-form-label
              | タイトル
            input.a-text-input(v-model='edited.title', name='question[title]')
          .form-item
            .form-tabs.js-tabs
              .form-tabs__tab.js-tabs__tab(
                :class='{ "is-active": isActive("question") }',
                @click='changeActiveTab("question")')
                | 質問文
              .form-tabs__tab.js-tabs__tab(
                :class='{ "is-active": isActive("preview") }',
                @click='changeActiveTab("preview")')
                | プレビュー
            .a-markdown-parent.js-markdown-parent
              .a-markdown-input__inner.js-tabs__content(
                v-bind:class='{ "is-active": isActive("question") }')
                .form-textarea
                  .form-textarea__body
                    textarea#js-question-content.a-text-input.form-tabs-item__textarea(
                      v-model='edited.description',
                      data-preview='#js-question-preview',
                      data-input='.js-question-file-input',
                      name='question[description]')
                  .form-textarea__footer
                    .form-textarea__insert
                      label.a-file-insert.a-button.is-xs.is-text-reversal.is-block
                        | ファイルを挿入
                        input.js-question-file-input(type='file', multiple)
              .form-tabs-item__markdown.js-tabs__content(
                :class='{ "is-active": isActive("preview") }')
                #js-question-preview.js-preview.a-long-text.is-md.form-tabs-item__preview

        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item
              button.a-button.is-sm.is-secondary.is-block(
                @click='updateQuestion(true)',
                :disabled='!validation',
                type='button')
                | WIP
            li.card-main-actions__item
              button.a-button.is-sm.is-primary.is-block(
                v-if='question.wip',
                @click='updateQuestion(false)',
                :disabled='!validation',
                type='button')
                | 質問を公開
              button.a-button.is-sm.is-primary.is-block(
                v-else,
                @click='updateQuestion(false)',
                :disabled='!validation',
                type='button')
                | 更新する
            li.card-main-actions__item.is-sub
              button.card-main-actions__muted-action(
                @click='cancel',
                type='button')
                | キャンセル
</template>
<script>
import CSRF from 'csrf'
import Reaction from 'reaction.vue'
import WatchToggle from './watch-toggle.vue'
import BookmarkButton from 'bookmark-button.vue'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import Tags from 'tags.vue'
import UserIcon from 'user-icon.vue'
import confirmUnload from 'confirm-unload'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import role from 'role'
import Choices from 'choices.js'
dayjs.locale(ja)

export default {
  name: 'QuestionEdit',
  components: {
    WatchToggle: WatchToggle,
    BookmarkButton: BookmarkButton,
    tags: Tags,
    reaction: Reaction,
    userIcon: UserIcon
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
      practiceId: this.getPracticeId(),
      edited: {
        title: this.question.title,
        description: this.question.description,
        practiceId: this.getPracticeId()
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
      if (
        this.practiceId === '' ||
        this.practiceId === undefined ||
        this.practiceId === null
      ) {
        return ''
      } else {
        const { practices, question, practiceId } = this

        return practices === null
          ? question.practice.title
          : practices.find((practice) => practice.id === Number(practiceId))
              .title
      }
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
    getPracticeId() {
      return this.question.practice === undefined
        ? null
        : this.question.practice.id
    },
    fetchPractices() {
      fetch('/api/practices.json?scoped_by_user=true', {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((practices) => {
          this.practices = practices
        })
        .then(() => {
          const choices = document.getElementById('js-choices-single-select')
          if (choices) {
            return new Choices(choices, {
              removeItemButton: true,
              allowHTML: true,
              searchResultLimit: 20,
              searchPlaceholderValue: '検索ワード',
              noResultsText: '一致する情報は見つかりません',
              itemSelectText: '選択',
              shouldSort: false
            })
          }
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
    isChangedPracticeId(edited) {
      return Object.entries(edited.practiceId).some(([key, val]) => {
        return val !== this[key]
      })
    },
    updateQuestion(wip) {
      const flashElement = document.querySelector('.flash__message')
      if (flashElement) {
        flashElement.innerHTML = wip
          ? '質問をWIPとして保存しました。'
          : '質問を公開しました。'
      }

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
          'X-CSRF-Token': CSRF.getToken()
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
        .then(() => {
          if (this.isChangedPracticeId(this.edited)) {
            location.href = `/questions/${this.question.id}`
          }
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
