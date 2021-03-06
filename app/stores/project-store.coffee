Reflux = require 'reflux'
projectConfig = require '../lib/project-config'
userStore = require '../stores/user-store'
{api} = require '../api/bats-client'

module.exports = Reflux.createStore
  init: ->
    @listenTo userStore, @getProject

  getInitialState: ->
    @project

  getProject: ->
    api.type('projects').get(projectConfig.projectId)
      .then (@project) =>
        @trigger @project

  getLaunchedProjects: ->
    query =
      launch_approved: true
      page_size: 35

    api.type('projects').get(query)
      .then (projects) =>
        projects
