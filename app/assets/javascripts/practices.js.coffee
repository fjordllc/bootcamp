$ ->
  $(document).on "click", '.status.unstarted', ->
    practice_id = $(this).attr('id').split('-')[1]
    $(this).attr({ class: 'status active' })
    $(this).children().attr({ class: 'btn btn-info' }).text 'active'
    console.log('active!')
    $.ajax
      type: "post"
      url: "/practices/#{practice_id}/start"
      data:
        _method: "post"
        authenticity_token: $("meta[name=csrf-token]").attr("content")

  $(document).on "click", '.status.active', ->
    practice_id = $(this).attr('id').split('-')[1]
    $(this).attr({ class: 'status complete' })
    $(this).children().attr({ class: 'btn btn-success' }).text 'complete'
    console.log('complete!')
    $.ajax
      type: "post"
      url: "/practices/#{practice_id}/finish"
      data:
        _method: "put"
        authenticity_token: $("meta[name=csrf-token]").attr("content")

  $(document).on "click", '.status.complete', ->
    practice_id = $(this).attr('id').split('-')[1]
    $(this).attr({ class: 'status unstarted' })
    $(this).children().attr({ class: 'btn' }).text 'unstarted'
    console.log('unstarted!')
    $.ajax
      type: "post"
      url: "/practices/#{practice_id}/destroy"
      data:
        _method: "delete"
        authenticity_token: $("meta[name=csrf-token]").attr("content")
