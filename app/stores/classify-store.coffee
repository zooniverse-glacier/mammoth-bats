Reflux = require 'reflux'
_ = require 'underscore'
counterpart = require 'counterpart'
{api} = require '../api/bats-client'
classifyActions = require '../actions/classify-actions'
projectStore = require './project-store'
projectConfig = require '../lib/project-config'

ClassifyStore = Reflux.createStore
  listenables: classifyActions

  init: ->
    @listenTo projectStore, @getWorkflow

  getInitialState: ->
    @data

  getWorkflow: (@project = null) ->
    unless @project
      return throw new Error 'cannot fetch workflows for project'

    api.type('workflows').get projectConfig.workflowId
      .then (@workflow) =>
        @getNextSubject()

  getNextSubject: ->
    query =
      workflow_id: @workflow.id
      sort: 'queued'

    api.type('subjects').get query
      .then (subjects) =>
        if subjects.length is 0
          # handle empty subjects array
          return

        randomInt = Math.floor(Math.random() * subjects.length) #random num 0-4
        subject = subjects[randomInt]
        @createNewClassification @workflow, subject

  createNewClassification: (workflow, subject) ->
    classification = api.type('classification').create
      annotations: [
        {task: "", value: null}
        {task: "", value: null}
        {task: "", value: null}
      ]
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

    classification._workflow = workflow
    classification._subjects = [subject]

    @createStore(workflow, classification, subject)

  createStore: (workflow, classification, subject) ->
    @data =
      workflow: workflow
      subject: subject
      classification: classification

    @trigger @data

  onUpdateAnnotation: (updatedAnnotation) ->
    currentAnnotations = _.find @data?.classification.annotations, (annotation) ->
      (annotation.task is updatedAnnotation.task) or (annotation.task.length is 0)

    _.extend currentAnnotations, updatedAnnotation
    @trigger @data

  finishClassification: ->
    @data?.classification.update
      completed: true
      'metadata.finished_at': (new Date).toISOString()
      'metadata.viewport':
        width: innerWidth
        height: innerHeight

  saveClassification: ->
    @data?.classification.save()
      .then (classification) ->
        classification.destroy()
        @getSubject(@data?.workflow)
      .catch (error) ->
        console.log 'error saving c'

module.exports = ClassifyStore
