React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
_ = require 'underscore'
classnames = require 'classnames'

counterpart = require 'counterpart'
Translate = require 'react-translate-component'

Reflux = require 'reflux'
classifyStore = require '../../stores/classify-store'
classifyActions = require '../../actions/classify-actions'

counterpart.registerTranslations 'en',
  task:
    buttons:
      next: "next question"
      finish: "finished!"
      nextVideo: "next video"
    summary:
      firstTask: "You saw %(number)s %(batNoun)s."
      secondTask: "Doing %(secondTaskPossessive)s activities:"
      thirdTask: "Near %(thirdTaskPossessive)s:"
      batSingular: "bat"
      batPlural: "bats"
      this: "this"
      these: "these"

module.exports = React.createClass
  displayName: 'Task'

  getInitialState: ->
    currentTask: null
    nextTask: "T2"
    numberInput: "0"

  componentDidMount: ->
    @setState currentTask: @props.firstTask

  showTask: (nextTask) ->
    if @state.currentTask is "T0"
      @props.storeSelection(@props.workflow.tasks["T0"].question, @state.numberInput, @state.currentTask)
      if @state.numberInput is "0"
        @props.storeSelection(@props.workflow.tasks["T1"].question, "N/A", "T1")

    @setState({
      currentTask: nextTask
      nextTask: null}, -> @props.clearMultipleSelection())

  onClickProgressBarButton: (selectedTask) ->
    index = selectedTask.slice(1)
    nextTask = @determineNextTask(selectedTask, index)

    @setState({
      currentTask: selectedTask
      nextTask: nextTask}, -> @reloadAnnotations(selectedTask, index))

  determineNextTask: (selectedTask, index) ->
    if selectedTask is "T0"
      selectedNextTask = ""
      for answer in @props.workflow.tasks[selectedTask].answers
        if answer.label is @props.annotations[index].value.toString()
          selectedNextTask = answer.next
      selectedNextTask
    else
      @props.workflow.tasks[selectedTask].next

  reloadAnnotations: (selectedTask, index) ->
    inputs = React.findDOMNode(@).querySelectorAll 'input'

    for input in inputs
      for annotation in @props.annotations[index].value
        input.checked = true if input.value is annotation

  handleClick: (question, answer, taskType, nextTask, event) ->
    if @state.currentTask is Object.keys(@props.workflow.tasks)[Object.keys(@props.workflow.tasks).length - 1] #last task
      @setState nextTask: "summary"
    else
      @setState nextTask: nextTask

    if taskType is "multiple"
      @props.storeMultipleSelection(question, answer, @state.currentTask)
      @setOptionsState(event.target) if @state.currentTask is "T2" # Add animal step
    else if taskType is "single"
      @props.storeSelection(question, answer, @state.currentTask)

  onClickMinus: ->
    numberInput = @state.numberInput

    if numberInput is "0"
      numberInput
    else if numberInput is "5+"
      numberInput = "4"
    else
      numberInput--

    @setState numberInput: numberInput, -> @getNextTask()

  onClickPlus: ->
    numberInput = @state.numberInput

    if numberInput is 4
      numberInput = "5+"
    else if numberInput is "5+"
      numberInput
    else
      numberInput++

    @setState numberInput: numberInput, -> @getNextTask()

  getNextTask: ->
    nextTask = ''
    numberInput = @state.numberInput.toString()

    for answer in @props.workflow.tasks[@state.currentTask].answers
      if numberInput is answer.label
        nextTask = answer.next

    @setState nextTask: nextTask, -> console.log 'state', @state

  setOptionsState: (checkedSelection) ->
    inputs = React.findDOMNode(@).querySelectorAll('input')

    if checkedSelection.value is "None"
      for input in inputs
        if checkedSelection.checked is true
          unless input.checked is true
            @disableInput(input)
        else
          @enableInput(input)
    else
      for input in inputs
        if checkedSelection.checked is true
          if input.value is "None"
            @disableInput(input)
        else
          if @props.annotations[2].value.length is 0
            @enableInput(input)
          else
            if input.value is "None"
              @disableInput(input)

  disableInput: (input) ->
    input.disabled = true
    input.parentNode.classList.add 'disabled'

  enableInput: (input) ->
    input.disabled = false
    input.parentNode.classList.remove 'disabled'

  onClickFinish: (summary) ->
    console.log 'finished!'
    classifyActions.finishClassification()
    @showTask(summary)
    @props.clearMultipleSelection()

  resetNumberInput: ->
    @setState numberInput: "0"

  render: ->
    task = @props.workflow.tasks[@state.currentTask]
    <ReactCSSTransitionGroup transitionName="task-fade" transitionAppear={true}>
      {if @state.currentTask?
        if @state.currentTask isnt 'summary'
          <div className="task">
            <p className="question">{task.question}</p>
            <ProgressBar currentTask={@state.currentTask} onClickProgressBarButton={@onClickProgressBarButton} annotations={@props.annotations} />
            {switch task.type
              when "multiple"
                <div className="task-checkbox-container">
                  {for answer in task.answers
                    <label key={answer.label} className="task-checkbox">
                      <input type="checkbox" name={task.question} value={answer.label} onClick={@handleClick.bind(null, task.question, answer.label, task.type, task.next)} />
                      {answer.label}
                    </label>}
                </div>
              when "single"
                <fieldset>
                  <button type="button" className="minus-button" value="-" onClick={@onClickMinus}>-</button>
                  <input ref="numberInput" type="text" className="number-input" readOnly value={@state.numberInput} />
                  <button type="button" className="plus-button" value="+" onClick={@onClickPlus}>+</button>
                </fieldset>
            }
            {unless @state.currentTask is Object.keys(@props.workflow.tasks).pop()
              <div className="workflow-action">
                <p className="help-text">{task.help}</p>
                <button ref="nextButton" className="action-button" type="button" onClick={@showTask.bind(null, @state.nextTask)} disabled={@state.currentTask is "T1" and (!@props.annotations[1].value? or @props.annotations[1].value?.length is 0)}>
                  <Translate content="task.buttons.next" />
                </button>
              </div>
            else
              <div className="workflow-action">
                <button ref="finishButton" className="action-button" type="button" onClick={@onClickFinish.bind(null, @state.nextTask)} disabled={!@props.annotations[2].value? or @props.annotations[2].value?.length is 0}>
                  <Translate content="task.buttons.finish" />
                </button>
              </div>
            }
          </div>
        else
          <Summary annotations={@props.annotations} showTask={@showTask} firstTask={@props.firstTask} resetNumberInput={@resetNumberInput} />
      }
    </ReactCSSTransitionGroup>

