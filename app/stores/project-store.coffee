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
    console.log 'getting project'
    api.type('projects').get(projectConfig.projectId)
      .then (@project) =>
        @trigger @project
