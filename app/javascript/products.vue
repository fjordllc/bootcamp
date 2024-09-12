<template lang="pug">
.page-content.is-products(v-if='!loaded')
  div
    loadingListPlaceholder

.o-empty-message(v-else-if='products.length === 0')
  .o-empty-message__icon
    i.fa-regular.fa-smile
  p.o-empty-message__text
    | {{ title }}はありません

.o-empty-message(v-else-if='isDashboard && isNotProduct5daysElapsed')
  .o-empty-message__icon
    i.fa-regular.fa-smile
  p.o-empty-message__text
    | 5日経過した提出物はありません

//- ダッシュボード
.is-vue(v-else-if='isDashboard')
  template(v-if='traineeProductsEndDateWithin7Days.length > 0')
    .a-card.h-auto
      header.card-header
        h2.card-header__title
          | 研修終了日が7日以内
          span.card-header__count ({{ traineeProductsEndDateWithin7Days.length }})

      .card-list
        .card-list__items
          product(
            v-for='product in traineeProductsEndDateWithin7Days',
            :key='product.id',
            :product='product',
            :currentUserId='currentUserId',
            :isMentor='isMentor',
            :display-user-icon='displayUserIcon')

  template(v-for='product_n_days_passed in productsGroupedByElapsedDays') <!-- product_n_days_passedはn日経過の提出物 -->
    .a-card.h-auto(
      v-if='!isDashboard || (isDashboard && product_n_days_passed.elapsed_days >= 5)')
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
        v-else-if='product_n_days_passed.elapsed_days === 5', id='5days-elapsed'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-alert(
        v-else-if='product_n_days_passed.elapsed_days === 6', id='6days-elapsed'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-deadline(
        v-else-if='product_n_days_passed.elapsed_days === 7', id='7days-elapsed'
      )
        h2.card-header__title
          | {{ product_n_days_passed.elapsed_days }}日以上経過
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
        href='/products/unassigned#4days-elapsed',
        v-if='countAlmostPassed5days() === 0')
        | しばらく5日経過に到達する<br>提出物はありません。
      a.divide-indigo-800.block.p-3.border.rounded.border-solid.text-indigo-800.a-hover-link(
        class='hover\:bg-black',
        href='/products/unassigned#4days-elapsed',
        v-else)
        | <strong>{{ countAlmostPassed5days() }}件</strong>の提出物が、<br>8時間以内に5日経過に到達します。
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
    displayUserIcon: { type: Boolean, default: true }
  },
  data() {
    return {
      products: [],
      loaded: false,
      productsGroupedByElapsedDays: null,
      traineeProductsEndDateWithin7Days: []
    }
  },
  computed: {
    url() {
      return '/api/products/unassigned'
    },
    isDashboard() {
      return location.pathname === '/'
    },
    isNotProduct5daysElapsed() {
      const elapsedDays = []
      this.productsGroupedByElapsedDays.forEach((h) => {
        elapsedDays.push(h.elapsed_days)
      })
      return elapsedDays.every((day) => day < 5)
    }
  },
  created() {
    window.onpopstate = () => {
      this.getProductsPerPage()
    }
    this.getProductsPerPage()
  },
  methods: {
    getProductsPerPage() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (location.pathname === '/') {
            this.productsGroupedByElapsedDays =
              json.products_grouped_by_elapsed_days
          }
          this.products = []
          json.products.forEach((product) => {
            this.products.push(product)
            if (
              product.user.training_remaining_days >= 0 &&
              product.user.training_remaining_days <= 7
            ) {
              this.traineeProductsEndDateWithin7Days.push(product)
            }
          })
          this.loaded = true
        })
        .then(() => {
          const hash = location.hash.slice(1)
          const element = document.getElementById(hash)
          if (element) {
            element.scrollIntoView()
          }
        })
        .catch((error) => {
          console.warn(error)
        })
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
    PassedAlmost5daysProducts(products) {
      const productsPassedAlmost5days = products.filter((product) => {
        const thresholdDay = 5
        const thresholdHour = 8
        return (
          Math.floor((thresholdDay - this.elapsedTimes(product)) * 24) <=
          thresholdHour
        )
      })
      return productsPassedAlmost5days
    },
    elapsedTimes(product) {
      const lastSubmittedTime =
        product.published_at_date_time || product.created_at_date_time
      return (new Date() - new Date(lastSubmittedTime)) / 1000 / 60 / 60 / 24
    },
    countAlmostPassed5days() {
      const elementPassed4days =
        this.productsGroupedByElapsedDays === null
          ? undefined
          : this.getElementNdaysPassed(4)
      return elementPassed4days === undefined
        ? 0
        : this.PassedAlmost5daysProducts(elementPassed4days.products).length
    }
  }
}
</script>
