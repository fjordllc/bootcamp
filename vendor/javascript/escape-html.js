var u=(c,e)=>()=>(e||c((e={exports:{}}).exports,e),e.exports);var v=u((m,i)=>{var b=/["'&<>]/;i.exports=l;function l(c){var e=""+c,n=b.exec(e);if(!n)return e;var r,s="",a=0,t=0;for(a=n.index;a<e.length;a++){switch(e.charCodeAt(a)){case 34:r="&quot;";break;case 38:r="&amp;";break;case 39:r="&#39;";break;case 60:r="&lt;";break;case 62:r="&gt;";break;default:continue}t!==a&&(s+=e.substring(t,a)),t=a+1,s+=r}return t!==a?s+e.substring(t,a):s}});export default v();
/*! Bundled license information:

escape-html/index.js:
  (*!
   * escape-html
   * Copyright(c) 2012-2013 TJ Holowaychuk
   * Copyright(c) 2015 Andreas Lubbe
   * Copyright(c) 2015 Tiancheng "Timothy" Gu
   * MIT Licensed
   *)
*/
