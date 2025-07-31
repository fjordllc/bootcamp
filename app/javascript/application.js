// Entry point for the build script in your package.json
// Migrated from Webpacker packs/application.js

/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Rails 7 core imports - temporarily disabled to debug
// import * as ActiveStorage from '@rails/activestorage'

// jQuery setup for Rails 7
import jquery from 'jquery'
import './textarea.js'
import './markdown.js'
import './shortcut.js'
import './learning.js'
import './learning-status.js'
import './check.js'
import './check-stamp.js'
import './unconfirmed-links-open.js'
import './new-comment.js'
import './category-select.js'
import './comments.js'
import './fileinput.js'
import './reaction.js'
import './practice_memo.js'
import './card.js'
import './js-select2.js'
import './warning.js'
import './date-input-toggler'
import './grass.js'
import './github_grass'
import './following.js'
import './hide-user.js'
import './categories-practice.js'
import './courses-categories.js'
import './courses-practices.js'
import './no_learn.js'
import './survey_question.js'
import './survey.js'
import './mentor-mode.js'
import './agreements.js'
import './book-select.js'
import './subscription-status.js'
import './new-event-date-set.js'
import './learning-completion-message.js'
import './choices-ui.js'
import './training-info-toggler.js'
import './welcome_message_for_adviser.js'
import './bookmarks-edit-button.js'
import './hibernation_agreements.js'
import './current-date-time-setter.js'
import './modal-switcher.js'
import './survey-question-listings.js'
import './activity-time-filter.js'
import './change-subdivisions.js'
import './register-address.js'
import './upload-image-to-article.js'
import './header-dropdown.js'
import './postal-code-address.js'
import './editor-selection-form.js'
import './user_mentor_memo.js'
import './invitation-url-updater.js'
import './movie-fileinput.js'
import './payment-methods-check-boxes.js'
import './product_checker.js'
import './product_checker_button.js'
import './user-follow.js'
import './sort-faq.js'
import './sort-faq-category.js'
import './micro-report-form-tabs.js'
import './micro-reports.js'
import './micro-reports-edit.js'
import './answer.js'
import './new-answer.js'
import './coding-test.js'
import './copy-url.js'
import './survey_result_chart.js'
import './footprints.js'
import './article-target.js'
import './referral-source-selection-form.js'
import './coding_tests_sort.js'
import './watches.js'
import './watch-toggle.js'
import './diploma-upload.js'
import './tag-shortcut.js'
import Cocooned from '@notus.sh/cocooned'
import './action_completed_button.js'
import './toast.js'
import VueMounter from './VueMounter.js'
import Questions from './components/questions.vue'
// Import stylesheets
import './stylesheets/application.sass'

// jQuery setup for Rails 7
if (typeof window !== 'undefined') {
  window.$ = window.jQuery = jquery
}

const mounter = new VueMounter()
mounter.addComponent(Questions)
mounter.mount()

// Support component names relative to this directory:
const componentRequireContext = require.context('components', true)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)

document.addEventListener('DOMContentLoaded', () => {
  // Initialize ActiveStorage - temporarily disabled to debug
  // if (typeof window !== 'undefined') {
  //   window.ActiveStorage = ActiveStorage
  //   ActiveStorage.start()
  // }

  Cocooned.start()

  // Debug React components
  console.log(
    'React UJS mounted components:',
    document.querySelectorAll('[data-react-class]').length
  )
  console.log(
    'Found react components:',
    Array.from(document.querySelectorAll('[data-react-class]')).map((el) =>
      el.getAttribute('data-react-class')
    )
  )
})
