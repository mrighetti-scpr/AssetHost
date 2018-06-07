(function(){"use strict"
function e(e,t){return caches.keys().then(function(n){n.forEach(function(n){var c=0===n.indexOf(e),s=n!==t
c&&s&&caches.delete(n)})})}function t(e){var t=arguments.length<=1||void 0===arguments[1]?self.location:arguments[1]
return decodeURI(new URL(encodeURI(e),t).toString())}function n(e){var n=t(e)
return new RegExp("^"+n+"$")}function c(e,t){return!!t.find(function(t){return t.test(decodeURI(e))})}self.CACHE_BUSTER="1528345646433|0.888972531177358",self.addEventListener("install",function(e){return self.skipWaiting()}),self.addEventListener("activate",function(e){return self.clients.claim()})
var s=["assets/frontend-3c970c6ad891d4f1474812e358daa33f.css","assets/frontend-2772ad0f42fa1daaaf075db68da24365.js","assets/vendor-cfa7d14768e6fcf0687346d2d883f485.css","assets/vendor-027e6078973737fc6508f75ee1b83d8b.js"],i="esw-asset-cache-1",a=s.map(function(e){return new URL(e,self.location).toString()}),r=function(){caches.open(i).then(function(e){return e.keys().then(function(t){t.forEach(function(t){-1===a.indexOf(t.url)&&e.delete(t)})})})}
self.addEventListener("install",function(e){e.waitUntil(caches.open(i).then(function(e){return Promise.all(a.map(function(t){var n=new Request(t,{mode:"cors"})
return fetch(n).then(function(n){if(n.status>=400){var c=new Error("Request for "+t+" failed with status "+n.statusText)
throw c}return e.put(t,n)}).catch(function(e){console.error("Not caching "+t+" due to "+e)})}))}))}),self.addEventListener("activate",function(t){t.waitUntil(Promise.all([e("esw-asset-cache",i),r()]))}),self.addEventListener("fetch",function(e){var t="GET"===e.request.method,n=-1!==a.indexOf(e.request.url)
t&&n&&e.respondWith(caches.match(e.request,{cacheName:i}).then(function(t){return t||fetch(e.request)}))})
var o=["/api/assets(.*)"],u=o.map(n)
self.addEventListener("fetch",function(e){var t=e.request
"GET"===t.method&&/^https?/.test(t.url)&&c(t.url,u)&&e.respondWith(caches.open("esw-cache-fallback-1").then(function(n){return fetch(t).then(function(e){return n.put(t,e.clone()),e}).catch(function(){return caches.match(e.request)})}))}),self.addEventListener("activate",function(t){t.waitUntil(e("esw-cache-fallback","esw-cache-fallback-1"))})
var f=[/\/i(\/.*)?$/,/\/api(\/.*)?$/],l=[]
self.INDEX_FILE_HASH="279b9d4a923e007c39011ab3b862bf00"
var h=new URL("index.html",self.location).toString()
self.addEventListener("install",function(e){e.waitUntil(fetch(h,{credentials:"include"}).then(function(e){return caches.open("esw-index-1").then(function(t){return t.put(h,e)})}))}),self.addEventListener("activate",function(t){t.waitUntil(e("esw-index","esw-index-1"))}),self.addEventListener("fetch",function(e){var t=e.request,n=new URL(t.url),s="GET"===t.method,i=-1!==t.headers.get("accept").indexOf("text/html"),a=n.origin===location.origin,r=c(t.url,f),o=!l.length||c(t.url,l)
!("/tests"===n.pathname&&!1)&&s&&i&&a&&o&&!r&&e.respondWith(caches.match(h,{cacheName:"esw-index-1"}))})})()
