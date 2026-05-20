# Pin npm packages by running ./bin/importmap

pin "hotwire"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/request.js", to: "importmap-rails-request.js" # @0.0.12
pin "autosize", to: "importmap-autosize.js" # @4.0.2
pin "sortablejs", to: "importmap-sortablejs.js" # @1.15.0
pin "sweetalert2", to: "importmap-sweetalert2.js" # @11.1.5
