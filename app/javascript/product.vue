<template lang="pug">
.thread-list-item(:class='product.wip ? "is-wip" : ""')
  p(v-if="isLatestProductSubmittedJust5days")
    | 5日経過
  p(v-else-if="isLatestProductSubmittedJust6days")
    | 6日経過
  p(v-else-if="isLatestProductSubmittedOver7days")
    | 7日以上経過
  .thread-list-item__inner
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__start
            .thread-list-item-title__icon.is-wip(v-if='product.wip') WIP
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link.js-unconfirmed-link(
              :href='product.url',
              itemprop='url'
            ) {{ practiceTitle }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              a.a-user-name(:href='product.user.url') {{ product.user.login_name }}
            .thread-list-item-meta__item(v-if='product.wip')
              .a-date 提出物作成中
            .thread-list-item-meta__item(v-else-if='product.published_at')
              time.a-date(datetime='product.published_at_date_time')
                span.a-date__label 提出日
                | {{ product.published_at }}
            .thread-list-item-meta__item(v-else)
              time.a-date(datetime='product.created_at_date_time')
                span.a-date__label 提出日
                | {{ product.created_at }}
            time.a-date(
              v-if='product.updated_at',
              datetime='product.updated_at_date_time'
            )
              span.a-date__label 最終更新日
              | {{ product.updated_at }}

      .thread-list-item__row(v-if='product.comments.size > 0')
        hr.thread-list-item__row-separator
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              .thread-list-item-comment
                .thread-list-item-comment__label
                  | コメント
                .thread-list-item-comment__count
                  | （{{ product.comments.size }}）
                .thread-list-item-comment__user-icons
                  a.thread-list-item-comment__user-icon(:href='user.url')(
                    v-for='user in product.comments.users'
                  )
                    img.a-user-icon(
                      :title='user.icon_title',
                      :alt='user.icon_title',
                      :src='user.avatar_url',
                      :class='[roleClass, daimyoClass]'
                    )
                time.a-date(
                  datetime='product.comments.last_created_at_date_time'
                )
                  | 〜 {{ product.comments.last_created_at }}
    .stamp.stamp-approve(v-if='product.checks.size > 0')
      h2.stamp__content.is-title 確認済
      time.stamp__content.is-created-at {{ product.checks.last_created_at }}
      .stamp__content.is-user-name {{ product.checks.last_user_login_name }}
    .thread-list-item__assignee.is-only-mentor(
      v-if='isMentor && product.checks.size == 0'
    )
      product-checker(
        :checkerId='product.checker_id',
        :checkerName='product.checker_name',
        :currentUserId='currentUserId',
        :productId='product.id'
      )
    .thread-list-item__author
      a.a-user-name(:href='product.user.url')
        img.thread-list-item__author-icon.a-user-icon(
          :title='product.user.icon_title',
          :alt='product.user.icon_title',
          :src='product.user.avatar_url',
          :class='[roleClass, daimyoClass]'
        )
</template>
<script>
import ProductChecker from './product_checker'
export default {
  props: ['product', 'currentUserId', 'isMentor', 'latestProductSubmittedJust5days', 'latestProductSubmittedJust6days', 'latestProductSubmittedOver7days'],
  components: {
    'product-checker': ProductChecker
  },
  computed: {
    roleClass() {
      return `is-${this.product.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.product.user.daimyo }
    },
    practiceTitle() {
      return this.product.user.daimyo
        ? `★${this.product.practice.title}の提出物`
        : `${this.product.practice.title}の提出物`
    },
    isLatestProductSubmittedJust5days() {
      if (this.latestProductSubmittedJust5days !== null) {
        return this.product.id === this.latestProductSubmittedJust5days.id
      }
    },
    isLatestProductSubmittedJust6days() {
      if (this.latestProductSubmittedJust6days !== null) {
        return this.product.id === this.latestProductSubmittedJust6days.id
      }
    },
    isLatestProductSubmittedOver7days() {
      if (this.latestProductSubmittedOver7days !== null) {
        return this.product.id === this.latestProductSubmittedOver7days.id
      }
    },
  }
}
</script>
