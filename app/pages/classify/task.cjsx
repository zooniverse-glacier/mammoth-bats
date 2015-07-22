React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
_ = require 'underscore'
classnames = require 'classnames'

counterpart = require 'counterpart'
Translate = require 'react-translate-component'

Reflux = require 'reflux'
classifyStore = require '../../stores/classify-store'
classifyActions = require '../../actions/classify-actions'

workflowTaskKeys = require '../../lib/workflow-task-keys'

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
    currentTask: workflowTaskKeys.first

  componentDidMount: ->
    @showTask @props.task

  showTask: (task) ->
    if @state.currentTask is workflowTaskKeys.first
      firstTaskAnnotation = classifyStore.getAnnotationByKey(workflowTaskKeys.first).value
      if firstTaskAnnotation.toString() is "0"
        @props.storeSelection workflowTaskKeys.second, "N/A"

    @setState currentTask: task

  onClickProgressBarButton: (selectedTask) ->
    @setState currentTask: selectedTask

  determineNextTask: (selectedTask) ->
    if selectedTask is workflowTaskKeys.first
      annotation = _.find @props.annotations, (annotation) ->
        annotation.key is workflowTaskKeys.first

      for answer in @props.workflow.tasks[workflowTaskKeys.first].answers
        break if answer?.label?.toString() is annotation?.value.toString()

      answer.next
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
      @props.storeMultipleSelection @state.currentTask, answer
      @setOptionsState(event.target) if @state.currentTask is workflowTaskKeys.third # Add animal step
    else if taskType is "single"
      @props.storeSelection @state.currentTask, answer

  onClickMinus: ->
    numberInput = classifyStore.getAnnotationByKey(workflowTaskKeys.first).value.toString()

    if numberInput is "0"
      numberInput
    else if numberInput is "5+"
      numberInput = "4"
    else
      numberInput--

    @props.storeSelection workflowTaskKeys.first, numberInput

  onClickPlus: ->
    numberInput = classifyStore.getAnnotationByKey(workflowTaskKeys.first).value.toString()

    if numberInput is "4"
      numberInput = "5+"
    else if numberInput is "5+"
      numberInput
    else
      numberInput++

    @props.storeSelection workflowTaskKeys.first, numberInput

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

  onClickFinish: ->
    classifyActions.finishClassification()
    @showTask 'summary'

  onClickNextVideo: ->
    classifyActions.getNextSubject()
    @showTask workflowTaskKeys.first

  render: ->
    task = @props.workflow.tasks[@state.currentTask]

    <ReactCSSTransitionGroup transitionName="task-fade" transitionAppear={true}>
      {if @state.currentTask?
        if @state.currentTask isnt 'summary'
          <div className="task">
            <p className="question">{task.question}</p>
            <ProgressBar
              currentTask={@state.currentTask}
              onClickProgressBarButton={@onClickProgressBarButton}
              annotations={@props.annotations} />
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
                firstTaskAnnotation = classifyStore.getAnnotationByKey workflowTaskKeys.first

                <fieldset>
                  <button type="button" className="minus-button" value="-" onClick={@onClickMinus}>-</button>
                  <input ref="numberInput" type="text" className="number-input" readOnly value={firstTaskAnnotation.value} />
                  <button type="button" className="plus-button" value="+" onClick={@onClickPlus}>+</button>
                </fieldset>
            }
            {unless @state.currentTask is workflowTaskKeys.third
              secondTaskAnnotation = classifyStore.getAnnotationByKey workflowTaskKeys.second

              <div className="workflow-action">
                <p className="help-text">{task.help}</p>
                <button ref="nextButton" className="action-button" type="button" onClick={@showTask.bind(null, @determineNextTask(@state.currentTask))} disabled={@state.currentTask is workflowTaskKeys.second and (!secondTaskAnnotation.value? or secondTaskAnnotation.value?.length is 0)}>
                  <Translate content="task.buttons.next" />
                </button>
              </div>
            else
              <div className="workflow-action">
                <button ref="finishButton" className="action-button" type="button" onClick={@onClickFinish} disabled={!@props.annotations[2].value? or @props.annotations[2].value?.length is 0}>
                  <Translate content="task.buttons.finish" />
                </button>
              </div>
            }
          </div>
        else
          <Summary
            annotations={@props.annotations}
            onClickNextVideo={@onClickNextVideo} />
      }
    </ReactCSSTransitionGroup>

ProgressBar = React.createClass
  displayName: "ProgressBar"

  render: ->
    disabledCondition = @props.currentTask is "summary"

    taskOneClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is workflowTaskKeys.first
      done: @props.currentTask isnt workflowTaskKeys.first and @props.annotations[0].value?

    taskTwoClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is workflowTaskKeys.second
      done: @props.currentTask isnt workflowTaskKeys.second and @props.annotations[1].value?
      skip: @props.annotations[1].value? is "N/A"

    taskThreeClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTaks is workflowTaskKeys.third
      done: @props.currentTask isnt workflowTaskKeys.third and @props.annotations[2].value?

    <div className="progress-bar">
      <div ref="taskOne" className={taskOneClasses}>
        <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.first)} disabled={disabledCondition}>
          {unless @props.annotations[0].value?
            "1"
          else
            <img src="./assets/checkmark.svg" alt="checkmark" />}
        </button>
      </div>
      <div ref="taskTwo" className={taskTwoClasses}>
        {if @props.currentTask is workflowTaskKeys.second or @props.annotations[1].value?
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.second)} disabled={disabledCondition}>
            {unless @props.annotations[1].value?
              "2"
            else
              <img src="./assets/checkmark.svg" alt="checkmark" />}
          </button>}
      </div>
      <div ref="taskThree" className={taskThreeClasses}>
        {if @props.currentTask is workflowTaskKeys.third or @props.annotations[2].value?
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.third)} disabled={disabledCondition}>
            {unless @props.annotations[2].value?
              "3"
            else
              <img src="./assets/checkmark.svg" alt="checkmark" />}
          </button>}
      </div>
    </div>

Summary = React.createClass
  displayName: "Summary"

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
        <button ref="nextVideoButton" className="action-button" type="button" onClick={@props.onClickNextVideo}>
          <Translate content="task.buttons.nextVideo" />
        </button>
      </div>
    </div>
