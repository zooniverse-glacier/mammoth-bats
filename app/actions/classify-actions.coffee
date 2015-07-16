Reflux = require 'reflux'

ClassifyActions = Reflux.createActions({
  createNewClassification: "createNewClassification",
  updateAnnotation: "updateAnnotation",
  finishClassification: "finishClassification",
  saveClassification: "saveClassification"
})

module.exports = ClassifyActions