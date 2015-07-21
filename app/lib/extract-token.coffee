module.exports = (hash) ->
  match = hash.match(/access_token=(\w+)/)
  !!match && match[1]
