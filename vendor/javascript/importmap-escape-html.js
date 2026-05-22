// escape-html@1.0.3 downloaded from https://ga.jspm.io/npm:escape-html@1.0.3/index.js

var a={};var e=/["'&<>]/;a=escapeHtml;function escapeHtml(a){var r=""+a;var t=e.exec(r);if(!t)return r;var c;var s="";var n=0;var u=0;for(n=t.index;n<r.length;n++){switch(r.charCodeAt(n)){case 34:c="&quot;";break;case 38:c="&amp;";break;case 39:c="&#39;";break;case 60:c="&lt;";break;case 62:c="&gt;";break;default:continue}u!==n&&(s+=r.substring(u,n));u=n+1;s+=c}return u!==n?s+r.substring(u,n):s}var r=a;export default r;

