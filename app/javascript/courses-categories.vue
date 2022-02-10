<template lang="pug">
.admin-table.is-grab
  table.admin-table__table
    thead.admin-table__header
      tr.admin-table__labels
        th.admin-table__label
          | 名前
        th.admin-table__label
          | URLスラッグ
        th.admin-table__label.handle
          | 並び順
    draggable.admin-table__items(
      v-model='coursesCategories',
      handle='.js-grab',
      tag='tbody',
      @start='start',
      @end='end'
    )
      tr.admin-table__item(
        v-for='coursesCategory in coursesCategories',
        :key='coursesCategory.id'
      )
        td.admin-table__item-value
          | {{ coursesCategory.category.name }}
        td.admin-table__item-value
          | {{ coursesCategory.slug }}
        td.admin-table__item-value.is-text-align-center.is-grab
          span.js-grab.a-grab
            i.fas.fa-align-justify
</template>
<script>
import draggable from 'vuedraggable'

export default {
  components: {
    draggable
  },
  props: {
    allCoursesCategories: { type: String, required: true }
  },
  data() {
    return {
      coursesCategories: JSON.parse(this.allCoursesCategories),
      coursesCategoriesBeforeDragging: '',
      draggingItem: ''
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    start() {
      this.coursesCategoriesBeforeDragging = this.coursesCategories
    },
    end(event) {
      this.draggingItem = this.coursesCategoriesBeforeDragging[event.oldIndex]
      if (event.oldIndex !== event.newIndex) {
        const params = {
          // position値は1から始まるため、インデックス番号 + 1
          position: event.newIndex + 1
        }
        fetch(`/api/courses_categories/${this.draggingItem.id}/position.json`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual',
          body: JSON.stringify(params)
        })
          .then((response) => {
            if (!response.ok) {
              this.coursesCategories = this.coursesCategoriesBeforeDragging
            }
          })
          .catch((error) => {
            console.warn(error)
          })
      }
    }
  }
}
</script>
