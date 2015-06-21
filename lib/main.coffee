InputDialog = require '@aki77/atom-input-dialog'
Kobito = require './kobito'

module.exports =
  activate: ->
    unless process.platform is 'darwin'
      atom.notifications.addWarning('OSX Only!')
      return

    @subscription = atom.commands.add 'atom-text-editor',
      'kobito-tools:post': (event) => @confirmPost(event)

  deactivate: ->
    @subscription?.dispose()

  confirmPost: (event) ->
    editor = event.target?.getModel()
    return unless editor

    text = editor.getSelectedText()
    text = editor.getText() if text.length is 0

    {scopeName} = editor.getGrammar()
    return @post(text) if scopeName is 'source.gfm'

    filename = editor.getTitle()
    title = "#{filename} (from Atom)"
    language = @scopeName2Language(scopeName)
    text = "```#{language}:#{filename}\n#{text}\n```"

    new InputDialog(
      prompt: 'Enter a title'
      defaultText: title
      selectedRange: [[0, 0], [0, filename.length]]
      callback: (title) =>
        text = "#{title}\n\n#{text}"
        @post(text)
    ).attach()

  post: (text) ->
    new Kobito()
      .post(text)
      .then( ->
        atom.notifications.addSuccess('All done!')
      )
      .catch((error) ->
        console.error(error)
        atom.notifications.addError('post error!')
      )

  scopeName2Language: (scopeName) ->
    # TODO: refactor
    scopeName.split('.')[1]
