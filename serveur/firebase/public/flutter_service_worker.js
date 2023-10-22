'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-192x192.png": "e1001502ad64acf96ad22bc69d8f4077",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-36x36.png": "1a349ae150f50f0e5fdc8cc58d3811b7",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-48x48.png": "2a527c47f65f9b4727451eac730b6c44",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-72x72.png": "6bc3e68b94f5d565e64ca2d6fb62b1bc",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-96x96.png": "e6c299666ab61959fab3a04e88a18312",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-114x114.png": "568598c946da4cda6ad80e6458157076",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-120x120.png": "3370e018aef1d353612e909cd2c96f05",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-152x152.png": "53b4a85ae2ac3630f42bfe5eb7f14c3d",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-180x180.png": "87911d9b118c866f2910f7ce990ab40e",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-57x57.png": "78bd388782d75e444723786692149dd4",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-60x60.png": "112570e26229965bd7d2d55214a42e2d",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-72x72.png": "6bc3e68b94f5d565e64ca2d6fb62b1bc",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-76x76.png": "41fee404f5d8744d21dedf6293505543",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-precomposed.png": "d8bde5783b72857f30d85d179524de76",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon.png": "d8bde5783b72857f30d85d179524de76",
"26f676da641b1786c359c8ac9924a4b5.ico/browserconfig.xml": "97775b1fd3b6e6c13fc719c2c7dd0ffe",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon-32x32.png": "0ef796d89524b266f2fd31a11bf2cdc9",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon-96x96.png": "e6c299666ab61959fab3a04e88a18312",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon.ico": "8ffefa5f964349deb2052998818521a4",
"26f676da641b1786c359c8ac9924a4b5.ico/manifest.json": "e50e6a1c9ed6452635d3211f39501e0d",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-150x150.png": "073a4e6cad8590c5d2f46e3134c3905c",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-310x310.png": "be12a70ce74c3903a2ad4f82a4f3ffb9",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-70x70.png": "5fbf397c40caeccb4294c7055f40c307",
"assets/AssetManifest.bin": "22778950ed68be9d685b27ec28b69851",
"assets/AssetManifest.json": "462442bd85f110a43cf56b698a5a5ae0",
"assets/assets/images/IPIC_logo_petit.png": "ce25e5d0a37d3556ab45ec6d44857ee3",
"assets/assets/images/vidar_logo.png": "e194d7095a47a758cada139b0127e520",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "a0464ae7b494ef29bfbab7fa73bbf613",
"assets/NOTICES": "4599cbad48dba4d912d979d6076e50a7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.png": "ca40e9392d0d2200d7dfd8c6ec0b0dee",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "20537dd695465e417e6c4932fa2a4669",
"/": "20537dd695465e417e6c4932fa2a4669",
"main.dart.js": "5b6c5853184a2e83c5eec3c4f5839e69",
"manifest.json": "52791d4d56a2b25c0536ebef05e73d5e",
"version.json": "0625f5950af80c4dc8a4c0688ceb4cab"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
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
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
