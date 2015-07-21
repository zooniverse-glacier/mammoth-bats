Reflux = require 'reflux'
{api} = client = require '../api/bats-client'
extractToken = require '../lib/extract-token'
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

module.exports = Reflux.createStore
  listenables: userActions

  init: ->
    @getUser()

  getInitialState: ->
    user: null

  getUser: ->
    token = extractToken window.location.hash

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
        api.headers['Authorization'] = 'Bearer ' + token
        @trigger @user
      .catch (error) =>
        @user = null
        @trigger @user

  signInUrl: (location = null) ->
    location ?= window.location

    api.host + '/oauth/authorize' +
      "?response_type=token" +
      "&client_id=#{ client.appID }" +
      "&redirect_uri=#{ location }"
