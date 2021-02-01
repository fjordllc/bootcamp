<template lang="pug">
draggable.draggable-items(v-model='practices', handle=".grab", @start="start", @end="end")
  .category-practices-item.js-practice(
    v-for="practice in practices"
    :key="practice.id")
    a.category-practices-item__anchor
    header.category-practices-item__header
      .category-practices-item__title
        .category-practices-item__title-link
          | {{ practice.title }}
      span.grab
        i.fas.fa-align-justify
  .category-practices-item__handle.js-show-handle__target
</template>
<script>
import draggable from 'vuedraggable'
export default {
  props: ['categoriesPractices','categoryPractices'],
  data () {
    return {
      combinations: JSON.parse(this.categoriesPractices),
      practices: JSON.parse(this.categoryPractices),
      practicesBeforeDragging: '',
      draggingItem: ''
    }
  },
  components: {
    draggable
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    start () {
      this.practicesBeforeDragging = this.practices
    },
    end (event) {
      this.draggingItem = this.practicesBeforeDragging[event.oldIndex]
      if (event.oldIndex !== event.newIndex) {
        const params = {
          // position値は1から始まるため、インデックス番号 + 1
          'position': event.newIndex + 1
        }
        const categoriesPracticeId = (this.combinations.find((v) => v.practice_id === this.draggingItem.id)).id
        fetch(`/api/categories_practices/position/${categoriesPracticeId}.json`, {
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
            .then(response => {
              if (!response.ok) {
                this.practices = this.practicesBeforeDragging
              }
            })
            .catch(error => {
              console.warn('Failed to parsing', error)
            })
      }
    }
  }
}
</script>
