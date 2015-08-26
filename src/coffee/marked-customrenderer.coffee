define ['marked'], (marked) ->
  customRenderer = new marked.Renderer
  customRenderer.heading = (b, c, d) ->
    base = "<h#{c}"
    if c <= 1
      base = base + " class=\"heading\""
    base = base + " id=\"#{this.options.headerPrefix + d.toLowerCase().replace(/[^\w]+/g, "-")}\">#{b}</h#{c}>\n"
    return base
  customRenderer.link = (b, c, d) ->
    e = ""
    if /INNER../.test(b)
      e = '<a class="innerUrl" href="/pages/' + b.replace("INNER..", "") + '"'
    else
      e = '<a target="_blank" href="' + b + '"'
    e += ' title="' + c + '"' if c
    return e + ">" + d + "</a>"
  customRenderer.image = (b, c, d) ->
    c = "" unless c
    d = "" unless d
    "<img class=\"img-responsive lazyload\" src=\"data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\" data-src=\"#{b}\" alt=\"#{d}\" title=\"#{c}\" />\n"
  return customRenderer
