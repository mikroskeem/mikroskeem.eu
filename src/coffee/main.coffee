# Start Cache worker
cacheWorker = new Worker "/static/js/cache-worker.min.js"
cacheWorker.postMessage "nop"
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
  stwbtn.className = if document.body.scrollTop > 100 then "show" else ""
  return
stwbtn.addEventListener "click", ->
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
    contentelem = document.getElementById "content"
    backButton = document.getElementById "backbutton"
    customRenderer = new marked.Renderer
    loadingBar = new progress
      bg: '#848484'

    getPage = ->
      splitUrl = window.location.pathname.split "/"
      splitUrl.shift() # Remove (always) empty item
      if splitUrl[0] is "index.html"
        splitUrl.shift()
      if splitUrl.length >= 2
        unless splitUrl[1] is ""
          loadPage splitUrl[1]
        else  # Shouldn't happen with sample nginx config
          $(contentelem).html "How did you even get here?"
      else
        loadPage "main"
      return

    processBody = (content) ->
      loadingBar.go 40
      $(contentelem).html content
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
      customScript = $(".customscript")
      (new Function(atob customScript[0].value))() if customScript.length is 1 #New scripts will start using RequireJS
      return

    _direct_loadPage = (name) ->
      req = $.get "/pages/#{name}.md"
      req.done (res, status, xhr) ->
        body = res
        unless name is "main"
          body = "#{body}\n\n* * *\n\n<a href=\"javascript:history.back()\">Go back</a>"
        marked body, (err, renderedBody) ->
          loadingBar.go 60
          if err
            $(contentelem).html "marked.js error: #{err}"
            loadingBar.go 100
            return
          processBody renderedBody
          cacheWorker.postMessage
            type: "set"
            data:
              name: name
              etag: xhr.getResponseHeader "ETag"
              content: renderedBody
          return
        return
      req.fail (xhr) ->
        console.log xhr
        $(contentelem).html "<h1 class='heading'>#{xhr.status}</h1>"
        loadingBar.go 100
        return
      return

    loadPage = (name) ->
      loadingBar.go 20
      fetchEtag = $.ajax
        url: "/pages/#{name}.md"
        type: "HEAD"
      fetchEtag.done (res, status, xhr) ->
        cacheCallback = (event) ->
          cacheWorker.removeEventListener "message", cacheCallback
          msg = event.data
          if msg.etag is xhr.getResponseHeader "etag"
            clearTimeout fallbackFetch
            processBody msg.content
          else
            cacheWorker.postMessage
              type: "del"
              data:
                name: name
          return
        cacheWorker.addEventListener "message", cacheCallback, false
        cacheWorker.postMessage
          type: "get"
          data:
            name: name
        fallbackFetch = setTimeout ->
          cacheWorker.removeEventListener "message", cacheCallback
          _direct_loadPage name
          return
        , 1000
        return
      fetchEtag.fail (xhr) ->
        console.log xhr
        $(contentelem).html "<h1 class='heading'>#{xhr.status}</h1>"
        loadingBar.go 100
        return
      return
    window.addEventListener "popstate", getPage
    getPage()
    return
  return
