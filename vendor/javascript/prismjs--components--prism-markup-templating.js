// prismjs/components/prism-markup-templating@1.30.0 downloaded from https://ga.jspm.io/npm:prismjs@1.30.0/components/prism-markup-templating.js

(function(e){
/**
   * Returns the placeholder for the given language id and index.
   *
   * @param {string} language
   * @param {string|number} index
   * @returns {string}
   */
function getPlaceholder(e,n){return"___"+e.toUpperCase()+n+"___"}Object.defineProperties(e.languages["markup-templating"]={},{buildPlaceholders:{
/**
       * Tokenize all inline templating expressions matching `placeholderPattern`.
       *
       * If `replaceFilter` is provided, only matches of `placeholderPattern` for which `replaceFilter` returns
       * `true` will be replaced.
       *
       * @param {object} env The environment of the `before-tokenize` hook.
       * @param {string} language The language id.
       * @param {RegExp} placeholderPattern The matches of this pattern will be replaced by placeholders.
       * @param {(match: string) => boolean} [replaceFilter]
       */
value:function(n,a,t,r){if(n.language===a){var o=n.tokenStack=[];n.code=n.code.replace(t,(function(e){if(typeof r==="function"&&!r(e))return e;var t=o.length;var l;while(n.code.indexOf(l=getPlaceholder(a,t))!==-1)++t;o[t]=e;return l}));n.grammar=e.languages.markup}}},tokenizePlaceholders:{
/**
       * Replace placeholders with proper tokens after tokenizing.
       *
       * @param {object} env The environment of the `after-tokenize` hook.
       * @param {string} language The language id.
       */
value:function(n,a){if(n.language===a&&n.tokenStack){n.grammar=e.languages[a];var t=0;var r=Object.keys(n.tokenStack);walkTokens(n.tokens)}function walkTokens(o){for(var l=0;l<o.length;l++){if(t>=r.length)break;var c=o[l];if(typeof c==="string"||c.content&&typeof c.content==="string"){var i=r[t];var g=n.tokenStack[i];var s=typeof c==="string"?c:c.content;var u=getPlaceholder(a,i);var k=s.indexOf(u);if(k>-1){++t;var f=s.substring(0,k);var p=new e.Token(a,e.tokenize(g,n.grammar),"language-"+a,g);var v=s.substring(k+u.length);var d=[];f&&d.push.apply(d,walkTokens([f]));d.push(p);v&&d.push.apply(d,walkTokens([v]));typeof c==="string"?o.splice.apply(o,[l,1].concat(d)):c.content=d}}else c.content&&walkTokens(c.content)}return o}}}})})(Prism);var e={};export{e as default};

