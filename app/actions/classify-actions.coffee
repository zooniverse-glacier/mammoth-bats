Reflux = require 'reflux'

ClassifyActions = Reflux.createActions({
  createNewClassification: "createNewClassification",
  updateAnnotation: "updateAnnotation"
})

ClassifyActions.updateAnnotation.listen ->
  console.log 'updateAnnotation called'

module.exports = ClassifyActions