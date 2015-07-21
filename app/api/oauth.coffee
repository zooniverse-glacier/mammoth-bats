config = require './config'

extractToken = (hash) ->
  match = hash.match(/access_token=(\w+)/)
  !!match && match[1]

fetch(config.host + '/api/me', {
  method: 'GET'
  headers:
    'Authorization': 'Bearer ' + extractToken window.location.hash
    'Accept': 'Accept: application/vnd.api+json; version=1'
  })
  .then (user) ->
    console.log user
  .catch (error) ->
    console.log error
