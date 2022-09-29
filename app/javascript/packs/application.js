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
import '../notifications_bell.js'
import '../question-page.js'
import '../category-select.js'
import '../grass.js'
import '../fileinput.js'
import '../reaction.js'
import '../practice_memo.js'
import '../card.js'
import '../js-select2.js'
import '../warning.js'
import '../date-input-toggler'
import '../github_grass'
import '../tags-input.js'
import '../page_tags.js'
import '../following.js'
import '../user_tags.js'
import '../hide-user.js'
import '../categories.js'
import '../categories-practice.js'
import '../notifications.js'
import '../products.js'
import '../courses-categories.js'
import '../courses-practices.js'
import '../no_learn.js'
import '../searchables.js'
import '../niconico_calendar.js'
import '../mentor-mode.js'
import '../bookmark.js'
import '../bookmarks.js'
import '../events.js'
import '../agreements.js'
import '../incoming-events.js'
import '../book-select.js'
import '../companies.js'
import '../report_template.js'
import '../subscription-status.js'
import '../new-event-date-set.js'
import '../tag_edit.js'
import '../company-users.js'
import '../generation-users.js'
import '../learning-completion-message.js'
import '../choices-ui.js'
import '../training-info-toggler.js'
import '../company-products.js'
import '../welcome_message_for_adviser.js'
import '../regular-events.js'
import '../featured_entry.js'
import '../featured_entries.js'

import VueMounter from '../VueMounter.js'
import Hello from '../components/hello.vue'
import AdminCompanies from '../components/admin_companies.vue'
import Announcements from '../components/announcements.vue'
import Books from '../components/books.vue'
import Pages from '../components/pages.vue'
import Questions from '../components/questions.vue'
import WorriedUsers from '../components/worried-users.vue'
import Reports from '../components/reports.vue'
import Users from '../components/users.vue'
import UsersAnswers from '../components/users-answers.vue'
import User from '../components/user.vue'
import Watches from '../components/watches.vue'
import WatchToggle from '../components/watch-toggle.vue'
import UserMentorMemo from '../components/user_mentor_memo.vue'
import Talks from '../components/talks.vue'

const mounter = new VueMounter()
mounter.addComponent(Hello)
mounter.addComponent(AdminCompanies)
mounter.addComponent(Announcements)
mounter.addComponent(Books)
mounter.addComponent(Pages)
mounter.addComponent(Questions)
mounter.addComponent(WorriedUsers)
mounter.addComponent(Reports)
mounter.addComponent(Users)
mounter.addComponent(UsersAnswers)
mounter.addComponent(User)
mounter.addComponent(Watches)
mounter.addComponent(WatchToggle)
mounter.addComponent(UserMentorMemo)
mounter.addComponent(Talks)
mounter.mount()

// Support component names relative to this directory:
const componentRequireContext = require.context('components', true)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)
