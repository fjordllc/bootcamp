require 'seed_helper'

include SeedHelper

User.delete_all
Practice.delete_all

import_fixture 'users'
import_fixture 'practices'
