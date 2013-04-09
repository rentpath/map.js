define ['jquery', 'primedia_events', 'utils'], ($, events, utils) ->
  _read = (key) ->
    data = localStorage.getItem(key)
    value = if data? then JSON.parse(data) else null

  _write = (key, value) ->
    localStorage.setItem(key, JSON.stringify(value))

  return {
    track: ->
      key = window.location.pathname
      data = utils.getPageInfo()

      record = _read key

      if record?
        record['count']++
        _write key, record
      else
        record = data
        record['count'] = 1
        _write key, record

      record

    save: (item, value) ->
      key = window.location.pathname
      data = utils.getPageInfo(key)

      record = _read key

      if record?
        record[item] = value
        _write key, record
      else
        record = data
        record[item] = value
        _write key, record

      record

    peek: (item) ->
      v = _read(window.location.pathname)
      return if v[item]? then parseInt(v[item]) else 0

    number_of_visits: ->
      v = _read(window.location.pathname).count
      return if v? then parseInt(v) else 0

    refinements: ->
      _read(window.location.pathname).nodes

    number_of_refinements: ->
      r = _read(window.location.pathname).nodes.length
      return if r? then parseInt(r) else 0

    type: ->
      _read(window.location.pathname).type

    searchType: ->
      _read(window.location.pathname).searchType



  }
