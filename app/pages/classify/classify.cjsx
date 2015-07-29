React = require 'react/addons'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
_ = require 'underscore'

counterpart = require 'counterpart'
Translate = require 'react-translate-component'
LoadingIndicator = require '../../components/loading-indicator'
Task = require './task'

Reflux = require 'reflux'
classifyStore = require '../../stores/classify-store'
classifyActions = require '../../actions/classify-actions'

workflowTaskKeys = require '../../lib/workflow-task-keys'

counterpart.registerTranslations 'en',
  classifyPage:
    help:
      playback: "playback speed"

module.exports = React.createClass
  displayName: "Classify"
  mixins: [Reflux.connect(classifyStore, 'classificationData')]

  getInitialState: ->
    playbackRate: 1
    loading: !classifyStore.loading

  onClickPlaybackRateButton: ({currentTarget}) ->
    subjectVideo = React.findDOMNode(@refs.subjectVideo)
    playbackRate = currentTarget.value
    subjectVideo.playbackRate = playbackRate

    @setState playbackRate: parseFloat(playbackRate)

  storeMultipleSelection: (currentTask, answer) ->
    currentAnnotation = _.find @state.classificationData.classification.annotations, (annotation) ->
      currentTask is annotation.key
    currentAnnotation.value ?= []

    currentAnswersIndex = currentAnnotation.value.indexOf answer
    if currentAnswersIndex > -1
      currentAnnotation.value.splice currentAnswersIndex, 1
    else
      currentAnnotation.value.push answer

  storeSelection: (key, answer) ->
    annotation = key: key, value: answer
    classifyActions.updateAnnotation annotation

  onVideoLoad: ->
    console.log 'loading video'
    # to do: break video out into own component and manage loading state

  render: ->
    activePlaybackRateStyle = {backgroundColor: "#92a2b3", color: "black", border: "solid 2px transparent"}

    mediaSrcs = {}
    if @state.classificationData?.subject?
      @state.classificationData?.subject?.locations.map (location, i) ->
        mediaSrcs["#{Object.keys(location)[0]}"] = location["#{Object.keys(location)[0]}"]

    <div className="classify-page">
      {if @state.loading is true
        <div style={display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: '100vh'}>
          <LoadingIndicator />
        </div>
      else
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
                  onLoad={@onVideoLoad()}
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
              </div>}
          </section>
          {if @state.classificationData?.classification?
            <Task
              workflow={@state.classificationData?.workflow}
              annotations={@state.classificationData?.classification.annotations}
              storeSelection={@storeSelection}
              storeMultipleSelection={@storeMultipleSelection}
              user={@props.user}
            />}
        </div>}
    </div>
