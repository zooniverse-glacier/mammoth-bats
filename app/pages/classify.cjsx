React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
_ = require 'underscore'

counterpart = require 'counterpart'
Translate = require 'react-translate-component'
LoadingIndicator = require '../components/loading-indicator'

Reflux = require 'reflux'
classifyStore = require '../stores/classify-store'
classifyActions = require '../actions/classify-actions'

counterpart.registerTranslations 'en',
  classifyPage:
    buttons:
      next: "next question"
      finish: "finished!"
    help:
      playback: "playback speed"

Task = React.createClass
  displayName: 'Task'

  getInitialState: ->
    currentTask: null
    nextTask: "T2"
    numberInput: "0"

  componentDidMount: ->
    @setState currentTask: @props.firstTask

  showTask: (nextTask) ->
    if @state.currentTask is "T0"
      @props.storeSelection(@state.currentTask, @state.numberInput)
      if @state.numberInput is "0"
        @props.storeSelection("T1", "N/A")

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
          <p className="question">{task.question}</p>
          {switch task.type
            when "multiple"
              for answer in task.answers
                <label key={answer.label} className="task-checkbox">
                  <input type="checkbox" name={task.question} value={answer.label} onClick={@handleClick.bind(null, @state.currentTask, answer.label, task.type, task.next)} />
                  {answer.label}
                </label>
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
              <button ref="nextButton" className="action-button" type="button" onClick={@showTask.bind(null, @state.nextTask)} disabled={@state.currentTask is "T1" and (@props.annotations["T1"]?.length is 0 or !@props.annotations.hasOwnProperty("T1"))}>
                <Translate content="classifyPage.buttons.next" />
              </button>
            </div>
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
    playbackRate: 1

  componentDidMount: ->
    @listenTo classifyStore, (classificationData) ->
      @setState firstTask: classificationData?.workflow?.first_task

  onClickPlaybackRateButton: ({currentTarget}) ->
    subjectVideo = React.findDOMNode(@refs.subjectVideo)
    playbackRate = currentTarget.value
    subjectVideo.playbackRate = playbackRate

    @setState playbackRate: parseFloat(playbackRate)

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
    classifyActions.updateAnnotation("#{currentTask}": answer)

  clearMultipleSelection: ->
    @setState multipleSelectionAnswers: []

  render: ->
    activePlaybackRateStyle = {backgroundColor: "#92a2b3", color: "black", border: "solid 2px transparent"}

    mediaSrcs = {}
    if @state.classificationData?.subject?
      @state.classificationData?.subject?.locations.map (location, i) ->
        mediaSrcs["#{Object.keys(location)[0]}"] = location["#{Object.keys(location)[0]}"]

    <div className="classify-page">
      <div className="classification">
        <section className="subject">
          {if @state.classificationData?.subject?
            <div className="video-container">
              <video
                ref="subjectVideo"
                controls
                src={mediaSrcs["video/mp4"]}
                poster={mediaSrcs["image/jpeg"]}
                type="video/mp4"
                width="100%"
                height="100%"
              >
                Your browser does not support the video format. Please upgrade your browser.
              </video>
              <div className="playback-rate-controls">
                <button className="playback-button" style={activePlaybackRateStyle if @state.playbackRate is 0.25} type="button" onClick={@onClickPlaybackRateButton} value="0.25">
                  &#188;x
                </button>
                <button className="playback-button" style={activePlaybackRateStyle if @state.playbackRate is 0.5} type="button" onClick={@onClickPlaybackRateButton} value="0.5">
                  &#189;x
                </button>
                <button className="playback-button" style={activePlaybackRateStyle if @state.playbackRate is 1} type="button" onClick={@onClickPlaybackRateButton} value="1">
                  1x
                </button>
                <span className="playback-controls-label"><Translate content="classifyPage.help.playback" /></span>
              </div>
            </div>
          else
            <div style={width: '400px', height: '400px', display: 'flex', justifyContent: 'center', alignItems: 'center'}>
              <LoadingIndicator />
            </div>
          }
        </section>
        <section className="questions-container">
          <img className="batman-placeholder" src="./assets/batman-placeholder.png" alt="bat icon placeholder" />
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
