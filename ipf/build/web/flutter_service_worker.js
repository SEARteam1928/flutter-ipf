'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "96aa7eba2eb4a2a1e5aae1d1f46cae1e",
"assets/FontManifest.json": "a8fe68574435c3f990b90af066321c41",
"assets/fonts/MaterialIcons-Regular.otf": "a68d2a28c526b3b070aefca4bac93d25",
"assets/fonts/Montserrat-Black.ttf": "3b396895e6988d35a5b46ee05b6d33ff",
"assets/fonts/Montserrat-BlackItalic.ttf": "0672ca2e4a98d6e2286fd37f373a876f",
"assets/fonts/Montserrat-Bold.ttf": "69c703b21776155b4bf13adbbb72e5a5",
"assets/fonts/Montserrat-BoldItalic.ttf": "eb83f898880a44deeca283840a45f913",
"assets/fonts/Montserrat-ExtraBold.ttf": "7a6fdef13a2abae467ee1b7a074b2a00",
"assets/fonts/Montserrat-ExtraBoldItalic.ttf": "62973b22103f5eac74e39acfd265cae5",
"assets/fonts/Montserrat-ExtraLight.ttf": "9ad37942bb6ac384b75ce1a65ecd78dc",
"assets/fonts/Montserrat-ExtraLightItalic.ttf": "bf34ba2c374854bc88e0050a5d0d323e",
"assets/fonts/Montserrat-Italic.ttf": "94843d8d9321098821fe6d64af3239c1",
"assets/fonts/Montserrat-Light.ttf": "f8fe32d3f0e1dca05f9eece295173bd5",
"assets/fonts/Montserrat-LightItalic.ttf": "bba75306e217801d52f8918a5808fb3d",
"assets/fonts/Montserrat-Medium.ttf": "f7c2cad2a5287ca6894cc1eb0080d855",
"assets/fonts/Montserrat-MediumItalic.ttf": "c8f07890599af48d986e8ecc160af375",
"assets/fonts/Montserrat-Regular.ttf": "5906fb82e31864c9b531898bb3c97d98",
"assets/fonts/Montserrat-SemiBold.ttf": "b80caec20382c61f0350f74ed67b7b0e",
"assets/fonts/Montserrat-SemiBoldItalic.ttf": "fbcd1ab76ddb1973492726bb397af05a",
"assets/fonts/Montserrat-Thin.ttf": "b60b82f5e87a84054c09bfa9ee39026f",
"assets/fonts/Montserrat-ThinItalic.ttf": "efa2a39cf4b6d2098a1d3effca3eeb3d",
"assets/NOTICES": "6972ec34fd8c99c299775801024f816a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "ff97fbd049f831fe706cc52348396e19",
"/": "ff97fbd049f831fe706cc52348396e19",
"main.dart.js": "010dc1044fdc0f0ac750fab44520f75b",
"manifest.json": "cb478734b13b14e2b6dc39204cbea174"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');

      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }

      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#')) {
    key = '/';
  }
  // If the URL is not the RESOURCE list, skip the cache.
  if (!RESOURCES[key]) {
    return event.respondWith(fetch(event.request));
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache. Ensure the resources are not cached
        // by the browser for longer than the service worker expects.
        var modifiedRequest = new Request(event.request, {'cache': 'reload'});
        return response || fetch(modifiedRequest).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    return self.skipWaiting();
  }

  if (event.message === 'downloadOffline') {
    downloadOffline();
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
