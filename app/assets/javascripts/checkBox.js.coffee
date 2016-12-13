$ ->
  # チェックボックス、ラジオボタンにチェックを入れたら、親要素のlabel に .is-checked を付ける
  $(":checked").parents("label").addClass "is-checked"
  $("input").click (e) ->
    t = e.target.type
    chk = $(this).prop("checked")
    name = $(this).attr("name")
    if t is "checkbox"
      if chk is true
        $(this).parents("label").addClass "is-checked"
      else
        $(this).parents("label").removeClass "is-checked"
      true
    else if t is "radio"
      if chk is true
        $(this).parents('ul').each ->
          $(this).find('label').removeClass "is-checked"
        $('input[name=" + name + "]').parents("ul label").removeClass "is-checked"
        $(this).parents('label').addClass "is-checked"
      true

  # すでにチェックが入ってるものにページ読み込みの時点で .is-checked を付ける
  $(this).find(":checked").closest("label").addClass "is-checked"

  # ラジオボタンの親要素をクリッカブルに .is-clickable も付ける
  cf = $(':radio').parent()
  cf.addClass('is-clickable')
  cf.click ->
    $(this).find(':radio').attr('is-checked', true)

  rl = $(':radio').parents("label")
  cl = $(':checkbox').parents("label")
  rl.addClass 'radio-label'
  cl.addClass 'checkbox-label'
