# Pin npm packages by running ./bin/importmap

pin "application", to: "importmap_application.js", preload: true
pin_all_from "app/javascript"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@notus.sh/cocooned", to: "@notus.sh--cocooned.js" # @3.0.1
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.13
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3-4
pin "@yaireo/tagify", to: "@yaireo--tagify.js" # @4.37.1
pin "ace-builds" # @1.44.0
pin "autosize" # @6.0.1
pin "chart.js" # @4.5.1
pin "chartjs-plugin-annotation" # @3.1.0
pin "chartjs-plugin-datalabels" # @2.2.0
pin "choices.js" # @11.2.3
pin "emoji-data"
pin "escape-html" # @1.0.3
pin "escape-string-regexp" # @5.0.0
pin "heic2any" # @0.0.4
pin "markdown-it" # @12.3.2
pin "markdown-it-anchor" # @9.2.0
pin "markdown-it-container" # @3.0.0
pin "markdown-it-container-figure" # @1.1.3
pin "markdown-it-emoji" # @3.0.0
pin "markdown-it-link-attributes" # @4.0.1
pin "markdown-it-regexp" # @0.4.0
pin "markdown-it-task-lists" # @2.1.1
pin "prismjs" # @1.30.0
pin "sortablejs" # @1.15.7
pin "sweetalert2" # @11.26.25
pin "textarea-markdown" # @1.7.0
pin "tributejs" # @5.1.3
pin "whatwg-fetch" # @2.0.4
pin "prismjs/components/prism-bash", to: "prismjs--components--prism-bash.js" # @1.30.0
pin "prismjs/components/prism-clike", to: "prismjs--components--prism-clike.js" # @1.30.0
pin "prismjs/components/prism-css", to: "prismjs--components--prism-css.js" # @1.30.0
pin "prismjs/components/prism-css-extras", to: "prismjs--components--prism-css-extras.js" # @1.30.0
pin "prismjs/components/prism-erb", to: "prismjs--components--prism-erb.js" # @1.30.0
pin "prismjs/components/prism-go", to: "prismjs--components--prism-go.js" # @1.30.0
pin "prismjs/components/prism-haml", to: "prismjs--components--prism-haml.js" # @1.30.0
pin "prismjs/components/prism-http", to: "prismjs--components--prism-http.js" # @1.30.0
pin "prismjs/components/prism-javascript", to: "prismjs--components--prism-javascript.js" # @1.30.0
pin "prismjs/components/prism-json", to: "prismjs--components--prism-json.js" # @1.30.0
pin "prismjs/components/prism-jsx", to: "prismjs--components--prism-jsx.js" # @1.30.0
pin "prismjs/components/prism-markdown", to: "prismjs--components--prism-markdown.js" # @1.30.0
pin "prismjs/components/prism-markup-templating", to: "prismjs--components--prism-markup-templating.js" # @1.30.0
pin "prismjs/components/prism-nginx", to: "prismjs--components--prism-nginx.js" # @1.30.0
pin "prismjs/components/prism-pug", to: "prismjs--components--prism-pug.js" # @1.30.0
pin "prismjs/components/prism-ruby", to: "prismjs--components--prism-ruby.js" # @1.30.0
pin "prismjs/components/prism-sass", to: "prismjs--components--prism-sass.js" # @1.30.0
pin "prismjs/components/prism-scss", to: "prismjs--components--prism-scss.js" # @1.30.0
pin "prismjs/components/prism-shell-session", to: "prismjs--components--prism-shell-session.js" # @1.30.0
pin "prismjs/components/prism-sql", to: "prismjs--components--prism-sql.js" # @1.30.0
pin "prismjs/components/prism-tsx", to: "prismjs--components--prism-tsx.js" # @1.30.0
pin "prismjs/components/prism-typescript", to: "prismjs--components--prism-typescript.js" # @1.30.0
pin "prismjs/components/prism-yaml", to: "prismjs--components--prism-yaml.js" # @1.30.0
