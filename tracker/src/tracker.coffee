define ['jquery', 'primedia_events', 'utils'], ($, events, utils) ->
  _read = (key) ->
    data = localStorage.getItem(key)
    if data? then JSON.parse(data) else null

  _write = (key, value) ->
    localStorage.setItem(key, JSON.stringify(value))
    value

  return {
    path: -> window.location.pathname

    path_and_query: -> window.location.pathname + window.location.search

    key: (type="refined") ->
      switch type
        when "refined" then @path()
        when "base"
          refinements = $("head meta[name='refinements']").attr('content') || ""
          @path().split(refinements).shift()

    track: ->
      count = @peek('count', 0) + 1
      @save('count', count)

    save: (item, value) ->
      key = @key()
      data = utils.getPageInfo(key)

      record = _read(key) || data
      record[item] = value
      _write key, record

      record

    peek: (item, not_found=0) ->
      v = _read(@key()) || {}
      if v[item]? then v[item] else not_found

    number_of_visits: -> @peek('count')

    refinements: -> @peek('nodes', [])

    number_of_refinements: -> @peek('nodes', []).length

    type: -> @peek('type', '')

    searchType: -> @peek('searchType', '')
  }
