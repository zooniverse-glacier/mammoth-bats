config = require './config'

extractToken = (hash) ->
  match = hash.match(/access_token=(\w+)/)
  !!match && match[1]

fetch(config.host + '/me', {
  method: 'GET'
  headers:
    'Authorization': 'Bearer ' + extractToken window.location.hash
    'Accept': 'application/json'
  })
  .then (user) ->
    console.log user
  .catch (error) ->
    console.log error
