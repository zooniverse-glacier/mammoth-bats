Reflux = require 'reflux'
counterpart = require 'counterpart'
{api} = require '../api/bats-client'
classifyActions = '../actions/classify-actions'

ClassifyStore = Reflux.createStore
  listenables: [classifyActions]

  init: ->
    @getProject()

  getInitialState: ->
    @data

  getProject: ->
    api.type('projects').get('865')
      .then (batProject) =>
        @project = batProject
        @getWorkflow(batProject)

  getWorkflow: (project) ->
    project.get('workflows')
      .then ([workflow]) =>
        @getSubject(workflow)

  getSubject: (workflow) ->
    randomInt = Math.floor(Math.random() * 4) #random num 0-3, temporarily only 4 subjects atm

    api.type('subjects').get(workflow_id: workflow.id, sort: 'queued')
      .then (subjects) =>
        subject = subjects[randomInt]
        @createNewClassification(workflow, subject)

  createNewClassification: (workflow, subject) ->
    classification = api.type('classification').create
      annotations: []
      metadata:
        workflow_version: workflow.version
        started_at: (new Date).toISOString()
        user_agent: navigator.userAgent
        user_language: counterpart.getLocale()
        utc_offset: ((new Date).getTimezoneOffset() * 60).toString()
      links:
        project: @project.id
        workflow: workflow.id
        subjects: [subject.id]

    @createStore(workflow, classification, subject)

  createStore: (workflow, classification, subject) ->
    @data =
      workflow: workflow
      subject: subject
      classification: classification

    @trigger @data


module.exports = ClassifyStore