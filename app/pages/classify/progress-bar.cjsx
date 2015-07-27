React = require 'react'
classnames = require 'classnames'

workflowTaskKeys = require '../../lib/workflow-task-keys'

module.exports = React.createClass
  displayName: "ProgressBar"

  render: ->
    disabledCondition = @props.currentTask is "summary"

    taskOneClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is workflowTaskKeys.first and @props.annotations[1].value?.length is 0
      done: @props.currentTask isnt workflowTaskKeys.first and @props.annotations[0].value?

    taskTwoClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is workflowTaskKeys.second
      done: @props.currentTask isnt workflowTaskKeys.second and @props.annotations[1].value?.length > 0
      skip: @props.currentTask is workflowTaskKeys.third and @props.annotations[1].value?.length is 0

    taskThreeClasses = classnames
      "progress-bar-button-container": true
      active: @props.currentTask is workflowTaskKeys.third
      done: @props.currentTask is workflowTaskKeys.third and @props.annotations[2].value?.length > 0

    <div className="progress-bar">
      <div ref="taskOne" className={taskOneClasses}>
        <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.first)} disabled={disabledCondition}>
          {if @props.currentTask is workflowTaskKeys.first
            "1"
          else
            <img src="./assets/checkmark.svg" alt="checkmark" />}
        </button>
      </div>
      <div ref="taskTwo" className={taskTwoClasses}>
        {if @props.currentTask is workflowTaskKeys.second or @props.annotations[1].value?.length > 0
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.second)} disabled={disabledCondition}>
            {if @props.currentTask is workflowTaskKeys.second
              "2"
            else if @props.currentTask is workflowTaskKeys.third
              <img src="./assets/checkmark.svg" alt="checkmark icon" />}
          </button>
        else if @props.currentTask is workflowTaskKeys.third and @props.annotations[1].value?.length is 0
          <span className="skip-pseudo-button"><img src="./assets/ex-icon.svg" alt="skipped icon" /></span>}
      </div>
      <div ref="taskThree" className={taskThreeClasses}>
        {if @props.currentTask is workflowTaskKeys.third or @props.annotations[2].value?.length > 0
          <button className="progress-bar-button" type="button" onClick={@props.onClickProgressBarButton.bind(null, workflowTaskKeys.third)} disabled={disabledCondition}>
            {if !@props.annotations[2].value? or @props.annotations[2].value?.length is 0
              "3"
            else
              <img src="./assets/checkmark.svg" alt="checkmark" />}
          </button>}
      </div>
    </div>