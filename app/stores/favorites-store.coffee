Reflux = require 'reflux'
projectConfig = require '../lib/project-config'
classifyStore = require '../stores/classify-store'
{api} = require '../api/bats-client'

module.exports = Reflux.createStore
  init: ->
    @listenTo classifyStore, @getFavorites

  getInitialState: ->
    @favorited

  getFavorites: ->
    query =
      project_id: projectConfig.projectId
      favorite: true

    api.type('collections').get(query)
      .then ([favorites]) =>
        console.log 'favorites', favorites
        @favorites = if favorites? then favorites else null
        @getSubjectInCollection(@favorites)

  getSubjectInCollection: (favorites) ->
    @subjectID = classifyStore.data.subject.id
    if favorites?
      favorites.get('subjects', id: @subjectID)
        .then ([subject]) ->
          @favorited = subject?

  createFavorites: ->
    project = projectConfig.projectId
    display_name = "Favorites #{project}"
    console.log 'display_name', display_name
    subjects = [@subjectID]
    favorite = true

    links = {subjects}
    links.project = project
    collection = {favorite, display_name, links}

    api.type('collections').create(collection).save().then =>
      console.log 'favorites created'
      @favorited = true
      @trigger @favorited

  removeSubjectFrom: ->
    console.log 'removeSubjectFrom'
    @favorites.removeLink('subjects', @subjectID.toString())
    @trigger @favorited

  addSubjectTo: ->
    console.log @subjectID.toString()
    @favorites.addLink('subjects', @subjectID.toString())
    @trigger @favorited

  toggleFavorite: ->
    console.log 'toggling favorites', @favorites
    if not @favorites?
      console.log 'no existing favorites'
      @createFavorites()
    else if @favorited
      console.log 'remove from favorites'
      @removeSubjectFrom()
    else
      console.log 'add to favorites'
      @addSubjectTo()
