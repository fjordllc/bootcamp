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
    | {{ selectedDays }}日経過した提出物はありません

//- ダッシュボード
div(v-else-if='isDashboard')
  select(v-on:change='onDaysSelectChange($event)')
    option(value='' disabled selected hidden) 未アサインの提出物の経過日数を選択
    option(value='1') 1日経過 2日経過 3日以上経過
    option(value='2') 2日経過 3日経過 4日以上経過
    option(value='3') 3日経過 4日経過 5日以上経過
    option(value='4') 4日経過 5日経過 6日以上経過
    option(value='5') 5日経過 6日経過 7日以上経過
  template(v-for='product_n_days_passed in productsGroupedByElapsedDays') <!-- product_n_days_passedはn日経過の提出物 -->
    .a-card.h-auto(
      v-if='!isDashboard || (isDashboard && product_n_days_passed.elapsed_days >= selectedDays && product_n_days_passed.elapsed_days <= selectedDays + 2)')
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
        v-else-if='product_n_days_passed.elapsed_days === selectedDays', id='4days-elapsed'
      )
        h2.card-header__title
          | {{ selectedDays }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-alert(
        v-else-if='product_n_days_passed.elapsed_days === selectedDays + 1', id='5days-elapsed'
      )
        h2.card-header__title
          | {{ selectedDays + 1 }}日経過
          span.card-header__count
            | （{{ countProductsGroupedBy(product_n_days_passed) }}）
      //- prettier-ignore: need space between v-else-if and id
      header.card-header.a-elapsed-days.is-reply-deadline(
        v-else-if='product_n_days_passed.elapsed_days === selectedDays + 2', id='6days-elapsed'
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
        v-bind:href='/products/unassigned#${selectedDays}days-elapsed',
        v-if='countAlmostPassedSelectedDays() === 0')
        | しばらく{{ selectedDays }}日経過に到達する<br>提出物はありません。
      a.divide-indigo-800.block.p-3.border.rounded.border-solid.text-indigo-800.a-hover-link(
        class='hover\:bg-black',
        v-bind:href='/products/unassigned#${selectedDays}days-elapsed',
        v-else)
        | <strong>{{ countAlmostPassedSelectedDays() }}件</strong>の提出物が、<br>8時間以内に{{ selectedDays }}日経過に到達します。
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
      selectedDays: 4
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
      const previousDaysElement =
        this.productsGroupedByElapsedDays === null
          ? undefined
          : this.getElementNdaysPassed(this.selectedDays - 1)
      return previousDaysElement === undefined
        ? 0
        : this.PassedAlmostSelectedDaysProducts(previousDaysElement.products).length
    },
    onDaysSelectChange(event) {
      this.selectedDays = parseInt(event.target.value)
    }
  }
}
</script>
