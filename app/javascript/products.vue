<template lang="pug">
.page-content.is-products(v-if='!loaded')
  div
    loadingListPlaceholder

//- ダッシュボード
.is-vue(v-else-if='isDashboard')
  template(v-for='product_n_days_passed in filteredProducts') <!-- product_n_days_passedはn日経過の提出物 -->
    .a-card.h-auto(
      v-if='!isDashboard || (isDashboard && product_n_days_passed.elapsed_days >= 0 && product_n_days_passed.elapsed_days <= selectedDays + 2)')
      //- TODO 以下を共通化する
      //- prettier-ignore: need space between v-if and id
      header.card-header.a-elapsed-days(
        v-if='product_n_days_passed.elapsed_days === 0', id='0days-elapsed'
      )
        h2.card-header__title
          | 今日提出
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id            
      header.card-header.a-elapsed-days.is-reply-warning(
        v-else-if='product_n_days_passed.elapsed_days === selectedDays', id='first-alert'
      )
        h2.card-header__title
          | {{ selectedDays }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-alert(
        v-else-if='product_n_days_passed.elapsed_days === selectedDays + 1', id='second-alert'
      )
        h2.card-header__title
          | {{ selectedDays + 1 }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-deadline(
        v-else-if='product_n_days_passed.elapsed_days === selectedDays + 2', id='deadline-alert'
      )
        h2.card-header__title
          | {{ selectedDays + 2 }}日以上経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      header.card-header.a-elapsed-days(
        v-else,
        :id='elapsedDaysId(product_n_days_passed.elapsed_days)')
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- 共通化ここまで
      .card-list
        .card-list__items
          product(
            v-for='product in product_n_days_passed.products',
            :key='product.id',
            :product='product',
            :currentUserId='currentUserId',
            :isMentor='isMentor',
            :display-user-icon='displayUserIcon')

  .under-cards
    .under-cards__links.mt-4.text-center.leading-normal.text-sm
      a.divide-indigo-800.block.p-3.border.rounded.border-solid.text-indigo-800.a-hover-link(
        class='hover\:bg-black',
        v-bind:href='`/products/unassigned#${selectedDays - 1}days-elapsed`',
        v-if='filteredProducts.length === 0 && countAlmostPassedSelectedDays() === 0')
        | しばらく{{ selectedDays }}日経過に到達する<br>提出物はありません。
      a.divide-indigo-800.block.p-3.border.rounded.border-solid.text-indigo-800.a-hover-link(
        class='hover\:bg-black',
        v-bind:href='`/products/unassigned#${selectedDays - 1}days-elapsed`',
        v-else-if='countAlmostPassedSelectedDays() > 0')
        | <strong>{{ countAlmostPassedSelectedDays() }}件</strong>の提出物が、<br>8時間以内に{{ selectedDays }}日経過に到達します。
      a.divide-indigo-800.block.p-3.border.rounded.border-solid.text-indigo-800.a-hover-link(
        class='hover\:bg-black',
        v-bind:href='`/products/unassigned#${selectedDays - 1}days-elapsed`',
        v-else)
        | しばらく{{ selectedDays }}日経過に到達する<br>提出物はありません。        
</template>

<script>
import CSRF from 'csrf'
import Product from 'product.vue'
import LoadingListPlaceholder from 'loading-list-placeholder.vue'

export default {
  components: {
    product: Product,
    loadingListPlaceholder: LoadingListPlaceholder
  },
  props: {
    title: { type: String, required: true },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: Number, required: true },
    displayUserIcon: { type: Boolean, default: true },
    productDeadlineDays: { type: Number, required: true }
  },
  data() {
    return {
      products: [],
      loaded: false,
      productsGroupedByElapsedDays: null,
      selectedDays: this.productDeadlineDays
    }
  },
  computed: {
    filteredProducts() {
      if (!this.productsGroupedByElapsedDays) {
        return []
      }
      return this.productsGroupedByElapsedDays.filter(group => {
        return group.elapsed_days === this.selectedDays ||
               group.elapsed_days === this.selectedDays + 1 ||
               group.elapsed_days === this.selectedDays + 2
      })
    },
    url() {
      return '/api/products/unassigned'
    },
    isDashboard() {
      return location.pathname === '/'
    },
    isNotProductSelectedDaysElapsed() {
      const elapsedDays = []
      this.productsGroupedByElapsedDays.forEach((h) => {
        elapsedDays.push(h.elapsed_days)
      })
      return elapsedDays.every((day) => day < this.selectedDays)
    }
  },
  created() {
    window.onpopstate = () => {
      this.getProductsPerPage()
    }
    this.getProductsPerPage()
  },
  methods: {
    async getProductsPerPage() {
      try {
        const response = await fetch(this.url, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        })

        const json = await response.json()
        if (
          ['/products/unassigned', '/products/unchecked', '/'].includes(
            location.pathname
          )
        ) {
          const newGroups = json.products_grouped_by_elapsed_days.reduce(
            (newGroups, group) => {
              const elapsedDays =
                group.elapsed_days >= this.selectedDays + 2
                  ? this.selectedDays + 2
                  : group.elapsed_days

              let existingGroup = newGroups.find(
                (g) => g.elapsed_days === elapsedDays
              )
              if (!existingGroup) {
                existingGroup = { elapsed_days: elapsedDays, products: [] }
                newGroups.push(existingGroup)
              }
              existingGroup.products = existingGroup.products.concat(
                group.products
              )
              return newGroups
            },
            []
          )

          this.productsGroupedByElapsedDays = newGroups
        }

        this.totalPages = json.total_pages
        this.products = json.products
        this.loaded = true

        const hash = location.hash.slice(1)
        const element = document.getElementById(hash)
        if (element) {
          element.scrollIntoView()
        }
      } catch (error) {
        console.warn(error)
      }
    },
    onDaysSelectChange(event) {
      const newDeadlineDays = parseInt(event.target.value)
      this.updateProductDeadline(newDeadlineDays)
      this.selectedDays = newDeadlineDays
      this.getProductsPerPage()
    },
    async updateProductDeadline(newDeadlineDays) {
      try {
        const response = await fetch('/product_deadline', {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin',
          body: JSON.stringify({ alert_day: newDeadlineDays })
        })
        if (!response.ok) {
          throw new Error('Failed to update product deadline')
        }
      } catch (error) {
        console.warn(error)
      }
    },
    getElementNdaysPassed(elapsedDays) {
      const element = this.productsGroupedByElapsedDays.find(
        (el) => el.elapsed_days === elapsedDays
      )
      return element
    },
    countProductsGroupedBy({ elapsed_days: elapsedDays }) {
      const element = this.getElementNdaysPassed(elapsedDays)
      return element === undefined ? 0 : element.products.length
    },
    elapsedDaysId(elapsedDays) {
      return `${elapsedDays}days-elapsed`
    },
    PassedAlmostSelectedDaysProducts(products) {
      const productsPassedAlmostSelectedDays = products.filter((product) => {
        const thresholdDay = this.selectedDays
        const thresholdHour = 8
        return (
          Math.floor((thresholdDay - this.elapsedTimes(product)) * 24) <=
          thresholdHour
        )
      })
      return productsPassedAlmostSelectedDays
    },
    elapsedTimes(product) {
      const lastSubmittedTime =
        product.published_at_date_time || product.created_at_date_time
      return (new Date() - new Date(lastSubmittedTime)) / 1000 / 60 / 60 / 24
    },
    countAlmostPassedSelectedDays() {
      if (!this.productsGroupedByElapsedDays) {
        return 0
      }

      const previousDaysElement = this.getElementNdaysPassed(
        this.selectedDays - 1
      )
      if (!previousDaysElement) {
        return 0
      }

      return this.PassedAlmostSelectedDaysProducts(previousDaysElement.products)
        .length
    }
  }
}
</script>
