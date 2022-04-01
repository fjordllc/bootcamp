<template lang="pug">
.thread-list-item.has-assigned(:class='product.wip ? "is-wip" : ""')
  .thread-list-item__strip-label(v-if='unassigned || unchecked')
    .thread-list-item__elapsed-days.is-reply-warning.is-only-mentor(
      v-if='isAllSubmittedProducts(1)'
    )
      | 1日経過
    .thread-list-item__elapsed-days.is-reply-alert.is-only-mentor(
      v-else-if='isAllSubmittedProducts(2)'
    )
      | 2日経過
    .thread-list-item__elapsed-days.is-reply-alert.is-only-mentor(
      v-else-if='isAllSubmittedProducts(3)'
    )
      | 3日経過
    .thread-list-item__elapsed-days.is-reply-alert.is-only-mentor(
      v-else-if='isAllSubmittedProducts(4)'
    )
      | 4日経過
    .thread-list-item__elapsed-days.is-reply-alert.is-only-mentor(
      v-else-if='isAllSubmittedProducts(5)'
    )
      | 5日経過
    .thread-list-item__elapsed-days.is-reply-alert.is-only-mentor(
      v-else-if='isAllSubmittedProducts(6)'
    )
      | 6日経過
    .thread-list-item__elapsed-days.is-reply-deadline.is-only-mentor(
      v-else-if='isAllSubmittedProducts(7)'
    )
      | 7日以上経過
  .thread-list-item__inner
    .thread-list-item__user
      a.a-user-name(:href='product.user.url')
        img.thread-list-item__user-icon.a-user-icon(
          :title='product.user.icon_title',
          :alt='product.user.icon_title',
          :src='product.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item__notresponded(v-if='notRespondedSign')
          .thread-list-item-title__start
            .thread-list-item-title__icon.is-wip(v-if='product.wip') WIP
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link.a-text-link.js-unconfirmed-link(
              :href='product.url',
              itemprop='url'
            )
              | {{ practiceTitle }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='product.user.url')
                | {{ product.user.login_name }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item(v-if='product.wip')
              .a-meta 提出物作成中
            .thread-list-item-meta__item(v-else-if='product.published_at')
              time.a-meta
                | 提出日（{{ product.published_at }}）
            .thread-list-item-meta__item(v-else)
              time.a-meta
                | 提出日（{{ product.created_at }}）
            .thread-list-item-meta__item
              time.a-meta(v-if='product.updated_at')
                | 更新（{{ product.updated_at }}）
      hr.thread-list-item__row-separator(v-if='product.comments.size > 0')
      .thread-list-item__row(v-if='product.comments.size > 0')
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .a-meta
                | コメント（{{ product.comments.size }}）
              .thread-list-item-comment__user-icons
                a.thread-list-item-comment__user-icon(
                  :href='user.url',
                  v-for='user in product.comments.users'
                )
                  img.a-user-icon(
                    :title='user.icon_title',
                    :alt='user.icon_title',
                    :src='user.avatar_url',
                    :class='[roleClass, daimyoClass]'
                  )

            .thread-list-item-meta__item(
              v-if='product.self_last_commented_at_date_time && product.mentor_last_commented_at_date_time'
            )
              time.a-meta(
                v-if='product.self_last_commented_at_date_time > product.mentor_last_commented_at_date_time'
              )
                | 〜 {{ product.self_last_commented_at }}（
                strong
                  | 提出者
                | ）
              time.a-meta(
                v-if='product.self_last_commented_at_date_time < product.mentor_last_commented_at_date_time'
              )
                | 〜 {{ product.mentor_last_commented_at }}（メンター）

            .thread-list-item-meta__item(
              v-else-if='product.self_last_commented_at_date_time || product.mentor_last_commented_at_date_time'
            )
              time.a-meta(v-if='product.self_last_commented_at_date_time')
                | 〜 {{ product.self_last_commented_at }}（
                strong
                  | 提出者
                | ）
              time.a-meta(
                v-else-if='product.mentor_last_commented_at_date_time'
              )
                | 〜 {{ product.mentor_last_commented_at }}（メンター）

    .stamp.stamp-approve(v-if='product.checks.size > 0')
      h2.stamp__content.is-title
        | 確認済
      time.stamp__content.is-created-at
        | {{ product.checks.last_created_at }}
      .stamp__content.is-user-name
        .stamp__content-inner
          | {{ product.checks.last_user_login_name }}
    .thread-list-item__assignee.is-only-mentor(
      v-if='isMentor && product.checks.size == 0'
    )
      product-checker(
        :checkerId='product.checker_id',
        :checkerName='product.checker_name',
        :checkerAvatar='product.checker_avatar',
        :currentUserId='currentUserId',
        :productId='product.id'
      )
</template>
<script>
import { formatDistance } from 'date-fns'
import ProductChecker from './product_checker'
export default {
  components: {
    'product-checker': ProductChecker
  },
  props: {
    product: { type: Object, required: true },
    isMentor: { type: Boolean, required: true },
    currentUserId: { type: String, required: true },
    allSubmittedProducts: {
      type: Object,
      required: false,
      default: null
    }
  },
  data() {
    return { formatDistance }
  },
  computed: {
    updatedAt() {
      return Date.parse(this.product.updated_at_date_time)
    },
    roleClass() {
      return `is-${this.product.user.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.product.user.daimyo }
    },
    practiceTitle() {
      return this.product.user.daimyo
        ? `★${this.product.practice.title}の提出物`
        : `${this.product.practice.title}の提出物`
    },
    unassigned() {
      return location.pathname === '/products/unassigned'
    },
    unchecked() {
      return location.pathname === '/products/unchecked'
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
    },
    isAllSubmittedProducts(n) {
      if (this.allSubmittedProducts[n] !== undefined) {
        return this.product.id === this.allSubmittedProducts[n].id
      } else {
        return false
      }
    }
  }
}
</script>
