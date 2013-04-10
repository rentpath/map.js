define ['jquery', 'primedia_events', 'utils'], ($, events, utils) ->
  _read = (key) ->
    data = localStorage.getItem(key)
    value = if data? then JSON.parse(data) else null

  _write = (key, value) ->
    localStorage.setItem(key, JSON.stringify(value))

  return {
    key: ->
      window.location.pathname

    track: ->
      key = @key()
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
      key = @key()
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

    peek: (item, not_found=0) ->
      v = _read(@key()) || {}
      return if v[item]? then parseInt(v[item]) else not_found

    number_of_visits: -> @peek('count')

    refinements: -> @peek('nodes', [])

    number_of_refinements: -> @refinements.length

    type: -> @peek('type', '')

    searchType: -> @peek('searchType', '')

  }
