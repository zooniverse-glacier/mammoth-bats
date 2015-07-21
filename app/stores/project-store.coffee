Reflux = require 'reflux'
projectConfig = require '../lib/project-config'
userStore = require '../stores/user-store'
{api} = require '../api/bats-client'

module.exports = Reflux.createStore
  init: ->
    @listenTo userStore, @getProject

  getInitialState: ->
    project: null

  getProject: ->
    api.type('projects').get(projectConfig.projectId)
      .then (batProject) =>
        @project = batProject
        @trigger @project
