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

# https://panoptes.zooniverse.org/oauth/authorize

settings =
  host: 'https://panoptes.zooniverse.org'
  clientId: '400ef4a4e543a717d370c4304a460eeb1ac4c9fc1b00897b92a67da5818a1603'
  responseType: 'token'

authorizationEndpoint = settings.host + '/oauth/authorize' +
  "?response_type=#{ settings.responseType }" +
  "&client_id=#{ settings.clientId }" +
  "&redirect_uri=#{ encodeURI window.location }"

module.exports = React.createClass
  displayName: 'LoginBar'

  render: ->
    <div className="login-bar">
      <a href={ authorizationEndpoint }>Click to login</a>
    </div>
