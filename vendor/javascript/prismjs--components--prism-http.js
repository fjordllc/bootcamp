// prismjs/components/prism-http@1.30.0 downloaded from https://ga.jspm.io/npm:prismjs@1.30.0/components/prism-http.js

(function(e){
/**
   * @param {string} name
   * @returns {RegExp}
   */
function headerValueOf(e){return RegExp("(^(?:"+e+"):[ \t]*(?![ \t]))[^]+","i")}e.languages.http={"request-line":{pattern:/^(?:CONNECT|DELETE|GET|HEAD|OPTIONS|PATCH|POST|PRI|PUT|SEARCH|TRACE)\s(?:https?:\/\/|\/)\S*\sHTTP\/[\d.]+/m,inside:{method:{pattern:/^[A-Z]+\b/,alias:"property"},"request-target":{pattern:/^(\s)(?:https?:\/\/|\/)\S*(?=\s)/,lookbehind:true,alias:"url",inside:e.languages.uri},"http-version":{pattern:/^(\s)HTTP\/[\d.]+/,lookbehind:true,alias:"property"}}},"response-status":{pattern:/^HTTP\/[\d.]+ \d+ .+/m,inside:{"http-version":{pattern:/^HTTP\/[\d.]+/,alias:"property"},"status-code":{pattern:/^(\s)\d+(?=\s)/,lookbehind:true,alias:"number"},"reason-phrase":{pattern:/^(\s).+/,lookbehind:true,alias:"string"}}},header:{pattern:/^[\w-]+:.+(?:(?:\r\n?|\n)[ \t].+)*/m,inside:{"header-value":[{pattern:headerValueOf(/Content-Security-Policy/.source),lookbehind:true,alias:["csp","languages-csp"],inside:e.languages.csp},{pattern:headerValueOf(/Public-Key-Pins(?:-Report-Only)?/.source),lookbehind:true,alias:["hpkp","languages-hpkp"],inside:e.languages.hpkp},{pattern:headerValueOf(/Strict-Transport-Security/.source),lookbehind:true,alias:["hsts","languages-hsts"],inside:e.languages.hsts},{pattern:headerValueOf(/[^:]+/.source),lookbehind:true}],"header-name":{pattern:/^[^:]+/,alias:"keyword"},punctuation:/^:/}}};var t=e.languages;var a={"application/javascript":t.javascript,"application/json":t.json||t.javascript,"application/xml":t.xml,"text/xml":t.xml,"text/html":t.html,"text/css":t.css,"text/plain":t.plain};var r={"application/json":true,"application/xml":true};
/**
   * Returns a pattern for the given content type which matches it and any type which has it as a suffix.
   *
   * @param {string} contentType
   * @returns {string}
   */function getSuffixPattern(e){var t=e.replace(/^[a-z]+\//,"");var a="\\w+/(?:[\\w.-]+\\+)+"+t+"(?![+\\w.-])";return"(?:"+e+"|"+a+")"}var n;for(var s in a)if(a[s]){n=n||{};var i=r[s]?getSuffixPattern(s):s;n[s.replace(/\//g,"-")]={pattern:RegExp("("+/content-type:\s*/.source+i+/(?:(?:\r\n?|\n)[\w-].*)*(?:\r(?:\n|(?!\n))|\n)/.source+")"+/[^ \t\w-][\s\S]*/.source,"i"),lookbehind:true,inside:a[s]}}n&&e.languages.insertBefore("http","header",n)})(Prism);var e={};export{e as default};

