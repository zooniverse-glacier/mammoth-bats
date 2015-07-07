counterpart = require 'counterpart'
React = require 'react'
Translate = require 'react-translate-component'
LoadingIndicator = require '../components/loading-indicator'

counterpart.registerTranslations 'en',
  signInForm:
    signIn: 'Sign in'
    signOut: 'Sign out'
    userName: 'User name'
    password: 'Password'
    incorrectDetails: 'Username or password incorrect'
    forgotPassword: 'Forget your password?'

module.exports = React.createClass
  displayName: 'SignInForm'

  getInitialState: ->
    busy: false
    currentUser: null
    login: ''
    password: ''
    error: null

  componentDidMount: ->
    @props.auth.listen @handleAuthChange
    @handleAuthChange()

  componentWillUnmount: ->
    @props.auth.stopListening @handleAuthChange

  handleAuthChange: ->
    @setState busy: true, =>
      @props.auth.checkCurrent().then (currentUser) =>
        @setState {currentUser}
        if currentUser?
          @setState login: currentUser.login, password: '********'
        @setState busy: false

  render: ->
    disabled = @state.currentUser? or @state.busy

    <form onSubmit={@handleSubmit}>
      <label>
        <Translate content="signInForm.userName" />
        <input type="text" className="standard-input full" name="login" value={@state.login} disabled={disabled} autoFocus onChange={@handleInputChange} />
      </label>

      <br />

      <label>
        <Translate content="signInForm.password" /><br />
        <input type="password" className="standard-input full" name="password" value={@state.password} disabled={disabled} onChange={@handleInputChange} />
      </label>

      <p style={textAlign: 'center'}>
        {if @state.currentUser?
          <div className="form-help">
            Signed in as {@state.currentUser.login}{' '}
            <button type="button" className="minor-button" onClick={@handleSignOut}>Sign out</button>
          </div>

        else if @state.error?
          <div className="form-help error">
            {if @state.error.message.match /invalid(.+)password/i
              <Translate content="signInForm.incorrectDetails" />
            else
              <span>{@state.error.toString()}</span>}{' '}

            <a href="#/reset-password" onClick={@props.onSuccess}>
              <Translate content="signInForm.forgotPassword" />
            </a>
          </div>

        else if @state.busy
          <LoadingIndicator />

        else
          <a href="#/reset-password" onClick={@props.onSuccess}>
            <Translate content="signInForm.forgotPassword" />
          </a>}
      </p>

      <button type="submit" className="standard-button full" disabled={disabled or @state.login.length is 0 or @state.password.length is 0}>
        <Translate content="signInForm.signIn" />
      </button>
    </form>

  handleInputChange: (e) ->
    newState = {}
    newState[e.target.name] = e.target.value
    @setState newState

  handleSubmit: (e) ->
    e.preventDefault()
    @setState working: true, =>
      {login, password} = @state
      @props.auth.signIn {login, password}
        .then (user) =>
          @setState working: false, error: null, =>
            @props.onSuccess? user
        .catch (error) =>
          @setState working: false, error: error, =>
            @getDOMNode().querySelector('[name="login"]')?.focus()
            @props.onFailure? error
      @props.onSubmit? e

  handleSignOut: ->
    @setState busy: true, =>
      @props.auth.signOut().then =>
        @setState busy: false, password: ''
