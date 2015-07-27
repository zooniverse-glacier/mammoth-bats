React = require 'react/addons'
UserStore = require '../stores/user-store'
ZooniverseLogo = require './zooniverse-logo'

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
      <a href={UserStore.signInUrl()}><button>Click to login</button></a>
    </div>
