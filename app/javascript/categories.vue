<template lang="pug">
  .container.is-padding-horizontal-0-sm-down
    .admin-table
      table.admin-table__table
        thead.admin-table__header
          tr.admin-table__labels
            th.admin-table__label
              | 名前
            th.admin-table__label
              | URLスラッグ
            th.admin-table__label.actions
              | 操作
            th.admin-table__label.handle
              | 並び順
        draggable.admin-table__items(v-model="categories", handle='.grab', tag="tbody", @start="start", @end="end")
          tr.admin-table__item(
            v-for="category in categories"
            :key="category.id"
            @dragstart="dragstart(category)")
            td.admin-table__item-value
              | {{ category.name }}
            td.admin-table__item-value
              | {{ category.slug }}
            td.admin-table__item-value.is-text-align-center
              ul.is-button-group
                li
                  a.a-button.is-sm.is-primary.is-icon(:href='`/admin/categories/${category.id}/edit`')
                    i.fas.fa-pen
                li
                  a.a-button.is-sm.is-danger.is-icon.js-delete(@click='destroy(category)')
                    i.fas.fa-trash-alt
            td.admin-table__item-value.is-text-align-center
              span.grab
                i.fas.fa-align-justify
</template>
<script>
import draggable from 'vuedraggable'

export default {
  props: ['allCategories'],
  data () {
    return {
      categories: JSON.parse(this.allCategories),
      beforeDragging: '',
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
      this.beforeDragging = this.categories
    },
    dragstart (category) {
      this.draggingItem = category
    },
    end (e) {
      if (e.oldIndex !== e.newIndex) {
        // position値は1から始まるため、インデックス番号 + 1
        const params = {
          'position': e.newIndex + 1
        }
        fetch(`/api/categories/${this.draggingItem.id}/position.json`, {
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
              this.categories = this.beforeDragging
            }
          })
          .catch(error => {
            console.warn('Failed to parsing', error)
          })
      }
    },
    destroy (category) {
      if (window.confirm('本当によろしいですか？')) {
        fetch(`/api/categories/${category.id}.json`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        })
          .then(response => {
            if (response.ok) {
              this.categories = this.categories.filter(v => v.id !== category.id)
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
