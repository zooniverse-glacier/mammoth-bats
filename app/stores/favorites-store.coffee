Reflux = require 'reflux'
projectConfig = require '../lib/project-config'
classifyStore = require '../stores/classify-store'
{api} = require '../api/bats-client'

module.exports = Reflux.createStore
  init: ->
    @listenTo classifyStore, @getFavorites

  getInitialState: ->
    @favorites

  getFavorites: ->
    query =
      project_id: projectConfig.projectId
      favorite: true

    api.type('collections').get(query)
      .then ([favorites]) =>
        console.log 'favorites', favorites
        @favorites = if favorites? then favorites else null
        @getSubjectInCollection(@favorites)
      .then =>
        @toggleFavorite()

  getSubjectInCollection: (favorites) ->
    subjectID = classifyStore.data.subject.id
    if favorites?
      favorites.get('subjects', id: subjectID)
        .then ([subject]) ->
          subject

  toggleFavorite: ->
    console.log 'TO DO: toggleFavorites'
    # if !@favorites?
    #   @createFavorites