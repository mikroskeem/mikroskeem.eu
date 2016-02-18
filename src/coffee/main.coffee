# Start Cache worker
cacheWorker = new Worker "/static/js/cache-worker.min.js"
cacheWorker.postMessage "nop"

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

  # Load image lazyloader and touch gesture support library
  require [
    'lazysizes'
    'hammer'
  ], (lazysizes, Hammer) ->
    mc = new Hammer document.body,
      cssProps:
        userSelect: true
        userDrag: true
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
  ], (marked, customRenderer, progress) ->
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

    fetchEtag = (name) ->
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
        httpreq.open 'HEAD', "/pages/#{name}.md", true
        httpreq.addEventListener 'readystatechange', handler
        httpreq.send null

    loadPage = (name) ->
      loadingBar.go 20
      fetchEtag(name).then ((etag) ->
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
    window.addEventListener "popstate", getPage
    getPage()
    return
  # Load Google Analytics
  require ['ga'], ->
    # Loaded
    return
  , (err) ->
    console.log 'GA failed to load. Dang you young adblock users!'
    return
  return
