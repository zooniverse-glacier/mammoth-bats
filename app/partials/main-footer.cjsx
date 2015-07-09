React = require 'react/addons'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'
ZooniverseLogotype = require './zooniverse-logotype'

module.exports = React.createClass
  displayName: 'MainFooter'

  render: ->
    <footer className="main-footer">
      <ZooniverseLogotype />
    </footer>