<template lang="pug">
.col-xxl-3.col-xl-4.col-lg-4.col-md-6.col-xs-12
  .card-books-item.a-card
    .card-books-item__body
      .card-books-item__inner
        .card-books-item__start
          a.card-books-item__cover-container(
            :href='book.pageUrl',
            target='_blank',
            rel='noopener'
          )
          img.card-books-item__image(
            :title='book.title',
            :alt='book.title',
            :src='book.coverUrl'
          )
        .card-books-item__end
          .card-books-item__rows
            .card-books-item__row
              h2.card-books-item__title
                a.card-books-item__title-link(
                  :href='book.pageUrl',
                  target='_blank',
                  rel='noopener'
                )
                span.card-books-item__title-label
                  | {{ book.title }}
            .card-books-item__row
              p.card-books-item__price
                | {{ book.price.toLocaleString() }}円（税込）
            card-books-item__row(v-if='book.description')
              .card-books-item__description
                .a-short-text
                  | {{ book.description }}
    .card-books-item__practices
      .tag-links
        ul.tag-links__items
          li.tag-links__item(
            v-for='practice in book.practices',
            :key='practice.id'
          )
            a.tag-links__item-link(:href='practice.practicePath')
              | {{ practice.title }}
    footer.card-footer.is-only-mentor(v-if='currentUser.adminOrMentor')
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item
            a.card-main-actions__action.a-button.is-sm.is-secondary.is-block(
              :href='book.editBookPath'
            )
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
