<template lang="pug">
nav.page-nav.has-footer.page-nav.has-footer
  header.page-nav__header
    h2.page-nav__title
      a.page-nav__title-link(
        v-if="questionPracticeTitle",
        :href='`/practices/${questionPracticeId}`')
          | {{ this.questionPracticeTitle }}
      .page-nav__title-link(v-else)
        | 関連プラクティス無し
  ul.page-nav__items
    li.page-nav__item(v-for="question in questions",
      :key="question.id",
      :class="{'is-current': (question.title === questionTitle)}")
      a.page-nav__item-link.has-metas(
        :href='`/questions/${question.id}`'
      )
        | {{question.title}}
      .page-nav__item-link-inner
        .page-nav__item-header
          .a-badge.is-danger.is-xs(v-if='question.has_correct_answer === false')
            | 未解決
          .page-nav__item-title
            | {{ question.title }}
        .page-nav-metas
          time.page-nav-metas__item
            | 公開: {{publishedAt(question.published_at)}}
          .page-nav-metas__item
            | 回答・コメント: {{question.answers.size}}
</template>

<script>
import dayjs from "dayjs";

export default {
  name: 'NavQuestions',
  props: {
    questionPracticeTitle: {type: String, required: true},
    questionPracticeId: {type: String, required: true},
    questionTitle: {type: String, required: true}
  },
  data() {
    return {
      questions: [],
      currentPage: this.getCurrentPage(),
      loaded: false
    }
  },
  computed: {
    url() {
      const params = new URL(location.href).searchParams
      params.set('page', this.currentPage)
      return `/api/questions?${params}`
    },
  },
  created() {
    window.onpopstate = () => {
      this.currentPage = this.getCurrentPage()
      this.getQuestions()
    }
      this.getQuestions()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    publishedAt(publishedAt) {
      return dayjs(publishedAt).format(
        'YYYY年MM月DD日(dd) HH:mm'
      )
    },
    getQuestions() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => response.json())
        .then((json) => {
          this.questions = json.questions
          this.loaded = true
          console.log(this.questions)
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getCurrentPage() {
      const params = new URLSearchParams(location.search)
      const page = params.get('page')
      return parseInt(page) || 1
    },
  },
}
</script>
