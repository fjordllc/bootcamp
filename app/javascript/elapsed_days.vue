<template lang="pug">
ol
  .elapsed-days__list(v-for='product_n_days_passed in productsGroupedByElapsedDays')
    li(
      v-if='product_n_days_passed.elapsed_days === 7',
      @click='transition(product_n_days_passed.elapsed_days)'
    )
      | {{ product_n_days_passed.elapsed_days }}日以上経過
      | ({{ countProductsGroupedBy(product_n_days_passed) }})
    li(
      v-else-if='product_n_days_passed.elapsed_days >= 1',
      @click='transition(product_n_days_passed.elapsed_days)'
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
    transition(elapsedDays) {
      this.$emit('transition', elapsedDays)
    }
  }
}
</script>
