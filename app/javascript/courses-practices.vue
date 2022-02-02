<template lang="pug">
.page-body__inner.is-md(v-if='categories === null')
  coursesPracticesLoadingListPlaceholder
.page-body__inner(v-else)
  .categories-items
    .categories-items__inner
      .categories-item.practices(
        v-for='category in containsPractices',
        :key='category.id'
      )
        a.categories-item__anchor(:id='`category-${category.id}`')
        header.categories-item__header
          h2.categories-item__title
            | {{ category.name }}
            span.stamp.is-circle.is-solved(
              v-if='category.completed_all_practices === true'
            )
              | 完了
        .categories-item__description
          .categories-item__edit.is-only-mentor(v-if='isRole("admin")')
            a.categories-item__edit-link(
              :href='`${category.edit_admin_category_path}`'
            )
              i.fas.fa-pen
          .is-long-text(v-html='markdownDescription(category.description)')
        .categories-item__body
          .category-practices.js-category-practices
            courses-practice(
              v-for='practices in category.practices',
              :key='practices.id',
              :practices='practices',
              :category='category',
              :learnings='learnings',
              :currentUser='currentUser'
            )
    nav.page-nav
      ul.page-nav__items
        li.page-nav__item(
          v-for='category in containsPractices',
          :key='category.id'
        )
          a.page-nav__item-link(:href='`practices#category-${category.id}`')
            span.page-nav__item-link-inner
              | {{ category.name }}
</template>

<script>
import CoursesPractice from './courses-practice.vue'
import MarkdownInitializer from './markdown-initializer'
import role from './role'
import CoursesPracticesLoadingListPlaceholder from './courses-practices-loading-list-placeholder'

export default {
  components: {
    'courses-practice': CoursesPractice,
    coursesPracticesLoadingListPlaceholder:
      CoursesPracticesLoadingListPlaceholder
  },
  mixins: [role],
  props: {
    courseId: { type: String, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      categories: null,
      learnings: null
    }
  },
  computed: {
    markdownDescription: function () {
      const markdownInitializer = new MarkdownInitializer()
      return function (description) {
        return markdownInitializer.render(description)
      }
    },
    url() {
      return `/api/courses/${this.courseId}/practices`
    },
    containsPractices() {
      if (!this.categories) return null
      return this.categories.filter((value) => value.practices.length)
    }
  },
  created() {
    this.getCoursesPractices()
  },
  methods: {
    getCoursesPractices() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.categories = []
          json.categories.forEach((r) => {
            this.categories.push(r)
          })
          this.learnings = json.learnings
        })
        .then(() => {
          const count = location.href.search('#')
          const hash = location.href.slice(count + 1)
          const element = document.getElementById(hash)
          if (element) {
            element.scrollIntoView()
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    }
  }
}
</script>
