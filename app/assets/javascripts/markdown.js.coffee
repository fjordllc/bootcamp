$ ->
  markdown = window.markdownit(
    breaks: true
    langPrefix: 'language-'
    linkify: true
    highlight: (str, lang) ->
      if lang and hljs.getLanguage(lang)
        try
          return '<pre class="hljs"><code>' + hljs.highlight(lang, str, true).value + '</code></pre>'
        catch __
      '<pre class="hljs"><code>' + markdown.utils.escapeHtml(str) + '</code></pre>'
  ).use(markdownitEmoji)

  $('.js-markdown-input').each (i) ->
    val = $(this).val()
    html = markdown.render(val)
    parent = $(this).parents('.js-markdown-parent')
    target = $(parent).find('.js-markdown-preview')
    $(target).html html
    $('pre code').each (i, block) ->
      hljs.highlightBlock block


  $('.js-markdown-input').keyup ->
    val = $(this).val()
    html = markdown.render(val)
    parent = $(this).parents('.js-markdown-parent')
    $(parent).find('.js-markdown-preview').html html
    $('pre code').each (i, block) ->
      hljs.highlightBlock block

$(document).ready ->
  $('pre code').each (i, block) ->
    hljs.highlightBlock block
