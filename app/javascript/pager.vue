<template lang="pug">
pager(
  :value='initialPageNumber',
  :page-count='pageCount',
  :page-range='pageRange',
  :prev-text='makeITag("left")',
  :next-text='makeITag("right")',
  :click-handler='clickHandle',
  :first-button-text='makeITag("double-left")',
  :last-button-text='makeITag("double-right")',
  :margin-pages='0',
  first-last-button,
  hide-prev-next,
  container-class='o-pagination__items',
  page-class='o-pagination__item',
  page-link-class='o-pagination__item-link',
  prev-class='o-pagination__item is-prev',
  prev-link-class='o-pagination__item-link is-prev',
  next-class='o-pagination__item is-next',
  next-link-class='o-pagination__item-link is-next',
  active-class='is-active',
  disabled-class='is-disabled'
)
</template>

<script>
import VuejsPaginate from 'vuejs-paginate'

export default {
  components: {
    pager: VuejsPaginate
  },
  props: {
    initialPageNumber: { type: Number, required: true },
    pageCount: { type: Number, required: true },
    pageRange: { type: Number, required: true },
    clickHandle: { type: Function, required: true }
  },
  methods: {
    makeITag(iconName) {
      return `<i class='fas fa-angle-${iconName}'></i>`
    }
  }
}
</script>
