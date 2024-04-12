export default {
  props: {
    footprint: { type: Object, required: true }
  },
  computed: {
    loginNameClass() {
      return `is-${this.footprint.user.login_name}`
    },
    primaryRoleClass() {
      return `is-${this.footprint.user.primary_role}`
    }
  }
}
