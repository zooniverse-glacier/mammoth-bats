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
    subjects = [@subjectID]
    favorite = true

    links = {subjects}
    links.project = project
    collection = {favorite, display_name, links}

    api.type('collections').create(collection).save().then =>
      @favorited = true
      @trigger @favorited

  removeSubjectFrom: ->
    @favorites.removeLink('subjects', [@subjectID.toString()]).then =>
      @favorited = false
      @trigger @favorited

  addSubjectTo: ->
    @favorites.addLink('subjects', [@subjectID.toString()]).then =>
      @favorited = true
      @trigger @favorited

  toggleFavorite: ->
    if not @favorites?
      @createFavorites()
    else if @favorited
      @removeSubjectFrom()
    else
      @addSubjectTo()
