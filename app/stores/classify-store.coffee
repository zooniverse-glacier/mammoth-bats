Reflux = require 'reflux'
{api} = require '../api/bats-client'
classifyActions = '../actions/classify-actions'

ClassifyStore = Reflux.createStore
  listenables: classifyActions

  project: {}
  workflow: {}

  init: ->
    @getProject()

  getInitialState: ->
    workflow: @workflow

  getProject: ->
    api.type('projects').get('865')
      .then (batProject) =>
        @project = batProject
        @fetchWorkflow(batProject)

  fetchWorkflow: (project) ->
    project.get('workflows')
      .then ([projectWorkflow]) =>
        @workflow = projectWorkflow
        @trigger @workflow



module.exports = ClassifyStore