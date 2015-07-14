Reflux = require 'reflux'
counterpart = require 'counterpart'
_ = require 'underscore'
{api} = require '../api/bats-client'
classifyActions = require '../actions/classify-actions'

ClassifyStore = Reflux.createStore
  listenables: classifyActions

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
        workflow.get('subject_sets').then ([subject_sets]) =>
          console.log subject_sets.id
          @getSubject(workflow, subject_sets.id)

  getSubject: (workflow, subjectSetID) ->
    randomInt = Math.floor(Math.random() * 20) #random num 0-19

    api.type('subjects').get(workflow_id: workflow.id, subject_set_id: subjectSetID)
      .then (subjects) =>
        console.log 'subjects', subjects, subjects[randomInt]
        subject = subjects[randomInt]
        @createNewClassification(workflow, subject)

  createNewClassification: (workflow, subject) ->
    classification = api.type('classification').create
      annotations: {}
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

  onUpdateAnnotation: (answer) ->
    annotations = @data?.classification.annotations

    _.extend annotations, answer
    console.log 'update annotation', annotations

    @trigger @data

  finishClassification: ->
    @data?.classification.update
      completed: true
      'metadata.finished_at': (new Date).toISOString()
      'metadata.viewport':
        width: innerWidth
        height: innerHeight

    @saveClassification()

  saveClassification: ->
    @data?.classification.save().then (classification) ->
      console.log 'saved', classification
      classification.destroy()
      @getSubject(@data?.workflow)

module.exports = ClassifyStore