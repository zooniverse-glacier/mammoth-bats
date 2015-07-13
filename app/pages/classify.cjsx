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

  render: ->
    <ReactCSSTransitionGroup transitionName="task-fade" transitionAppear={true}>
      {console.log 'task', @props.task}
      <div className="task">
        <h3>{@props.task.question}</h3>
        {switch @props.task.type
          when "multiple"
            for answer in @props.task.answers
              <label key={answer.label} className="task-checkbox">
                <input type="checkbox" name={@props.task.question} value={answer.label} onClick={@props.storeMultipleSelection.bind(null, @props.task.question, answer.label, @props.task.next)} />
                {answer.label}
              </label>
          when "single"
            for answer in @props.task.answers
              <button key={answer.label} type="button" className="task-button" value={answer.label} onClick={@props.storeSelection.bind(null, @props.task.question, answer.label, answer.next)}>
                {answer.label}
              </button>
        }
        {unless @props.lastTask
          <button className="action-button" type="button" onClick={@props.showTask.bind(null, @props.nextTask)} disabled={@props.nextTask is null}>
            <Translate content="classifyPage.buttons.next" />
          </button>
        else
          <button className="action-button" type="button" onClick={@props.onClickFinish}>
            <Translate content="classifyPage.buttons.finish" />
          </button>
        }
      </div>
    </ReactCSSTransitionGroup>

module.exports = React.createClass
  displayName: "Classify"
  mixins: [Reflux.ListenerMixin, Reflux.connect(classifyStore, "classificationData")]

  getInitialState: ->
    taskKey: ''
    nextTask: null
    multipleSelectionAnswers: []

  componentDidMount: ->
    console.log 'mounting'
    @listenTo classifyStore, (classificationData) ->
      @setState taskKey: classificationData?.workflow?.first_task

  showTask: (taskKey) ->
    console.log 'taskkey on showtask', taskKey
    @setState
      taskKey: taskKey
      nextTask: null

  storeMultipleSelection: (question, answer, nextTask) ->
    console.log nextTask
    currentAnswers = @state.multipleSelectionAnswers
    index = currentAnswers.indexOf(answer)

    if index > -1
      currentAnswers.splice index, 1
      @setState({multipleSelectionAnswers: currentAnswers}, -> @storeSelection(question, @state.multipleSelectionAnswers, nextTask))
    else
      currentAnswers.push answer
      @setState({multipleSelectionAnswers: currentAnswers}, -> @storeSelection(question, @state.multipleSelectionAnswers, nextTask))

  storeSelection: (question, answer, nextTask) ->
    console.log question, answer, nextTask
    question = question.replace(/\s+/g, '')
    @setState nextTask: nextTask, ->
      classifyActions.updateAnnotation("#{question}": answer)

  onClickFinish: ->
    console.log 'finished!', @state.classificationData.classification.annotations
    classifyActions.finishClassification()
    @clearMultipleSelection()

  clearMultipleSelection: ->
    @setState multipleSelectionAnswers: []

  checkIfLastTask: ->


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
                for taskKey, task of @state.classificationData.workflow.tasks
                  <div key={taskKey} className="task-container">
                    {if @state.taskKey is taskKey
                      <Task
                        task={task}
                        nextTask={@state.nextTask}
                        lastTask={@state.taskKey is Object.keys(@state.classificationData.workflow.tasks).pop()}
                        storeSelection={@storeSelection}
                        storeMultipleSelection={@storeMultipleSelection}
                        showTask={@showTask}
                        onClickFinish={@onClickFinish}
                      />
                    }
                  </div>
              else
                <div style={display: 'flex', justifyContent: 'center', alignItems: 'center'}>
                  <LoadingIndicator />
                </div>
              }
            </div>
          </section>
        </div>
    </div>
