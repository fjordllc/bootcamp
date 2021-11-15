import Vue from 'vue'
import FeaturedEntryButton from './featured-entry-button.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '#js-featured-entry'
  const featuredEntry = document.querySelector(selector)
  if (featuredEntry) {
    const featureableId = Number(featuredEntry.getAttribute('data-featureable-id'))
    const featureableType = featuredEntry.getAttribute('data-featureable-type')
    new Vue({
      render: (h) =>
        h(FeaturedEntryButton, {
          props: {
            featureableId,
            featureableType
          }
        })
    }).$mount(selector)
  }
})
