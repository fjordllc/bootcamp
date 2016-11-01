_ = require 'underscore'

# Checkbox replacement logic.
#

checkboxReplace = (md, options, Token) ->
  "use strict"

  arrayReplaceAt = md.utils.arrayReplaceAt
  lastId = 0
  defaults =
    divWrap: false
    divClass: 'checkbox'
    idPrefix: 'checkbox'

  options = _.extend defaults, options
  pattern = /\[(X|\s|\_|\-)\]\s(.*)/i


  createTokens = (checked, label, Token) ->
    nodes = []
    ###*
    # <div class="checkbox">
    ###
    if options.divWrap
      token = new Token("checkbox_open", "div", 1)
      token.attrs = [["class",options.divClass]]
      nodes.push token

    ###*
    # <input type="checkbox" id="checkbox{n}" checked="true">
    ###
    id = options.idPrefix + lastId
    lastId += 1
    token = new Token("checkbox_input", "input", 0)
    token.attrs = [["type","checkbox"],["id",id]]
    if(checked == true)
      token.attrs.push ["checked","true"]
    nodes.push token

    ###*
    # <label for="checkbox{n}">
    ###
    token = new Token("label_open", "label", 1)
    token.attrs = [["for",id]]
    nodes.push token

    ###*
    # content of label tag
    ###
    token = new Token("text", "", 0)
    token.content = label
    nodes.push token

    ###*
    # closing tags
    ###
    nodes.push new Token("label_close", "label", -1)
    if options.divWrap
      nodes.push new Token("checkbox_close", "div", -1)

    return nodes

  splitTextToken = (original, Token) ->

    text      = original.content
    matches   = text.match pattern

    if matches == null
      return original

    checked   = false
    value     = matches[1]
    label     = matches[2]

    if (value == "X" || value == "x")
      checked = true

    return createTokens(checked, label, Token)


  return (state) ->
    blockTokens = state.tokens
    j = 0
    l = blockTokens.length
    while j < l
      if blockTokens[j].type != "inline"
        j++
        continue
      tokens = blockTokens[j].children
      # We scan from the end, to keep position when new tags added.
      # Use reversed logic in links start/end match
      i = tokens.length - 1
      while i >= 0
        token = tokens[i]
        blockTokens[j].children = tokens = arrayReplaceAt(
          tokens, i, splitTextToken(token, state.Token)
        )
        i--
      j++
    return

  return

###global module###
module.exports = (md, options) ->
  "use strict"
  md.core.ruler.push "checkbox", checkboxReplace(md, options)
  return
