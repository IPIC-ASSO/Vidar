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
"assets/AssetManifest.bin": "55e42e6e8697320b9275d95e3b582aaa",
"assets/AssetManifest.bin.json": "d06e07d128a1d0b3f474e20d62ca89b9",
"assets/AssetManifest.json": "fbf6d7f95cd71d95dafadc26f9e240da",
"assets/assets/images/IPIC_logo_petit.png": "ce25e5d0a37d3556ab45ec6d44857ee3",
"assets/assets/images/vidar_logo.png": "2e877ab56337549c8b19df8be4a98a77",
"assets/assets/tutoriel/tuto_1.png": "c7ae8cd2e70586b7eb950238d51d0373",
"assets/assets/tutoriel/tuto_12.png": "7f55203b6e294f8ca28c887a1294970d",
"assets/assets/tutoriel/tuto_2.png": "fb0294961b57d0e4577f0fe2e9a28899",
"assets/assets/tutoriel/tuto_3.png": "b27744c207398713103196c0e2578e1f",
"assets/assets/tutoriel/tuto_4.png": "81921f83c062278cc78b2a50edd17658",
"assets/assets/tutoriel/tuto_5.png": "ab9eeb6f3f007136f45945cb3235863a",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "7618020043445257b91b129f639589df",
"assets/NOTICES": "55e2c79ed7de909d8319428739abef09",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"icons/android-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/android-icon-192x192.png": "364fe49d763ebcfafa953754d55d8cee",
"icons/android-icon-36x36.png": "48caa1b97297966f6264e68b49658b50",
"icons/android-icon-48x48.png": "2f3158f86264a457490c0a2dced63e67",
"icons/android-icon-72x72.png": "9269aaba12e7b7dbe4b73ef6aa16b7f3",
"icons/android-icon-96x96.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"icons/apple-icon-114x114.png": "e6f7024198f283b03747a25f4f99ee07",
"icons/apple-icon-120x120.png": "19e6e6683407e258575e32c59b74c122",
"icons/apple-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/apple-icon-152x152.png": "9f9e0a7ea66be978d40e4bc72d915fa2",
"icons/apple-icon-180x180.png": "f379f11fb34082dce9e3aeb1e4a1c40b",
"icons/apple-icon-57x57.png": "3504abfa22c4a0d367dc57b4eacb153b",
"icons/apple-icon-60x60.png": "b4f4f627386552fed57a92db491c5049",
"icons/apple-icon-72x72.png": "9269aaba12e7b7dbe4b73ef6aa16b7f3",
"icons/apple-icon-76x76.png": "ad28a51294f87eefc2ea487549078d5f",
"icons/apple-icon-precomposed.png": "1c9ad6ee614f737d4a5dd369e3f8bef2",
"icons/apple-icon.png": "1c9ad6ee614f737d4a5dd369e3f8bef2",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/favicon-16x16.png": "8db9368499160b10a08099631bb15d59",
"icons/favicon-32x32.png": "4e702b08342a8e0e9f4cf4133a074b2f",
"icons/favicon-96x96.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"icons/favicon.ico": "36895df6d2e0c0eb7f7383ad466b9185",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"icons/ms-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/ms-icon-150x150.png": "056245285978cb3b78414a87f7fe9b3e",
"icons/ms-icon-310x310.png": "33395fd15700b44558be336690544681",
"icons/ms-icon-70x70.png": "a2d80e2b279a8dff3e10ded083aae12d",
"index.html": "4d1f56c2b82385fb33448fad16289d93",
"/": "4d1f56c2b82385fb33448fad16289d93",
"main.dart.js": "ff537b89b201c2209578a425f579b224",
"manifest.json": "52791d4d56a2b25c0536ebef05e73d5e",
"version.json": "f785fa6194d19fcbdc53b9eae95ce103"};
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
