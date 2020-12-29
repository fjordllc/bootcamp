<template lang="pug">
  .thread-list-item(:class="product.wip ? 'is-wip' : ''")
    .thread-list-item__inner
      .thread-list-item__author
        a.thread-header__author(:href="product.user.url")
          img.thread-list-item__author-icon.a-user-icon(
            :title="product.user.icon_title"
            :alt="product.user.icon_title"
            :src="product.user.avatar_url"
            :class="[roleClass, daimyoClass]")
      header.thread-list-item__header
        .thread-list-item__header-title-container
          .thread-list-item__header-icon.is-wip(v-if="product.wip") WIP
        h2.thread-list-item__title(itemprop='name')
          a.thread-list-item__title-link.js-unconfirmed-link(:href="product.url" itemprop='url') {{ practiceTitle }}
      .thread-list-item-meta
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            a.thread-header__author(:href="product.user.url") {{ product.user.login_name }}
          .thread-list-item-meta__item(v-if="product.wip")
            .thread-list-item-meta__datetime 提出物作成中
          .thread-list-item-meta__item(v-else-if="product.published_at")
            time.thread-list-item-meta__datetime(datetime="product.published_at_date_time")
              span.thread-list-item-meta__datetime-label 提出日
              | {{ product.published_at }}
          .thread-list-item-meta__item(v-else)
            time.thread-list-item-meta__datetime(datetime="product.created_at_date_time")
              span.thread-list-item-meta__datetime-label 提出日
              | {{ product.created_at }}
          time.thread-list-item-meta__datetime(v-if="product.updated_at" datetime="product.updated_at_date_time")
            span.thread-list-item-meta__datetime-label 最終更新日
            | {{ product.updated_at }}

      .thread-list-item-meta(v-if="product.comments.size > 0")
        .thread-list-item-meta__label
          | コメント
        .thread-list-item-meta__comment-count
          .thread-list-item-meta__comment-count-value （{{product.comments.size}}）
        .thread-list-item__user-icons(v-for="user in product.comments.users")
          a.thread-list-item__user-icon(:href="user.url")
            img.thread-list-item__checked-author-icon.a-user-icon(
              :title="user.icon_title"
              :alt="user.icon_title"
              :src="user.avatar_url"
              :class="[roleClass, daimyoClass]")
        time.thread-list-item-meta__datetime(datetime="product.comments.last_created_at_date_time}")
          | {{ product.comments.last_created_at }}
      .stamp.stamp-approve(v-if="product.checks.size > 0")
        h2.stamp__content.is-title 確認済
        time.stamp__content.is-created-at {{ product.checks.last_created_at }}
        .stamp__content.is-user-name {{ product.checks.last_user_login_name }}
</template>
<script>
export default {
  props: ['product'],
  computed: {
    roleClass() {
      return `is-${this.product.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.product.user.daimyo }
    },
    practiceTitle() {
      return this.product.user.daimyo ? `★${this.product.practice.title}の提出物` : `${this.product.practice.title}の提出物`
    }
  }
}
</script>
