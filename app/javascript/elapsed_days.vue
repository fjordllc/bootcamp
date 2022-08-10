<template lang="pug">
nav.page-body__column.is-sub
  .page-nav.a-card
    ol.page-nav__items.elapsed-days
      li.page-nav__item.is-reply-deadline.is-active
        a.page-nav__item-link
          | 7日以上経過 （1）
      li.page-nav__item.is-reply-alert.is-inactive
        a.page-nav__item-link
          | 6日経過 （0）
      li.page-nav__item.is-reply-warning.is-active
        a.page-nav__item-link
          | 5日経過 （1）
      li.page-nav__item.is-inactive
        a.page-nav__item-link
          | 4日経過 （0）
      li.page-nav__item.is-active
        a.page-nav__item-link
          | 3日経過 （1）
      li.page-nav__item.is-active
        a.page-nav__item-link
          | 2日経過 （1）
      li.page-nav__item.is-active
        a.page-nav__item-link
          | 今日提出 （1）

    //
      - 7日以上経過の `li` に `.is-reply-deadline` を付ける
      - 6日経過の `li` に `.is-reply-alert` を付ける
      - 5日経過の `li` に `.is-reply-warning` を付ける
      - 提出物が 0 だったら li に `.is-inactive` を付ける
      - 提出物が 1 以上だったら li に `.is-active` を付ける

    //
      ol.page-nav__items.elapsed-days
        li.page-nav__item(
          v-for='product_n_days_passed in productsGroupedByElapsedDays',
          :key='product_n_days_passed.id'
        )
          a.page-nav__item-link(class='')(v-if='product_n_days_passed.elapsed_days === 7', href='#7days-elapsed')
            span.page-nav__item-link-inner
              | {{ product_n_days_passed.elapsed_days }}日以上経過
              | ({{ countProductsGroupedBy(product_n_days_passed) }})
          a.page-nav__item-link(
            v-else-if='product_n_days_passed.elapsed_days >= 1',
            :href='elementId(product_n_days_passed.elapsed_days)'
          )
            span.page-nav__item-link-inner
              | {{ product_n_days_passed.elapsed_days }}日経過
              | ({{ countProductsGroupedBy(product_n_days_passed) }})
</template>

<script>
export default {
  props: {
    productsGroupedByElapsedDays: { type: Array, required: true },
    countProductsGroupedBy: { type: Function, required: true }
  },
  methods: {
    elementId(elapsedDays) {
      return `#${elapsedDays}days-elapsed`
    }
  }
}
</script>
