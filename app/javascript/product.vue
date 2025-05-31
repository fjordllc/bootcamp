<template lang="pug">
.card-list-item.has-assigned(:class='product.wip ? "is-wip" : ""')
  .card-list-item__inner
    .card-list-item__user(v-if='displayUserIcon')
      a.card-list-item__user-link(:href='product.user.url')
        span(:class='["a-user-role", roleClass]')
          img.card-list-item__user-icon.a-user-icon(
            :title='product.user.icon_title',
            :alt='product.user.icon_title',
            :src='product.user.avatar_url')
    .card-list-item__rows
      .card-list-item__row
        .card-list-item-title
          .card-list-item__notresponded(v-if='notRespondedSign')
          .card-list-item-title__start
            .a-list-item-badge.is-wip(v-if='product.wip')
              span
                | WIP
          h2.card-list-item-title__title(itemprop='name')
            a.card-list-item-title__link.a-text-link.js-unconfirmed-link(
              :href='product.url',
              itemprop='url')
              | {{ practiceTitle }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              a.a-user-name(:href='product.user.url')
                | {{ product.user.long_name }}
      .card-list-item__row
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item(v-if='product.wip')
              .a-meta 提出物作成中
            .card-list-item-meta__item(v-else-if='product.published_at')
              time.a-meta
                span.a-meta__label 提出
                | {{ product.published_at }}
            .card-list-item-meta__item(v-else)
              time.a-meta
                span.a-meta__label 提出
                | {{ product.created_at }}
            .card-list-item-meta__item
              time.a-meta(v-if='product.updated_at')
                span.a-meta__label 更新
                | {{ product.updated_at }}
            .card-list-item-meta__item(
              v-if='isUnassignedProductsPage || isDashboardPage')
              time.a-meta(v-if='untilNextElapsedDays(product) < 1')
                span.a-meta__label 次の経過日数まで
                | 1時間未満
              time.a-meta(v-else-if='calcElapsedTimes(product) < 7')
                span.a-meta__label 次の経過日数まで
                | 約{{ untilNextElapsedDays(product) }}時間

      hr.card-list-item__row-separator(v-if='product.comments.size > 0')
      .card-list-item__row(v-if='product.comments.size > 0')
        .card-list-item-meta
          .card-list-item-meta__items
            .card-list-item-meta__item
              .a-meta
                | コメント（{{ product.comments.size }}）
            .card-list-item-meta__item
              .card-list-item__user-icons
                a.card-list-item__user-icons-icon(
                  :href='user.url',
                  v-for='user in product.comments.users')
                  img.a-user-icon(
                    :title='user.icon_title',
                    :alt='user.icon_title',
                    :src='user.avatar_url',
                    :class='[`is-${user.primary_role}`]')

            .card-list-item-meta__item(
              v-if='product.self_last_commented_at_date_time && product.mentor_last_commented_at_date_time')
              time.a-meta(
                v-if='product.self_last_commented_at_date_time > product.mentor_last_commented_at_date_time')
                | 〜 {{ product.self_last_commented_at }}（
                strong
                  | 提出者
                | ）
              time.a-meta(
                v-if='product.self_last_commented_at_date_time < product.mentor_last_commented_at_date_time')
                | 〜 {{ product.mentor_last_commented_at }}（メンター）

            .card-list-item-meta__item(
              v-else-if='product.self_last_commented_at_date_time || product.mentor_last_commented_at_date_time')
              time.a-meta(v-if='product.self_last_commented_at_date_time')
                | 〜 {{ product.self_last_commented_at }}（
                strong
                  | 提出者
                | ）
              time.a-meta(
                v-else-if='product.mentor_last_commented_at_date_time')
                | 〜 {{ product.mentor_last_commented_at }}（メンター）
      .card-list-item__row.is-only-mentor(
        v-if='isMentor && product.checks.size == 0')
        .card-list-item__assignee
          product-checker(
            :checkerId='product.checker_id',
            :checkerName='product.checker_name',
            :checkerAvatar='product.checker_avatar',
            :currentUserId='currentUserId',
            :productId='product.id',
            :parentComponent='"product"')

    .stamp.stamp-approve(v-if='product.checks.size > 0')
      h2.stamp__content.is-title
        | 合格
      time.stamp__content.is-created-at
        | {{ product.checks.last_created_at }}
      .stamp__content.is-user-name
        .stamp__content-inner
          | {{ product.checks.last_user_login_name }}
</template>
<script>
import ProductChecker from 'product_checker'
export default {
  components: {
    'product-checker': ProductChecker
  },
  props: {
    product: { type: Object, required: true },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: Number, required: true },
    displayUserIcon: { type: Boolean }
  },
  computed: {
    roleClass() {
      return `is-${this.product.user.primary_role}`
    },
    practiceTitle() {
      return `${this.product.practice.title}の提出物`
    },
    isDashboardPage() {
      return location.pathname === '/'
    },
    isUnassignedProductsPage() {
      return location.pathname === '/products/unassigned'
    },
    notRespondedSign() {
      return (
        this.product.self_last_commented_at_date_time >
          this.product.mentor_last_commented_at_date_time ||
        this.product.comments.size === 0
      )
    }
  },
  methods: {
    untilNextElapsedDays(product) {
      const elapsedTimes = this.calcElapsedTimes(product)
      return Math.floor((Math.ceil(elapsedTimes) - elapsedTimes) * 24)
    },
    calcElapsedTimes(product) {
      const time =
        product.published_at_date_time || product.created_at_date_time
      return (new Date() - Date.parse(time)) / 1000 / 60 / 60 / 24
    }
  }
}
</script>
