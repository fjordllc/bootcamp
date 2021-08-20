export default {
  watch: {
    editing(newEditing) {
      if (newEditing) {
        window.addEventListener('beforeunload', this.handleBeforeUnload, false)
      } else {
        window.removeEventListener(
          'beforeunload',
          this.handleBeforeUnload,
          false
        )
      }
    }
  },
  methods: {
    handleBeforeUnload(event) {
      event.preventDefault()
      event.returnValue = ''
    }
  }
}
