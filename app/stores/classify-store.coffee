Reflux = require 'reflux'
counterpart = require 'counterpart'
_ = require 'underscore'
projectConfig = require '../lib/project-config'
{api} = require '../api/bats-client'
classifyActions = require '../actions/classify-actions'
projectStore = require './project-store'

ClassifyStore = Reflux.createStore
  listenables: classifyActions

  init: ->
    @listenTo projectStore, @getWorkflow

  getInitialState: ->
    @data

  getWorkflow: (@project = null) ->
    unless @project
      return throw new Error 'cannot fetch workflows for project'

    @project.get('workflows')
      .then ([workflow]) =>
        workflow.get('subject_sets').then ([subject_sets]) =>
          @getSubject(workflow, subject_sets.id)

  getSubject: (workflow, subjectSetID) ->
    randomInt = Math.floor(Math.random() * 3) #random num 0-4

    api.type('subjects').get(workflow_id: workflow.id, subject_set_id: subjectSetID)
      .then (subjects) =>
        console.log 'subjects', subjects, subjects[randomInt]
        subject = subjects[randomInt]
        @createNewClassification(workflow, subject)

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
    console.log 'called save classification', @data.classification

    @data?.classification.save()
      .catch (response) ->
        console.log 'response', response, api.handleError(response)
        api.handleError(response)
      .then (classification) ->
        console.log 'saved', classification
        classification.destroy()
        @getSubject(@data?.workflow)

module.exports = ClassifyStore
