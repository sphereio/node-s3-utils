CustomError = (message) ->
  @name = 'CustomError'
  @message = message
CustomError:: = new Error()
CustomError::constructor = CustomError

module.exports =
  CustomError: CustomError
