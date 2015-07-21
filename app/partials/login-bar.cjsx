React = require 'react/addons'
UserStore = require '../stores/user-store'
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
      <a href={ UserStore.signInUrl() }>Click to login</a>
    </div>
