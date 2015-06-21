os = require 'os'
path = require 'path'
Promise = require 'bluebird'
fs = require 'fs'
write = Promise.promisify(fs.write)
unlink = Promise.promisify(fs.unlink)
close = Promise.promisify(fs.close)
tempOpen = Promise.promisify(require('temp').open)
{BufferedProcess} = require 'atom'

module.exports =
class Kobito
  post: (text) ->
    @_writeTmpFile(text).then((tmpPath)->
      new Promise((resolve, reject) ->
        new BufferedProcess(
          command: 'open'
          args: ['-a', 'Kobito', tmpPath]
          exit: (code) ->
            # すぐに削除するとKobitoに保存されない
            setTimeout ->
              unlink(tmpPath)
            , 3000

            if code is 0
              resolve()
            else
              reject()
        )
      )
    )

  _writeTmpFile: (text) ->
    tempOpen('atom-post-kobito').then(({fd, path: tmpPath}) ->
      write(fd, text).then( ->
        close(fd)
      ).then( ->
        Promise.resolve(tmpPath)
      )
    )
