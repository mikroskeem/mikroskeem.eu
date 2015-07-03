# Google Analytics 
googleAnalytics = (b, c, d, e, f, g, h) ->
  b.GoogleAnalyticsObject = f
  b[f] = b[f] || ->
    (b[f].q = b[f].q or []).push arguments
  b[f].l = 1 * new Date
  g = c.createElement d
  h = c.getElementsByTagName(d)[0]
  g.async = 1
  g.src = e
  h.parentNode.insertBefore g, h
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
require [
  '/static/js/marked.min.js'
  '/static/js/lazysizes.min.js'
  '/static/js/nanobar.min.js'
], (marked,lazysizes, progress) ->
  content = document.getElementById "content"
  backButton = document.getElementById "backbutton"
  customRenderer = new marked.Renderer
  loadingBar = new progress
    bg: '#848484'
  loadCss = (url) ->
    link = document.createElement "link"
    link.type = "text/css"
    link.rel = "stylesheet"
    link.href = url
    document.getElementsByTagName("head")[0].appendChild link
  do ->
    cssFiles = [
      '/static/css/bootstrap.min.css'
      '/static/css/font-awesome.min.css'
#      '/static/css/progressjs.min.css'
      '/static/css/index.css'
    ]
    raf = requestAnimationFrame or mozRequestAnimationFrame or webkitRequestAnimationFrame or msRequestAnimationFrame 
    raf ->
      loadCss file for file in cssFiles
      return
    return
  getPage = ->
    splitUrl = window.location.pathname.split "/"
    if splitUrl.length is 3
      loadPage(splitUrl[2])
    else
      loadPage("main")
    return
  loadPage = (name) ->
    req = new XMLHttpRequest
    req.addEventListener 'readystatechange', ->
      unless req.readyState is 4
        return
      fourHundredFour = false
      loadingBar.go 20
      if req.status is 404
        console.log "no such page"
        fourHundredFour = true
      else if req.status is 403 or req.status is 500
        throw new Error "Something went wrong with server"
      else unless req.status is 200
        throw new Error "Unexpected response code: "+req.status
      unless fourHundredFour #req.responseText.length is 0
        if name is "main"
          body = req.responseText
        else
          body = req.responseText + "\n\n* * *\n\n<a href=\"javascript:history.back()\">Go back</a>"
      else
        body = "# 404 :(\n\nYou should go back to [main page](INNER..main)."
      loadingBar.go 40
      marked body,
        renderer: customRenderer
      , (err,renderedBody) ->
        loadingBar.go 60
        if err
          content.innerHTML = "marked.js error: "+err
          return
        else
          content.innerHTML = renderedBody
          innerUrls = document.getElementsByClassName "innerUrl"
          i = 0
          while i < innerUrls.length
            innerUrls[i].addEventListener 'click', (event) ->
              event.preventDefault()
              href = event.target.getAttribute "href"
              if href is "/"
                url = "/pages/main"
              else
                url = href
              loadPage(url.replace "/pages", "")
              history.pushState(null,null,url)
              return
            , false
            i++
          loadingBar.go 80
          customScript = document.getElementsByClassName "customscript"
          (new Function(["marked", "customRenderer"], atob(customScript[0].value)))(marked, customRenderer) if 0 < customScript.length #passing marked and customRenderer cuz most of scripts want it
          loadingBar.go 100
          return
      return  
        
    req.open "GET", "/pages/"+name+".md?"+(new Date).getTime(), true
    req.setRequestHeader("X-Requested-With", "XMLHttpRequest")
    req.send null
    return
  window.addEventListener "popstate", getPage
  customRenderer.heading = (b, c, d) ->
    return "<h" + c + ' class="heading" id="' + this.options.headerPrefix + d.toLowerCase().replace(/[^\w]+/g, "-") + '">' + b + "</h" + c + ">\n"
  customRenderer.link = (b, c, d) ->
    e = ""
    if /INNER../.test(b) 
      e = '<a class="innerUrl" href="/pages/' + b.replace("INNER..", "") + '"'
    else
      e = '<a target="_blank" href="' + b + '"'
    e += ' title="' + c + '"' if c
    return e + ">" + d + "</a>"
  customRenderer.image = (b, c, d) ->
    b = '<img class="img-responsive lazyload" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" data-src="' + b + '" alt="' + d + '"'
    b += ' title="' + c + '"' if c
    return b + " />"
  getPage()
  return
