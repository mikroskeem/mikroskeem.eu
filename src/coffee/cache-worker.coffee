importScripts "Dexie.min.js"
db = new Dexie "cachedPages"
db.version(1).stores
  cache: "name,etag,content"
db.open()

self.addEventListener 'message', (event) ->
  db.transaction 'rw', db.cache, ->
    msg = event.data
    if msg is "nop"
      return
    if msg.type is "get"
      db.cache.where("name").equals(msg.data.name).each (item)->
        self.postMessage item
        return
    else if msg.type is "set"
      db.cache.add
        name: msg.data.name
        etag: msg.data.etag
        content: msg.data.content
    else if msg.type is "del"
      db.cache.where("name").equals(msg.data.name).delete()
    return
  return
, false
