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

# Get modules
require ['/static/js/require-cfg.min.js'], ->
  httpreq = new XMLHttpRequest
  stwbtn = document.getElementById "stw"
  contentelem = document.getElementById "content"
  backButton = document.getElementById "backbutton"

  # Gets current page name ('/pages/<name>')
  getCurrentPageName = ->
    splitUrl = window.location.pathname.split "/"
    splitUrl.shift() # Remove (always) empty item
    if splitUrl[0] is "index.html"
      splitUrl.shift()
    if splitUrl.length >= 2
      unless splitUrl[1] is ""
        return splitUrl[1]
      else  # Shouldn't happen with sample nginx config
        return ""
    else
      return "main"

  # Set up 'back to top' button
  document.addEventListener "scroll", ->
    stwbtn.className = if document.body.scrollTop > 100 then "show" else ""
    return
  stwbtn.addEventListener "click", ->
    scrollTo document.body, document.body.offsetTop, 400
    return

  # Load image lazyloader, touch gesture support and HTML5 import polyfill libraries
  require [
    'lazysizes'
    'hammer'
    'htmlimports'
  ], (lazysizes, Hammer, himports) ->
    mc = new Hammer document.body
    mc.on "swipeleft", (ev) ->
      history.forward()
      return
    mc.on "swiperight", (ev) ->
      unless getCurrentPageName() is "main"
        history.back()
      return
    return

  # Load require code and libraries for proper page workflow
  require [
    'marked'
    'marked_customrenderer'
    'nanobar'
    'jquery'
  ], (marked, customRenderer, progress, $) ->
    marked.setOptions
      renderer: customRenderer
      sanitize: false

    customRenderer = new marked.Renderer
    loadingBar = new progress
      bg: '#848484'

    getPage = ->
      page = getCurrentPageName()
      unless page is ""
        loadPage page
      else
        contentelem.innerHTML = "How did you even get here?"
      return

    processBody = (content) ->
      loadingBar.go 40
      contentelem.innerHTML = content
      loadingBar.go 60
      # http://html5demos.com/history
      innerUrls = document.getElementsByClassName "innerUrl"
      [].forEach.call innerUrls, (item) ->
        item.addEventListener 'click', (e) ->
          e.preventDefault()
          href = e.target.pathname
          url = href
          if href is "/"
            url = "/pages/main"
          loadPage(url.replace "/pages/", "")
          history.pushState null, null, url
          return
        , false
      loadingBar.go 100
      return

    _md_loadPage = (name) ->
      handler = ->
        unless httpreq.readyState is 4
          return
        if httpreq.status is 200
          body = httpreq.responseText
          unless name is "main"
            body = "#{body}\n\n* * *\n\n<a href=\"javascript:history.back()\">Go back</a> (or swipe)"
          marked body, (err, renderedBody) ->
            loadingBar.go 60
            if err
              contentelem.innerHTML = "marked.js error: #{err}"
              loadingBar.go 100
              return
            processBody renderedBody
            cacheWorker.postMessage
              type: "set"
              data:
                name: name
                etag: httpreq.getResponseHeader "ETag"
                content: renderedBody
            return
        else
          console.error httpreq
          contentelem.innerHTML = "<h1 class='heading'>#{httpreq.status}</h1>"
          loadingBar.go 100
        httpreq.removeEventListener 'readystatechange', handler
        return

      httpreq.open 'GET', "/pages/#{name}.md", true
      httpreq.addEventListener 'readystatechange', handler
      httpreq.send null

    fetchEtag = (name, type) ->
      new Promise (resolve, reject) ->
        handler = ->
          unless httpreq.readyState is 4
            return
          if httpreq.status is 200
            resolve httpreq.getResponseHeader 'ETag'
          else
            reject httpreq
          httpreq.removeEventListener 'readystatechange', handler
          return
        httpreq.open 'HEAD', "/pages/#{name}.#{type}", true
        httpreq.addEventListener 'readystatechange', handler
        httpreq.send null

    loadPage = (name) ->
      loadingBar.go 20
      fetchEtag(name, "html").then ((etag) ->
        imp = document.querySelector "link[data-page-name=\"#{name}\"]"
        backText = "\n<hr><a href=\"javascript:history.back()\">Go back</a> (or swipe)"
        if ! !imp and typeof imp is 'object'
          body = imp.import.querySelector(".importContent").cloneNode(true).innerHTML
          unless name is "main"
            processBody body + backText
          else
            processBody body
        else
          ((name) ->
            new Promise (resolve, reject) ->
              link = document.createElement "link"
              link.rel = "import"
              link.dataset.pageName = name
              link.href = "/pages/#{name}.html"
              link.addEventListener "load", (event) ->
                impContent = document.querySelector "link[data-page-name=\"#{name}\"]"
                if ! !impContent and typeof impContent is 'object'
                  resolve impContent.import.querySelector(".importContent").cloneNode(true).innerHTML
                else
                  reject event
              , false
              link.addEventListener "error", (event) ->
                impContent = document.querySelector "link[data-page-name=\"#{name}\"]"
                impContent.parentNode.removeChild impContent
                reject event
              , false
              document.head.appendChild link
              return
          )(name).then ((body)->
            newBody = body
            unless name is "main"
              processBody body+backText
            else
              processBody body
            return
          ), (errEv) ->
            console.error errEv
            return
        return
      ), (xhr) ->
        fetchEtag(name, "md").then ((etag) ->
          cacheCallback = (event) ->
            cacheWorker.removeEventListener "message", cacheCallback
            msg = event.data
            if msg.length is 0
              clearTimeout fallbackFetch
              _md_loadPage name
              return
            console.warn "Bug? cache length is #{msg.length}" unless msg.length is 1
            content = msg[0]
            if content.etag is etag
              clearTimeout fallbackFetch
              processBody content.content
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
            _md_loadPage name
            return
          , 500
          return
        ), (xhr) ->
          console.error xhr
          contentelem.innerHTML = "<h1 class='heading'>#{xhr.xhr.status}</h1>"
          loadingBar.go 100
          return
        return
      return
    window.addEventListener "popstate", getPage
    getPage()
    return
  return
