<?php
header('Content-Type: text/html; charset=utf-8');
echo '<!DOCTYPE html><html><head><title>httpd php</title></head><body>';
echo '<h1>PHP is working</h1>';
echo '<p>PHP ' . htmlspecialchars(PHP_VERSION) . '</p>';
echo '</body></html>';
