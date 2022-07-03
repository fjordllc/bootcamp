<template lang="pug">
.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .card-books-item
    .a-card
      .card-books-item__inner
        .card-books-item__start
          a.card-books-item__cover-container(:href='book.page_url')
            img.card-books-item__image(
              :title='book.title',
              :alt='book.title',
              :src='book.cover_url'
            )
        .card-books-item__end
          h2.card-books-item__title
            a.card-books-item__title-link(
              :href='book.page_url',
              target='_blank',
              rel='noopener'
              )
              span.card__title-label
                | {{ book.title }}
            p.card-books-item__price
              | {{ book.price }}円（税込）
              .card-books-item__description(v-if='book.description')
                .a-short-text
                  | {{ book.description }}
      .card-books-item__practices.tag-links
        ul.tag-links__items
          li.tag-links__item
            a.tag-links__item-link
      footer.card-footer.is-only-mentor(v-if='currentUser.admin || currentUser.mentor')
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item
              a.card-main-actions__action.a-button.is-sm.is-secondary.is-block(href='#')
                | 編集
</template>
<script>
export default {
  props: {
    book: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  }
}
</script>
