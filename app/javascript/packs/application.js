/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import '../textarea.js'
import '../markdown.js'
import '../shortcut.js'
import '../learning.js'
import '../learning-status.js'
import '../check.js'
import '../check-stamp.js'
import '../unconfirmed-links-open.js'
import '../comments.js'
import '../category-select.js'
import '../fileinput.js'
import '../reaction.js'
import '../practice_memo.js'
import '../card.js'
import '../js-select2.js'
import '../warning.js'
import '../date-input-toggler'
import '../github_grass'
import '../following.js'
import '../hide-user.js'
import '../categories-practice.js'
import '../products.js'
import '../courses-categories.js'
import '../courses-practices.js'
import '../no_learn.js'
import '../survey_question.js'
import '../survey.js'
import '../mentor-mode.js'
import '../agreements.js'
import '../book-select.js'
import '../subscription-status.js'
import '../new-event-date-set.js'
import '../company-users.js'
import '../learning-completion-message.js'
import '../choices-ui.js'
import '../training-info-toggler.js'
import '../company-products.js'
import '../welcome_message_for_adviser.js'
import '../bookmarks-edit-button.js'
import '../hibernation_agreements.js'
import '../current-date-time-setter.js'
import '../modal-switcher.js'
import '../survey-question-listings.js'
import '../change-subdivisions.js'
import '../register-address.js'
import '../upload-image-to-article.js'
import '../header-dropdown.js'
import '../editor-selection-form.js'
import '../user_mentor_memo.js'
import '../invitation-url-updater.js'
import '../card-form-display-switcher.js'

import VueMounter from '../VueMounter.js'
import Books from '../components/books.vue'
import Questions from '../components/questions.vue'
import UsersAnswers from '../components/users-answers.vue'
import User from '../components/user.vue'
import Watches from '../components/watches.vue'
import WatchToggle from '../components/watch-toggle.vue'
import Footprints from '../components/footprints.vue'
import QuestionAnswers from '../components/question-answers.vue'
import SadReports from '../components/sad_reports.vue'
import UserProducts from '../components/user-products.vue'
import ActionCompletedButton from '../components/action-completed-button.vue'
import CourseBooks from '../components/course-books.vue'

import '../stylesheets/application'

const mounter = new VueMounter()
mounter.addComponent(Books)
mounter.addComponent(Questions)
mounter.addComponent(UsersAnswers)
mounter.addComponent(User)
mounter.addComponent(Watches)
mounter.addComponent(WatchToggle)
mounter.addComponent(Footprints)
mounter.addComponent(QuestionAnswers)
mounter.addComponent(SadReports)
mounter.addComponent(UserProducts)
mounter.addComponent(ActionCompletedButton)
mounter.addComponent(CourseBooks)
mounter.mount()

// Support component names relative to this directory:
const componentRequireContext = require.context('components', true)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)
