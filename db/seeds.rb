require 'seed_helper'

include SeedHelper

User.delete_all
Practice.delete_all

import_fixture 'companies'
import_fixture 'users'
import_fixture 'practices'
import_fixture 'categories'
import_fixture 'learnings'
import_fixture "reports"
