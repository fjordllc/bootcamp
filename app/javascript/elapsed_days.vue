<template lang="pug">
ol.elapsed-days__list
  li.elapsed-days__content(
    v-for='product_n_days_passed in productsGroupedByElapsedDays',
    :key='product_n_days_passed.id'
  )
    a(v-if='product_n_days_passed.elapsed_days === 7', href='#7days-elapsed')
      | {{ product_n_days_passed.elapsed_days }}日以上経過
      | ({{ countProductsGroupedBy(product_n_days_passed) }})
    a(
      v-else-if='product_n_days_passed.elapsed_days >= 1',
      :href='elementId(product_n_days_passed.elapsed_days)'
    )
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
