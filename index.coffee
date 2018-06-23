express = require 'express'
bodyParser = require 'body-parser'
htmlToImage = require 'wkhtmltoimage'

orderMessageParser = require './orderMessageParser'

SERVER_PORT = 3000
IMAGE_DIR = "#{__dirname}/images/"
IMAGE_FILE_EXT = '.png'

HTML_TO_IMAGE_OPTIONS =
  cropW: 250

app = express()
app.use bodyParser.json()

app.get '/orderMessageImage', (req, res) ->
  orderHash = req.query.orderHash
  fileOptions =
    root: IMAGE_DIR
  res.sendFile "#{orderHash}#{IMAGE_FILE_EXT}", fileOptions, (err) ->
    return console.log(err) if err
    console.log "Sent message image for order: #{orderHash}"

app.post '/orderMessageImage', (req, res) ->
  return res.status(400).end() unless req.body
  tokenOptions =
    makerTokenSymbol: req.body.makerTokenSymbol,
    makerTokenLogo: req.body.makerTokenLogo,
    makerTokenAmount: req.body.makerTokenAmount,
    takerTokenSymbol: req.body.takerTokenSymbol,
    takerTokenLogo: req.body.takerTokenLogo,
    takerTokenAmount: req.body.takerTokenAmount
  orderMessageHtml = orderMessageParser req.body.message, tokenOptions

  imageOptions = Object.assign {}, HTML_TO_IMAGE_OPTIONS
  imageOptions.output = "#{IMAGE_DIR}#{req.body.orderHash}#{IMAGE_FILE_EXT}"
  imageStream = htmlToImage.generate orderMessageHtml, imageOptions
  res.end()

app.listen SERVER_PORT, -> console.log "Listening on port #{SERVER_PORT}"
