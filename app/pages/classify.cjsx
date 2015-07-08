React = require 'react/addons'
Reflux = require 'reflux'
classifyStore = require '../stores/classify-store'

Task = React.createClass
  displayName: 'Task'

  storeSelection: (answer) ->
    console.log answer

  render: ->
    <div className="task">
      {switch @props.task.type
        when "multiple"
          for answer in @props.task.answers
            <label key={answer.label}>
              <input type="checkbox" name={@props.task.question} value={answer.label} onClick={@storeSelection.bind(@, answer.label)} />
              {answer.label}
            </label>
        when "single"
          for answer in @props.task.answers
            <button key={answer.label} type="button" value={answer.label} onClick={@storeSelection.bind(@, answer.label)}>
              {answer.label}
            </button>
      }
    </div>

module.exports = React.createClass
  displayName: "Classify"
  mixins: [Reflux.ListenerMixin]

  getInitialState: ->
    workflow: {}
    task: ''
    subject: null

  componentDidMount: ->
    console.log @state
    @listenTo classifyStore, @setWorkflowState

  setWorkflowState: (projectWorkflow) ->
    @setState({
      workflow: projectWorkflow
      task: projectWorkflow.first_task
    }, @getSubject projectWorkflow)

  getSubject: (projectWorkflow) ->
    console.log projectWorkflow
    projectWorkflow.get('subject_sets')
      .then ([subject_set]) ->
        console.log subject_set

  render: ->
    <div className="classify-page">
      <h1>Classify</h1>
      <div className="classification">
        <section className="subject">
          <img src="http://placehold.it/400x400" />
        </section>
        <section className="questions">
          {for taskID, task of @state.workflow?.tasks
            console.log taskID, task
            <div key={taskID} className="task-container">
              <button className="task-question" type="button" onClick={@showTask.bind(null, taskID)}>{task.question}</button>
              <div className="task"><Task taskID={taskID} task={task} /></div>
            </div>
          }
        </section>
      </div>
    </div>

  showTask: (task) ->
    console.log task