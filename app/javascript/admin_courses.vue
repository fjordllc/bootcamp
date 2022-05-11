<template lang="pug">
  .container.is-lg
    .admin-table
      table.admin-table__table
        thead.admin-table__header
          tr.admin-table__labels
            th.admin-table__label
              | コース名
            th.admin-table__label
              | 説明文
            th.admin-table__label
              | 操作
        tbody.admin-table__items
          tr.admin-table__item(
            v-for='edge in courses.edges',
            :key='edge.node.id',
            :id='`course_${edge.node.id}`',
            v-if='courses.edges'
          )
            td.admin-table__item-value
              | {{ edge.node  }}
            td.admin-table__item-value
            td.admin-table__item-value.is-text-align-center
              ul.is-inline-buttons
                li
                  i.fa-solid.fa-pen
</template>
<script>
import gql from 'graphql-tag'

const query = gql`
query {
  courses {
    edges {
      node {
        id
        title
        description
        published
        createdAt
        updatedAt
      }
    }
    pageInfo {
      endCursor
      hasNextPage
      startCursor
      hasPreviousPage
    }
  }
}
`

export default {
  data () {
    return {
      courses: [],
      loading: null
    }
  },
  apollo: {
    courses: query,
  },
}
</script>
