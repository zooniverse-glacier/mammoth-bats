Reflux = require 'reflux'

ClassifyActions = Reflux.createActions({
  createNewClassification: "createNewClassification",
  updateAnnotation: "updateAnnotation",
  getAnnotationByKey: "getAnnotationByKey",
  finishClassification: "finishClassification",
  saveClassification: "saveClassification",
  getNextSubject: "getNextSubject"
})

module.exports = ClassifyActions
