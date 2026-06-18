// prismjs/components/prism-erb@1.30.0 downloaded from https://ga.jspm.io/npm:prismjs@1.30.0/components/prism-erb.js

(function(e){e.languages.erb={delimiter:{pattern:/^(\s*)<%=?|%>(?=\s*$)/,lookbehind:true,alias:"punctuation"},ruby:{pattern:/\s*\S[\s\S]*/,alias:"language-ruby",inside:e.languages.ruby}};e.hooks.add("before-tokenize",(function(n){var a=/<%=?(?:[^\r\n]|[\r\n](?!=begin)|[\r\n]=begin\s(?:[^\r\n]|[\r\n](?!=end))*[\r\n]=end)+?%>/g;e.languages["markup-templating"].buildPlaceholders(n,"erb",a)}));e.hooks.add("after-tokenize",(function(n){e.languages["markup-templating"].tokenizePlaceholders(n,"erb")}))})(Prism);var e={};export{e as default};

