<template lang="pug">
draggable.draggable-items(
  v-model='practices',
  handle='.js-grab',
  @start='start',
  @end='end'
)
  .category-practices-item.js-practice(
    v-for='practice in practices',
    :key='practice.id'
  )
    a.category-practices-item__anchor
    header.category-practices-item__header
      .category-practices-item__title
        .category-practices-item__title-link
          | {{ practice.title }}
      .category-practices-item__grab
        span.a-grab.js-grab
          i.fas.fa-align-justify
</template>
<script>
import draggable from 'vuedraggable'
export default {
  components: {
    draggable
  },
  props: {
    categoriesPractices: { type: Array, required: true },
    categoryPractices: { type: Array, required: true }
  },
  data() {
    return {
      practices: this.categoryPractices,
      practicesBeforeDragging: '',
      draggingItem: ''
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    start() {
      this.practicesBeforeDragging = this.practices
    },
    end(event) {
      this.draggingItem = this.practicesBeforeDragging[event.oldIndex]
      if (event.oldIndex !== event.newIndex) {
        const params = {
          // position値は1から始まるため、インデックス番号 + 1
          position: event.newIndex + 1
        }
        const categoriesPracticeId = this.categoriesPractices.find(
          (v) => v.practice_id === this.draggingItem.id
        ).id
        fetch(
          `/api/categories_practices/position/${categoriesPracticeId}.json`,
          {
            method: 'PATCH',
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'X-Requested-With': 'XMLHttpRequest',
              'X-CSRF-Token': this.token()
            },
            credentials: 'same-origin',
            redirect: 'manual',
            body: JSON.stringify(params)
          }
        )
          .then((response) => {
            if (!response.ok) {
              this.practices = this.practicesBeforeDragging
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
