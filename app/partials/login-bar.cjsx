React = require 'react/addons'
ZooniverseLogo = require './zooniverse-logo'
LoginDialog = require '../partials/login-dialog'
alert = require '../lib/alert'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'

counterpart.registerTranslations 'en',
  loginBar:
    signIn: 'Sign in'
    register: 'Register'

module.exports = React.createClass
  displayName: 'LoginBar'

  render: ->
    <div className="login-bar">
      <button type="button" className="secret-button" onClick={@showLoginDialog.bind this, 'sign-in'}>
        <Translate content="loginBar.signIn" />
      </button>&emsp;
      <button type="button" className="secret-button" onClick={@showLoginDialog.bind this, 'register'}>
        <Translate content="loginBar.register" />
      </button>
    </div>

  showLoginDialog: (which) ->
    alert (resolve) =>
      <LoginDialog which={which} onSuccess={resolve} auth={@props.auth} project={@props.project} />