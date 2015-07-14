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
      next: "next"
      finish: "finished!"

Task = React.createClass
  displayName: 'Task'

  getInitialState: ->
    currentTask: null
    nextTask: null

  componentDidMount: ->
    @setState currentTask: @props.firstTask

  showTask: (nextTask) ->
    @setState({
      currentTask: nextTask
      nextTask: null}, -> @props.clearMultipleSelection())

  handleClick: (question, answer, taskType, nextTask, event) ->
    @setState nextTask: nextTask

    if taskType is "multiple"
      @props.storeMultipleSelection(question, answer)
      @setOptionsState(event.target) if @state.currentTask is "T2" # Add animal step
    else if taskType is "single"
      @props.storeSelection(question, answer)

  setOptionsState: (checkedSelection) ->
    inputs = React.findDOMNode(@).querySelectorAll('input')

    if checkedSelection.value is "None"
      for input in inputs
        if checkedSelection.checked is true
          input.disabled = true unless input.checked is true
        else
          input.disabled = false
    else
      for input in inputs
        if checkedSelection.checked is true
          input.disabled = true if input.value is "None"
        else
          if @props.annotations[@state.currentTask].length is 0
            input.disabled = false if input.value is "None"
          else
            input.disabled = true if input.value is "None"

  onClickFinish: ->
    console.log 'finished!'
    classifyActions.finishClassification()
    @props.clearMultipleSelection()

  render: ->
    task = @props.workflow.tasks[@state.currentTask]
    <ReactCSSTransitionGroup transitionName="task-fade" transitionAppear={true}>
      {if @state.currentTask?
        <div className="task">
          <h3>{task.question}</h3>
          {for answer in task.answers
            switch task.type
              when "multiple"
                <label key={answer.label} className="task-checkbox">
                  <input type="checkbox" name={task.question} value={answer.label} onClick={@handleClick.bind(null, @state.currentTask, answer.label, task.type, task.next)} />
                  {answer.label}
                </label>
              when "single"
                <button key={answer.label} type="button" className="task-button" value={answer.label} onClick={@handleClick.bind(null, @state.currentTask, answer.label, task.type, answer.next)}>
                  {answer.label}
                </button>
          }
          {unless @state.currentTask is Object.keys(@props.workflow.tasks).pop()
            <button ref="nextButton" className="action-button" type="button" onClick={@showTask.bind(null, @state.nextTask)} disabled={@props.annotations["T1"]?.length is 0 or !@props.annotations.hasOwnProperty(@state.currentTask)}>
              <Translate content="classifyPage.buttons.next" />
            </button>
          else
            <button ref="finishButton" className="action-button" type="button" onClick={@onClickFinish} disabled={@props.annotations["T2"]?.length is 0 or !@props.annotations.hasOwnProperty(@state.currentTask)}>
              <Translate content="classifyPage.buttons.finish" />
            </button>
          }
      </div>}
    </ReactCSSTransitionGroup>

module.exports = React.createClass
  displayName: "Classify"
  mixins: [Reflux.ListenerMixin, Reflux.connect(classifyStore, "classificationData")]

  getInitialState: ->
    firstTask: null
    multipleSelectionAnswers: []

  componentDidMount: ->
    @listenTo classifyStore, (classificationData) ->
      @setState firstTask: classificationData?.workflow?.first_task

  storeMultipleSelection: (currentTask, answer) ->
    currentAnswers = @state.multipleSelectionAnswers
    index = currentAnswers.indexOf(answer)

    if index > -1
      currentAnswers.splice index, 1
      @setState({multipleSelectionAnswers: currentAnswers}, ->
        @storeSelection(currentTask, @state.multipleSelectionAnswers))
    else
      currentAnswers.push answer
      @setState({multipleSelectionAnswers: currentAnswers}, ->
        @storeSelection(currentTask, @state.multipleSelectionAnswers))

  storeSelection: (currentTask, answer) ->
    console.log 'store selection', currentTask, answer

    classifyActions.updateAnnotation("#{currentTask}": answer)

  clearMultipleSelection: ->
    @setState multipleSelectionAnswers: []

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
            {if @state.classificationData?.workflow?.tasks? and @state.firstTask?
              <div className="task-container">
                <Task
                  firstTask={@state.firstTask}
                  workflow={@state.classificationData?.workflow}
                  annotations={@state.classificationData?.classification.annotations}
                  storeSelection={@storeSelection}
                  storeMultipleSelection={@storeMultipleSelection}
                  clearMultipleSelection={@clearMultipleSelection}
                />
              </div>
            else
              <div style={display: 'flex', justifyContent: 'center', alignItems: 'center'}>
                <LoadingIndicator />
              </div>
            }
          </section>
        </div>
    </div>
