export default {
  methods: {
    isRole(role) {
      return this.currentUser.roles.includes(role)
    }
  }
}
