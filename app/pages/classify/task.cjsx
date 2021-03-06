React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
_ = require 'underscore'

counterpart = require 'counterpart'
Translate = require 'react-translate-component'

Reflux = require 'reflux'
classifyStore = require '../../stores/classify-store'
classifyActions = require '../../actions/classify-actions'

workflowTaskKeys = require '../../lib/workflow-task-keys'

FavoritesButton = require '../../components/favorites-button'
ProgressBar = require './progress-bar'

counterpart.registerTranslations 'en',
  task:
    buttons:
      next: "next question"
      finish: "finished!"
      nextVideo: "next video"
    summary:
      firstTask: "%(number)s %(batNoun)s"
      batSingular: "bat"
      batPlural: "bats"

camelize = (str) ->
  str.replace /(?:^\w|[A-Z]|\b\w)/g, (letter, index) ->
    if index is 0
      letter.toLowerCase()
    else
      letter.toUpperCase()
  .replace /\s+/g, ''

module.exports = React.createClass
  displayName: 'Task'

  getInitialState: ->
    currentTask: workflowTaskKeys.first

  componentDidMount: ->
    @showTask @state.currentTask

  showTask: (task) ->
    if @state.currentTask is workflowTaskKeys.first
      firstTaskAnnotation = classifyStore.getAnnotationByKey(workflowTaskKeys.first).value
      if firstTaskAnnotation.toString() is "0"
        @props.storeSelection workflowTaskKeys.second, []

    @setState({
      currentTask: task
      hoveringOver: null}, -> @reloadAnnotations())

  onClickProgressBarButton: (selectedTask) ->
    @setState({
      currentTask: selectedTask
      hoveringOver: null}, -> @reloadAnnotations())

  determineNextTask: (selectedTask) ->
    if selectedTask is workflowTaskKeys.first
      annotation = _.find @props.annotations, (annotation) ->
        annotation.key is workflowTaskKeys.first

      for answer in @props.workflow.tasks[workflowTaskKeys.first].answers
        break if answer?.label?.toString() is annotation?.value.toString()

      answer.next
    else
      @props.workflow.tasks[selectedTask].next

  reloadAnnotations: ->
    inputs = React.findDOMNode(@).querySelectorAll 'input'
    annotations = classifyStore.getAnnotationByKey(@state.currentTask).value if @state.currentTask isnt 'summary'

    if annotations?.length > 0
      for input in inputs
        for annotation in annotations
          if input.value is annotation
            input.checked = true
            @setOptionsState input

  handleClick: (question, answer, taskType) ->
    if taskType is "multiple"
      @props.storeMultipleSelection @state.currentTask, answer
      @setOptionsState(event.target) if @state.currentTask is workflowTaskKeys.third # Add animal step
      @forceUpdate() # Force DOM to update immediately instead of after mouseout.
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
    @props.clearClassificationData()
    classifyActions.getNextSubject()
    @showTask workflowTaskKeys.first

  handleHover: (key, e) ->
    @setState hoveringOver: key

  render: ->
    task = @props.workflow.tasks[@state.currentTask]

    <div className="tasks">
      <FieldGuide toDisplay={@state.hoveringOver} />

      {if @state.currentTask?
        if @state.currentTask isnt 'summary'
          <div className="task-individual">
            <p className="question">{task.question}</p>
            <ProgressBar
              currentTask={@state.currentTask}
              onClickProgressBarButton={@onClickProgressBarButton}
              annotations={@props.annotations} />
            {switch task.type
              when "multiple"
                <div className="task-checkbox-container">
                  {for answer in task.answers
                    <label key={answer.label} className="task-checkbox" onMouseOver={if window.innerWidth > 768 then @handleHover.bind null, camelize answer.label} onMouseOut={@handleHover.bind null, null if window.innerWidth > 768}>
                      <input type="checkbox" name={task.question} value={answer.label} onClick={@handleClick.bind(null, task.question, answer.label, task.type)} />
                      {answer.label}
                    </label>}
                </div>
              when "single"
                firstTaskAnnotation = classifyStore.getAnnotationByKey workflowTaskKeys.first
                <fieldset>
                  <button type="button" className="minus-button" value="-" onClick={@onClickMinus}>-</button>
                  <input ref="numberInput" type="text" className="number-input" readOnly value={firstTaskAnnotation.value} />
                  <button type="button" className="plus-button" value="+" onClick={@onClickPlus}>+</button>
                </fieldset>}

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
                <button ref="finishButton" className="action-button finish-button" type="button" onClick={@onClickFinish} disabled={!@props.annotations[2].value? or @props.annotations[2].value?.length is 0}>
                  <Translate content="task.buttons.finish" />
                </button>
              </div>
            }
          </div>
        else
          <div className="task-summary-container">
            <ProgressBar
              currentTask={@state.currentTask}
              onClickProgressBarButton={@onClickProgressBarButton}
              annotations={@props.annotations} />
            <Summary
              annotations={@props.annotations}
              onClickNextVideo={@onClickNextVideo}
              user={@props.user} />
          </div>}
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

    <div className="task-summary">
      <div className="task-summary-lists">
        <p>
          <i className="fa fa-check-circle-o fa-fw"></i><Translate number={@props.annotations[0].value} batNoun={batNoun} content="task.summary.firstTask" />
        </p>
        {unless @props.annotations[1].value?.length is 0
          <ul>
            {for activity, i in @props.annotations[1].value
              <li key={i} style={listStyle: "none"}><i className="fa fa-check-circle-o fa-fw"></i>{activity}</li>
            }
          </ul>}
        <ul>
          {for animal, i in @props.annotations[2].value
            <li key={i} style={listStyle: "none"}><i className="fa fa-check-circle-o fa-fw"></i>{animal}</li>
          }
        </ul>
      </div>
      <div className="workflow-action">
        <FavoritesButton user={@props.user} />
        <button ref="nextVideoButton" className="action-button next-video-button" type="button" onClick={@props.onClickNextVideo}>
          <Translate content="task.buttons.nextVideo" />
        </button>
      </div>
    </div>

fieldGuideContent = require '../../lib/field-guide-content'
FieldGuide = React.createClass
  displayName: 'FieldGuide'

  getDefaultProps: ->
    toDisplay: null

  render: ->
    <div className="field-guide">
      {if !@props.toDisplay? or @props.toDisplay is 'none'
        <img className="batman-placeholder" src="./assets/batman-placeholder.png" alt="bat icon placeholder" />}

      {if @props.toDisplay? && @props.toDisplay in Object.keys(fieldGuideContent)
        content = fieldGuideContent[@props.toDisplay]
        <p dangerouslySetInnerHTML={{__html: content}} />}
    </div>
