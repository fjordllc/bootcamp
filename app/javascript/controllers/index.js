import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
import { application } from 'controllers/application'

eagerLoadControllersFrom('controllers', application)
