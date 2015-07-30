Reflux = require 'reflux'
{client, api} = client = require '../api/bats-client'
userActions = require '../actions/user-actions'

checkStatus = (response) ->
  if response.status >= 200 && response.status < 300
    return response
  else
    error = new Error response.statusText
    error.response = response
    throw error

parseJson = (response) ->
  response.json()

extractToken = (hash) ->
  match = hash.match(/access_token=(\w+)/)
  if !!match && match[1]
    match[1]
  else
    null

module.exports = Reflux.createStore
  listenables: userActions

  init: ->
    if token = @_tokenExists()
      @_setupAuth token

    @getUser()

  getInitialState: ->
    @user

  getUser: ->
    token = @_getToken()

    fetch(api.root + '/me', {
      method: 'GET'
      headers:
        'Authorization': 'Bearer ' + token
        'Accept': 'Accept: application/vnd.api+json; version=1'
      })
      .then checkStatus
      .then parseJson
      .then (data) =>
        @user = data.users[0]
        @trigger @user
      .catch (error) =>
        @user = null
        @trigger @user

  signInUrl: (location = null) ->
    location ?= window.location

    client.host + '/oauth/authorize' +
      "?response_type=token" +
      "&client_id=#{ client.appID }" +
      "&redirect_uri=#{ location }"

  onSignOut: ->
    @_removeToken()
    @getUser()

  _setupAuth: (token) ->
    api.headers['Authorization'] = 'Bearer ' + token
    localStorage.setItem 'bearer_token', token

  _tokenExists: ->
    extractToken(window.location.hash) || localStorage.getItem('bearer_token')

  _getToken: ->
    token = null
    token ?= localStorage.getItem 'bearer_token'
    token ?= extractToken window.location.hash

    token

  _setToken: (token) ->
    api.headers['Authorization'] = 'Bearer ' + token
    localStorage.setItem 'bearer_token', token

  _removeToken: ->
    api.headers['Authorization'] = null
    localStorage.removeItem 'bearer_token'

