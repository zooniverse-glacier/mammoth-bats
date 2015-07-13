Reflux = require 'reflux'

ClassifyActions = Reflux.createActions({
  createNewClassification: "createNewClassification",
  updateAnnotation: "updateAnnotation",
  finishClassification: "finishClassification"
})

module.exports = ClassifyActions