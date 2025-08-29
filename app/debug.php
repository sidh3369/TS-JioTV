<?php
$url = "https://jiotvapi.media.jio.com/live/173.m3u8"; // example, replace with real Jio endpoint your code calls
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "User-Agent: okhttp/3.14.9",
    "appname: RJIL_JioTV"
    // add token headers here if needed
]);
$response = curl_exec($ch);

if ($response === false) {
    echo "cURL error: " . curl_error($ch);
} else {
    echo "Response (first 500 bytes):<br><pre>" . htmlspecialchars(substr($response, 0, 500)) . "</pre>";
}
curl_close($ch);
