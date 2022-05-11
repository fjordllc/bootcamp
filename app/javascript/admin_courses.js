import Vue from 'vue'
import VueApollo from 'vue-apollo'
import ApolloClient from 'apollo-boost'
import AdminCourses from 'admin_courses.vue'

const apolloClient = new ApolloClient({
  uri: 'http://localhost:3000/graphql'
})
const apolloProvider = new VueApollo({
  defaultClient: apolloClient,
})

Vue.use(VueApollo)

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-admin-courses'
  const adminCourses = document.querySelector(selector)
  if (adminCourses) {
    new Vue({
      apolloProvider,
      render: (h) => h(AdminCourses)
    }).$mount(selector)
  }
})
