define ['marked', 'emojione'], (marked, emojione) ->
  customRenderer = new marked.Renderer
  customRenderer.heading = (text, level, raw) ->
    base = "<h#{level}"
    if level <= 1
      base = "#{base} class=\"heading\""
    "#{base} id=\"#{this.options.headerPrefix + raw.toLowerCase().replace(/[^\w]+/g, "-")}\">#{text}</h#{level}>\n"
  customRenderer.link = (link, title, text) ->
    c = "" unless c
    "<a #{if /INNER../.test link then "class=\"innerUrl\" href=\"/pages/#{link.replace "INNER..", ""}\"" else "target=\"_blank\" href=\"#{link}\""} title=\"#{title}\">#{text}</a>"
  customRenderer.image = (src, title, alt) ->
    title = "" unless title
    alt = "" unless alt
    "<img class=\"img-responsive lazyload\" src=\"data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\" data-src=\"#{src}\" alt=\"#{alt}\" title=\"#{title}\" />\n"
  customRenderer.text = (b) -> emojione.toImage b
  return customRenderer
