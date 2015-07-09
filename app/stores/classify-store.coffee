Reflux = require 'reflux'
counterpart = require 'counterpart'
{api} = require '../api/bats-client'
classifyActions = '../actions/classify-actions'

ClassifyStore = Reflux.createStore
  listenables: classifyActions

  project: {}
  data:
    workflow: {}
    subject: {}
    classification: {}

  init: ->
    @getProject()

  getInitialState: ->
    data: @data

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
    workflow.get('subject_sets')
      .then ([subject_set]) =>
        subject = subject: 'subject', id: 1
        @createNewClassification(workflow, subject_set, subject)

  createNewClassification: (workflow, subjectSet, subject) ->
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