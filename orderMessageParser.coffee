MESSAGE_IMAGE_BODY_STYLE = 'background: #ddd; margin: 0;'
MESSAGE_IMAGE_DIV_STYLE = 'width: 250px; margin: 0px; padding: 30px 20px; box-sizing: border-box;'
MESSAGE_IMAGE_IMG_STYLE = 'display: inline-block; width: 12px; height: 12px; margin: 0 2px;'

# Each of these functions performs one parsing transform on the message body
# e.g. bold text or token symbols -- unfortunately the formatting syntax for
# italics interferes with the token replacements for the logos, since URLs can
# have underscores in them, so we'll first remove the underscores from the
# tokens, then perform the italics transform, then finish with the proper token
# replacements. NB: it might be worth switching to using double underscores for
# italics instead to avoid this issue.
MESSAGE_TRANSFORM_FUNCTIONS = [
    (message, context) -> message.replace(/<<MAKER_TOKEN_SYMBOL>>/g, context.makerTokenSymbol)
    (message, context) -> message.replace(/<<MAKER_TOKEN_AMOUNT>>/g, context.makerTokenAmount)
    (message, context) -> message.replace(/<<TAKER_TOKEN_SYMBOL>>/g, context.takerTokenSymbol)
    (message, context) -> message.replace(/<<TAKER_TOKEN_AMOUNT>>/g, context.takerTokenAmount)

    (message, context) -> message.replace(/<<MAKER_TOKEN_LOGO>>/g, '<<MAKERTOKENLOGO>>')
    (message, context) -> message.replace(/<<TAKER_TOKEN_LOGO>>/g, '<<TAKERTOKENLOGO>>')

    (message, context) -> message.replace(/(\*\*)(.*?)\1/g, '<strong>$2</strong>')
    (message, context) -> message.replace(/(_)(.*?)\1/g, '<em>$2</em>')

    (message, context) -> message.replace(/<<MAKERTOKENLOGO>>/g, context.makerTokenLogo)
    (message, context) -> message.replace(/<<TAKERTOKENLOGO>>/g, context.takerTokenLogo)
]

module.exports = (rawMessage, imageOptions) ->
  makerImageElement = "<img src=\"#{imageOptions.makerTokenLogo}\" style=\"#{MESSAGE_IMAGE_IMG_STYLE}\" />"
  takerImageElement = "<img src=\"#{imageOptions.takerTokenLogo}\" style=\"#{MESSAGE_IMAGE_IMG_STYLE}\" />"

  imageHtmlPrefix = "<body style=\"#{MESSAGE_IMAGE_BODY_STYLE}\"><div style=\"#{MESSAGE_IMAGE_DIV_STYLE}\">"
  imageHtmlSuffix = '</div></body>'

  messageContext =
    makerTokenSymbol: imageOptions.makerTokenSymbol
    makerTokenLogo: makerImageElement
    makerTokenAmount: imageOptions.makerTokenAmount
    takerTokenSymbol: imageOptions.takerTokenSymbol
    takerTokenLogo: takerImageElement
    takerTokenAmount: imageOptions.takerTokenAmount
  finalMessageHtml = MESSAGE_TRANSFORM_FUNCTIONS.reduce ((message, transformFunction) -> transformFunction(message, messageContext)), rawMessage
  console.log finalMessageHtml
  return "#{imageHtmlPrefix}#{finalMessageHtml}#{imageHtmlSuffix}"
