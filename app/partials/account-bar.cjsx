React = require 'react'
{Link} = require 'react-router'
counterpart = require 'counterpart'
Translate = require 'react-translate-component'

counterpart.registerTranslations 'en',
  accountMenu:
    profile: 'Profile'
    settings: 'Settings'
    signOut: 'Sign Out'
    collections: 'Collections'

module.exports = React.createClass
  displayName: 'AccountBar'

  getInitialState: ->
    unread: false

  handleSignOutClick: ->
    @props.auth.signOut()

  render: ->
    <div className="account-bar">
      <div className="account-info">
        <span className="display-name"><strong>{@props.user.display_name}</strong></span>
      </div>
      <button type="button" onClick=@handleSignOutClick>
        <Translate content="accountMenu.signOut" />
      </button>
    </div>
