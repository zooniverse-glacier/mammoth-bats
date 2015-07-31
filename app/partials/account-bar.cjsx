React = require 'react'
{Link} = require 'react-router'
counterpart = require 'counterpart'
Translate = require 'react-translate-component'
userActions = require '../actions/user-actions'

counterpart.registerTranslations 'en',
  accountMenu:
    profile: 'Profile'
    settings: 'Settings'
    signOut: 'Sign Out'
    collections: 'Collections'

module.exports = React.createClass
  displayName: 'AccountBar'

  componentDidMount: ->
    if @props.user?
      avatar = userActions.getUserAvatar(@props.user)
      console.log 'avatar', avatar

  handleSignOutClick: ->
    userActions.signOut()

  render: ->
    <div className="account-bar">
      <div className="account-info">
        <span className="display-name"><strong>{@props.user.display_name}</strong></span>
      </div>
      <button className="secret-button" type="button" onClick={@handleSignOutClick}>
        <Translate content="accountMenu.signOut" />
      </button>
    </div>
