React = require 'react'
counterpart = require 'counterpart'
Markdown = require '../components/markdown'

counterpart.registerTranslations 'en',
  aboutPage:
    content: '''
      ## Why is this project important?

      Scientists know relatively little about the behavior of many North American bat species in their native environments. That is because bat behaviors are really hard to study in the wild. Bats tend to be small, active at night when it is hard for us to see them, and easily disturbed when they are in their roosts.

      Studying bat behaviors in the wild is becoming easier thanks to improvements in technology. Infrared and near infrared cameras are now able to remotely record bat behaviors in and around bat roosts. However, one study can produce thousands of hours of video. Someone has to watch all those videos and identify the behaviors.

      This study helps scientists by involving the public in the scientific process. Lots of eyes can watch the videos faster than just one or two scientists. By working together, the videos can be processed faster and we can learn more about the bats' behaviors. Plus, because so little is known about bat behaviors in the wild, participants watching the videos may discover new behaviors.

      ## About the videos

      The bats in the videos are lesser long-nosed bats (Leptonycteris curasoae). Lesser long-nosed bats are an endangered bat that feeds on nectar and pollen of many southwestern cacti species, including agave. Lesser long-nosed bats migrate between Mexico and southern Arizona and New Mexico. Their migration follows the blooms of the cacti that they pollinate.

      Every year, scientists pick two consecutive nights in each of several months to conduct simultaneous population counts of the bats. The videos were recorded during those population counts. The videos feature an old mine that is located in Arizona and is a fall roosting site for the lesser long-nosed bats.

      A large, 6-sided gate surrounds the entrance to the mine. Six cameras, one for each side of the gate, were set up to record the bats as they entered and exited the mine. Infrared lights were also placed around the mine to provide extra light for the cameras. (Infrared light doesn't disturb the bats.) The cameras recorded video from sunup to sundown.

      Scientists used night vision goggles to count the bats using the mine at the same time that the cameras were recording the videos. The videos were originally used to check the accuracy of the scientists' population counts. Now, we want to use those same videos to study the bats' behaviors as they fly around the roost.
    '''

module.exports = React.createClass
  displayName: 'AboutPage'

  render: ->
    <div className="secondary-page">
      <Markdown>{counterpart 'aboutPage.content'}</Markdown>
    </div>
