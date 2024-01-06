'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "ce6f02670468f9e94c9e9d381248bc33",
"index.html": "69df9d2884c30bdcbf5c79d0b734f0b9",
"/": "69df9d2884c30bdcbf5c79d0b734f0b9",
"main.dart.js": "da1c354c9bc4fde36dca13d12467c141",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon.ico": "8ffefa5f964349deb2052998818521a4",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon.png": "d8bde5783b72857f30d85d179524de76",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-192x192.png": "e1001502ad64acf96ad22bc69d8f4077",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-precomposed.png": "d8bde5783b72857f30d85d179524de76",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-114x114.png": "568598c946da4cda6ad80e6458157076",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-310x310.png": "be12a70ce74c3903a2ad4f82a4f3ffb9",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-57x57.png": "78bd388782d75e444723786692149dd4",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-152x152.png": "53b4a85ae2ac3630f42bfe5eb7f14c3d",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-150x150.png": "073a4e6cad8590c5d2f46e3134c3905c",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-72x72.png": "6bc3e68b94f5d565e64ca2d6fb62b1bc",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-96x96.png": "e6c299666ab61959fab3a04e88a18312",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-36x36.png": "1a349ae150f50f0e5fdc8cc58d3811b7",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-180x180.png": "87911d9b118c866f2910f7ce990ab40e",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon-96x96.png": "e6c299666ab61959fab3a04e88a18312",
"26f676da641b1786c359c8ac9924a4b5.ico/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-48x48.png": "2a527c47f65f9b4727451eac730b6c44",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-76x76.png": "41fee404f5d8744d21dedf6293505543",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-60x60.png": "112570e26229965bd7d2d55214a42e2d",
"26f676da641b1786c359c8ac9924a4b5.ico/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"26f676da641b1786c359c8ac9924a4b5.ico/android-icon-144x144.png": "3f25cfbe1ed437784133545cb5c5f55d",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-72x72.png": "6bc3e68b94f5d565e64ca2d6fb62b1bc",
"26f676da641b1786c359c8ac9924a4b5.ico/apple-icon-120x120.png": "3370e018aef1d353612e909cd2c96f05",
"26f676da641b1786c359c8ac9924a4b5.ico/favicon-32x32.png": "0ef796d89524b266f2fd31a11bf2cdc9",
"26f676da641b1786c359c8ac9924a4b5.ico/ms-icon-70x70.png": "5fbf397c40caeccb4294c7055f40c307",
"favicon.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"icons/favicon-16x16.png": "8db9368499160b10a08099631bb15d59",
"icons/favicon.ico": "36895df6d2e0c0eb7f7383ad466b9185",
"icons/apple-icon.png": "1c9ad6ee614f737d4a5dd369e3f8bef2",
"icons/apple-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/android-icon-192x192.png": "364fe49d763ebcfafa953754d55d8cee",
"icons/apple-icon-precomposed.png": "1c9ad6ee614f737d4a5dd369e3f8bef2",
"icons/apple-icon-114x114.png": "e6f7024198f283b03747a25f4f99ee07",
"icons/ms-icon-310x310.png": "33395fd15700b44558be336690544681",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/ms-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/apple-icon-57x57.png": "3504abfa22c4a0d367dc57b4eacb153b",
"icons/apple-icon-152x152.png": "9f9e0a7ea66be978d40e4bc72d915fa2",
"icons/ms-icon-150x150.png": "056245285978cb3b78414a87f7fe9b3e",
"icons/android-icon-72x72.png": "9269aaba12e7b7dbe4b73ef6aa16b7f3",
"icons/android-icon-96x96.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"icons/android-icon-36x36.png": "48caa1b97297966f6264e68b49658b50",
"icons/apple-icon-180x180.png": "f379f11fb34082dce9e3aeb1e4a1c40b",
"icons/favicon-96x96.png": "6aac0315a51a0ce3d1e0a6238c555e0c",
"icons/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"icons/android-icon-48x48.png": "2f3158f86264a457490c0a2dced63e67",
"icons/apple-icon-76x76.png": "ad28a51294f87eefc2ea487549078d5f",
"icons/apple-icon-60x60.png": "b4f4f627386552fed57a92db491c5049",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/android-icon-144x144.png": "32d2afe9b3af57a5c798119f810e4c86",
"icons/apple-icon-72x72.png": "9269aaba12e7b7dbe4b73ef6aa16b7f3",
"icons/apple-icon-120x120.png": "19e6e6683407e258575e32c59b74c122",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/favicon-32x32.png": "4e702b08342a8e0e9f4cf4133a074b2f",
"icons/ms-icon-70x70.png": "a2d80e2b279a8dff3e10ded083aae12d",
"manifest.json": "cc8b5e7d1c2f12129950ced10f1534cb",
"assets/AssetManifest.json": "462442bd85f110a43cf56b698a5a5ae0",
"assets/NOTICES": "7fd83ea7b6aee5a32e9e315b710c8741",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "22778950ed68be9d685b27ec28b69851",
"assets/fonts/MaterialIcons-Regular.otf": "5d0dcdb7ddcf781840a678a463232dcd",
"assets/assets/images/vidar_logo.png": "2e877ab56337549c8b19df8be4a98a77",
"assets/assets/images/IPIC_logo_petit.png": "ce25e5d0a37d3556ab45ec6d44857ee3",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"canvaskit/chromium/canvaskit.js": "ffb2bb6484d5689d91f393b60664d530",
"canvaskit/chromium/canvaskit.wasm": "393ec8fb05d94036734f8104fa550a67",
"canvaskit/canvaskit.js": "5caccb235fad20e9b72ea6da5a0094e6",
"canvaskit/canvaskit.wasm": "d9f69e0f428f695dc3d66b3a83a4aa8e",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
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
