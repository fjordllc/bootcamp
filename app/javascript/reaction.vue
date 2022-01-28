<template lang="pug">
.reactions.test-block.js-reactions
  ul.reactions__items.test-inline-block.js-reaction
    li.reactions__item.test-inline-block(
      v-for='emoji in displayedEmojis',
      v-bind:class='{ "is-reacted": isReacted(emoji.kind) }',
      @click='footerReaction(emoji.kind)',
      :data-reaction-kind='emoji.kind'
    )
      span.reactions__item-emoji.js-reaction-emoji
        | {{ emoji.value }}
      span.reactions__item-count.js-reaction-count
        | {{ emoji.count }}
      ul.reactions__item-login-names.js-reaction-login-names
        li(v-for='login_name in emoji.login_names')
          | {{ login_name }}
  .reactions__dropdown.js-reaction-dropdown
    .reactions__dropdown-toggle.js-reaction-dropdown-toggle(
      @click='dropdownToggle()'
    )
      i.fas.fa-plus.reactions__dropdown-toggle-plus
      i.fas.fa-smile
    ul.reactions__items.test-inline-block.js-reaction(v-if='dropdown')
      li.reactions__item.test-inline-block(
        v-for='emoji in availableEmojis',
        v-bind:class='{ "is-reacted": isReacted(emoji.kind) }',
        :data-reaction-kind='emoji.kind',
        @click='dropdownReaction(emoji.kind)'
      )
        span.reactions__item-emoji.js-reaction-emoji
          | {{ emoji.value }}
</template>
<script>
export default {
  components: {},
  props: {
    reactionable: { type: Object, required: true },
    currentUser: { type: Object, required: true },
    reactionableId: { type: String, required: true }
  },
  data() {
    return {
      availableEmojis: [],
      dropdown: false
    }
  },
  computed: {
    displayedEmojis: function () {
      const emojis = this.reactionable.reaction_count.filter(function (el) {
        return el.count !== 0
      }, this)
      return emojis
    }
  },
  created: function () {
    this.availableEmojis = window.availableEmojis
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    createReaction: function (kind) {
      const params = {
        reactionable_id: this.reactionableId,
        kind: kind
      }

      fetch(`/api/reactions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          function findKind(element) {
            return element.kind === kind
          }
          const id = this.reactionable.reaction_count.findIndex(findKind)
          // TODO propsを直接変更しているコードを修正する #2600
          // eslint-disable-next-line vue/no-mutating-props
          this.reactionable.reaction_count[id].count += 1
          // eslint-disable-next-line vue/no-mutating-props
          this.reactionable.reaction_count[id].login_names.push(
            this.currentUser.login_name
          )
          return response.json()
        })
        .then((json) => {
          // TODO propsを直接変更しているコードを修正する #2600
          // eslint-disable-next-line vue/no-mutating-props
          this.reactionable.reaction.push({
            id: json.id,
            user_id: this.currentUser.id,
            kind: kind
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    destroyReaction: function (kind) {
      const clickedReaction = this.reactionable.reaction.find(function (el) {
        return el.user_id === this.currentUser.id && el.kind === kind
      }, this)

      fetch(`/api/reactions/${clickedReaction.id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.reactionable.reaction.forEach((reaction, i) => {
            if (reaction.id === clickedReaction.id) {
              // TODO propsを直接変更しているコードを修正する #2600
              // eslint-disable-next-line vue/no-mutating-props
              this.reactionable.reaction.splice(i, 1)
            }
          })

          function findKind(element) {
            return element.kind === kind
          }
          const id = this.reactionable.reaction_count.findIndex(findKind)
          // TODO propsを直接変更しているコードを修正する #2600
          // eslint-disable-next-line vue/no-mutating-props
          this.reactionable.reaction_count[id].count -= 1
          this.reactionable.reaction_count[id].login_names.forEach(
            (name, i) => {
              if (name === this.currentUser.login_name) {
                // TODO propsを直接変更しているコードを修正する #2600
                // eslint-disable-next-line vue/no-mutating-props
                this.reactionable.reaction_count[id].login_names.splice(i, 1)
              }
            }
          )
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    footerReaction: function (kind) {
      this.isReacted(kind)
        ? this.destroyReaction(kind)
        : this.createReaction(kind)
    },
    dropdownReaction: function (kind) {
      this.footerReaction(kind)
      this.dropdownToggle()
    },
    dropdownToggle: function () {
      this.dropdown = !this.dropdown
    },
    isReacted: function (kind) {
      function findkind(element) {
        return element.kind === kind
      }
      const id = this.reactionable.reaction_count.findIndex(findkind)
      const reaction = this.reactionable.reaction_count[id].login_names.filter(
        function (el) {
          return el === this.currentUser.login_name
        },
        this
      )
      return reaction.length !== 0
    }
  }
}
</script>
<style scoped></style>
