<template lang="pug">
div
  hr.a-border-tint
  .unconfirmed_links.card-footer.is-only-mentor
    .card-main-actions
      ul.card-main-actions__items
        li.card-main-actions__item
          button.thread-unconfirmed-links-form__action.a-button.is-block.is-sm.is-secondary(
            @click='openUnconfirmedItems()') {{ label }}
</template>
<script>
export default {
  props: {
    label: { type: String, required: true }
  },
  methods: {
    openUnconfirmedItems() {
      const links = document.querySelectorAll(
        '.card-list-item .js-unconfirmed-link'
      )
      links.forEach((link) => {
        window.open(link.href, '_target', 'noopener')
      })
    }
  }
}
</script>
