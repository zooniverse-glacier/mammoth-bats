React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

counterpart = require 'counterpart'
Translate = require 'react-translate-component'
LoadingIndicator = require '../components/loading-indicator'

Reflux = require 'reflux'
classifyStore = require '../stores/classify-store'
classifyActions = require '../actions/classify-actions'

counterpart.registerTranslations 'en',
  classifyPage:
    buttons:
      finish: "finished!"

Task = React.createClass
  displayName: 'Task'

  storeSelection: (answer) ->
    console.log 'answer', answer

  render: ->
    <ReactCSSTransitionGroup transitionName="task-fade" transitionAppear={true}>
      <div className="task">
          {switch @props.task.type
            when "multiple"
              for answer in @props.task.answers
                <label key={answer.label} className="task-checkbox">
                  <input type="checkbox" name={@props.task.question} value={answer.label} onClick={@storeSelection.bind(@, answer.label)} />
                  {answer.label}
                </label>
            when "single"
              for answer in @props.task.answers
                <button key={answer.label} type="button" className="task-button" value={answer.label} onClick={@storeSelection.bind(@, answer.label)}>
                  {answer.label}
                </button>
          }
      </div>
    </ReactCSSTransitionGroup>

module.exports = React.createClass
  displayName: "Classify"
  mixins: [Reflux.connect(classifyStore, "classificationData")]

  getInitialState: ->
    taskID: ''

  render: ->
    <div className="classify-page">
      <h1>Classify</h1>
        <div className="classification">
          <section className="subject">
            {if @state.classificationData?.subject?
              <img src={@state.classificationData?.subject?.locations[0]["image/gif"]} />
            else
              <div style={width: '400px', height: '400px', display: 'flex', justifyContent: 'center', alignItems: 'center'}>
                <LoadingIndicator />
              </div>
            }
          </section>
          <section className="questions-container">
            <div className="questions">
              {if @state.classificationData?.workflow?
                for taskID, task of @state.classificationData?.workflow?.tasks
                  <div key={taskID} className="task-container">
                    <button className="task-question" type="button" onClick={@showTask.bind(null, taskID)}>{task.question}</button>
                    {<Task task={task} /> if @state.taskID is taskID}
                  </div>
              else
                <div style={display: 'flex', justifyContent: 'center', alignItems: 'center'}>
                  <LoadingIndicator />
                </div>
              }
            </div>
            <button className="action-button" type="button" onClick={@finishClassification}><Translate content="classifyPage.buttons.finish" /></button>
          </section>
        </div>
    </div>

  showTask: (taskID) ->
    @setState taskID: taskID

  finishClassification: ->
    console.log 'finished!'