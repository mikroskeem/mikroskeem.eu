# Google Analytics 
googleAnalytics = (b, c, d, e, f, g, h) ->
  b.GoogleAnalyticsObject = f
  b[f] = b[f] || ->
    (b[f].q = b[f].q or []).push arguments
    return
  b[f].l = 1 * new Date
  g = c.createElement d
  h = c.getElementsByTagName(d)[0]
  g.async = 1
  g.src = e
  h.parentNode.insertBefore g, h
  return
googleAnalytics window, document, "script", "//www.google-analytics.com/analytics.js", "ga"
ga "create", "UA-53567925-1", "auto"
ga "send", "pageview"

# Check for localStorage


# Check if RequireJS is available
# TODO: Is there any way for that? since this script gets called after requirejs
#  load
#throw new Error "RequireJS is not available" if typeof require == "undefined"

# Back to top button config
scrollTo = (b, c, d) ->
  unless 0 > d
    e = (c - b.scrollTop) / d * 10
    setTimeout ->
      b.scrollTop += e
      scrollTo(b, c, d - 10) unless b.scrollTop is c
      return
    , 10
  return 
stwbtn = document.getElementById "stw"
document.addEventListener "scroll", ->
  if document.body.scrollTop > 100
    stwbtn.className = "show"
  else
    stwbtn.className = ""
  return
stwbtn.addEventListener "click", ->
  console.log "back to top"
  scrollTo document.body, document.body.offsetTop, 400
  return 

# Get modules
require ['/static/js/require-cfg.min.js'], ->
  require [
    'marked'
    'marked_customrenderer'
    'lazysizes'
    'nanobar'
    'jquery'
  ], (marked, customRenderer, lazysizes, progress, $) ->
    marked.setOptions
      renderer: customRenderer
      sanitize: false
    content = document.getElementById "content"
    backButton = document.getElementById "backbutton"
    customRenderer = new marked.Renderer
    loadingBar = new progress
      bg: '#848484'
    getPage = ->
      splitUrl = window.location.pathname.split "/"
      if splitUrl.length is 3
        loadPage splitUrl[2]
      else
        loadPage "main"
      return
    loadPage = (name) ->
      loadingBar.go 20
      req = $.get "/pages/" + name + ".md"
      req.done (res, status, xhr) ->
        loadingBar.go 40
        etag = xhr.getResponseHeader "ETag"
        body = res
        unless name is "main"
          body = res + "\n\n* * *\n\n<a href=\"javascript:history.back()\">Go back</a>"
        marked body, (err, renderedBody) ->
          loadingBar.go 60
          if err
            $(content).html "marked.js error: "+err
            loadingBar.go 100
            return
          $(content).html renderedBody
          loadingBar.go 100
          $(".innerUrl").each (i, item) ->
            $(item).click (e) ->
              e.preventDefault()
              href = e.target.getAttribute "href"
              url = href
              if href is "/"
                url = "/pages/main"
              loadPage(url.replace "/pages/", "")
              history.pushState null, null, url
              return
            return
          return
        customScript = $(".customscript")
        (new Function(atob customScript[0].value))() if customScript.length is 1 #New scripts will start using RequireJS
        return
      req.fail (xhr) ->
        console.log xhr
        console.log "Request failed, http code", xhr.status
        $(content).html "<h1 class='heading'>404</h1>"
        loadingBar.go 100
        return
      return
    window.addEventListener "popstate", getPage
    getPage()
    return
  return
