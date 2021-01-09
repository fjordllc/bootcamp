<template lang="pug">
  .unconfirmed_links
    .thread-admin-tools
      ul.thread-admin-tools__items
        li.thread-admin-tools__item
          button.thread-unconfirmed-links-form__action(class="a-button is-md is-primary" @click="openUnonfirmedItems()") {{ label }}
</template>
<script>

export default {
  props: ['label'],
  methods: {
    openUnonfirmedItems(){
      const links = document.querySelectorAll('.thread-list-item .js-unconfirmed-link')
      links.forEach(link => {
        window.open(link.href, '_target', 'noopener')
      })
    }
  },
}
</script>