ProgressBar = React.createClass
  displayName: "ProgressBar"

  render: ->
    disabledCondition = @props.currentTask is "summary"

    taskOneClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is "T0"
      done: @props.currentTask isnt "T0" and @props.annotations[0].value?

    taskTwoClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is "T1"
      done: @props.currentTask isnt "T1" and @props.annotations[1].value?
      skip: @props.annotations[1].value? is "N/A"

    taskThreeClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTaks is "T2"
      done: @props.currentTask isnt "T2" and @props.annotations[2].value?

    <div className="progress-bar">
      <div ref="taskOne" className={taskOneClasses}>
        <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, "T0")} disabled={disabledCondition}>
          {unless @props.annotations[0].value?
            "1"
          else
            <img src="./assets/checkmark.svg" alt="checkmark" />}
        </button>
      </div>
      <div ref="taskTwo" className={taskTwoClasses}>
        {if @props.currentTask is "T1" or @props.annotations[1].value?
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, "T1")} disabled={disabledCondition}>
            {unless @props.annotations[1].value?
              "2"
            else
              <img src="./assets/checkmark.svg" alt="checkmark" />}
          </button>}
      </div>
      <div ref="taskThree" className={taskThreeClasses}>
        {if @props.currentTask is "T2" or @props.annotations[2].value?
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, "T2")} disabled={disabledCondition}>
            {unless @props.annotations[2].value?
              "3"
            else
              <img src="./assets/checkmark.svg" alt="checkmark" />}
          </button>}
      </div>
    </div>

Summary = React.createClass
  displayName: "Summary"

  onClickNextVideo: ->
    console.log 'get next subject'
    classifyActions.saveClassification()
      .then =>
        @props.showTask(@props.firstTask)
        @props.resetNumberInput()

  render: ->
    batNoun =
      if @props.annotations[0].value is 0
        counterpart "task.summary.batPlural"
      else if @props.annotations[0].value is 1
        counterpart "task.summary.batSingular"
      else
        counterpart "task.summary.batPlural"

    secondTaskPossessive =
      if @props.annotations[1].length is 1
        counterpart "task.summary.this"
      else
        counterpart "task.summary.these"

    thirdTaskPossessive =
      if @props.annotations[2].length is 1
        counterpart "task.summary.this"
      else
        counterpart "task.summary.these"

    <div className="task-summary">
      <p>
        <Translate number={@props.annotations[0].value} batNoun={batNoun} content="task.summary.firstTask" />
      </p>
      {unless @props.annotations[1].value is "N/A"
        <p>
          <Translate secondTaskPossessive={secondTaskPossessive} content="task.summary.secondTask" />
          <ul>
            {for activity, i in @props.annotations[1].value
              <li key={i}>{activity}</li>
            }
          </ul>
        </p>}
      <p>
        <Translate thirdTaskPossessive={thirdTaskPossessive} content="task.summary.thirdTask" />
        <ul>
          {for animal, i in @props.annotations[2].value
            <li key={i}>{animal}</li>
          }
        </ul>
      </p>
      <div>TO DO: favorite button, social media buttons</div>
      <div className="workflow-action">
        <button ref="nextVideoButton" className="action-button" type="button" onClick={@onClickNextVideo}>
          <Translate content="task.buttons.nextVideo" />
        </button>
      </div>
    </div>