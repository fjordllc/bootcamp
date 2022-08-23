<template lang="pug">
nav.page-body__column.is-sub
  .page-nav.a-card
    ol.page-nav__items.elapsed-days
      li.page-nav__item.is-reply-deadline(
        :class='activeClass(countProductsByElapsedDays(7))'
      )
        a.page-nav__item-link(href='#7days-elapsed')
          span.page-nav__item-link-inner
            | 7日以上経過
            | ({{ countProductsByElapsedDays(7) }})
      li.page-nav__item.is-reply-alert(
        :class='activeClass(countProductsByElapsedDays(6))'
      )
        a.page-nav__item-link(href='#6days-elapsed')
          span.page-nav__item-link-inner
            | 6日経過
            | ({{ countProductsByElapsedDays(6) }})
      li.page-nav__item.is-reply-warning(
        :class='activeClass(countProductsByElapsedDays(5))'
      )
        a.page-nav__item-link(href='#5days-elapsed')
          span.page-nav__item-link-inner
            | 5日経過
            | ({{ countProductsByElapsedDays(5) }})
      li.page-nav__item(
        v-for='passedDay in [4, 3, 2, 1]',
        :class='activeClass(countProductsByElapsedDays(passedDay))'
      )
        a.page-nav__item-link(:href='"#" + passedDay + "days-elapsed"')
          span.page-nav__item-link-inner
            | {{ passedDay }}日経過
            | ({{ countProductsByElapsedDays(passedDay) }})
      li.page-nav__item(:class='activeClass(countProductsByElapsedDays(0))')
        a.page-nav__item-link(href='#0days-elapsed')
          span.page-nav__item-link-inner
            | 今日提出
            | ({{ countProductsByElapsedDays(0) }})
</template>

<script>
export default {
  props: {
    productsGroupedByElapsedDays: { type: Array, required: true },
    countProductsGroupedBy: { type: Function, required: true }
  },
  methods: {
    countProductsByElapsedDays(elapsedDays) {
      const productsGroup = this.productsGroupedByElapsedDays.find(
        (product) => product.elapsed_days === elapsedDays
      )
      if (productsGroup) return this.countProductsGroupedBy(productsGroup)
      return this.countProductsGroupedBy(0)
    },
    activeClass(quantity) {
      if (quantity) return `is-active`
      return `is-inactive`
    }
  }
}
</script>
