React = require 'react/addons'
ZooniverseLogo = require './zooniverse-logo'

module.exports = React.createClass
  displayName: 'Header'

  render: ->
    <header className="main-header">
      <ZooniverseLogo />
      <nav></nav>
    </header>

