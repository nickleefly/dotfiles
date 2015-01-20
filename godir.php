#!/usr/bin/php -d open_basedir=
<?php

$dir_history = array_key_exists("__dir_history", $_SERVER)
  ? $_SERVER["__dir_history"] : $_SERVER["HOME"];
if (!$dir_history) $dir_history = $_SERVER["HOME"];
$dir_history = split(":", $dir_history);
$dir_index = array_key_exists("__dir_index", $_SERVER) ? $_SERVER["__dir_index"] : 0;

$argv = $_SERVER["argv"];
$argc = $_SERVER["argc"];

if ($argc < 2) array_push($argv, $_SERVER['HOME']);

$cdpath = $_SERVER["CDPATH"];
if ($cdpath !== "." && false === strpos($cdpath, ".:") && false === strpos($cdpath, ":.")) {
  $cdpath .= ($cdpath ? ":" : "") . ".";
}
$cdpath = split(":", $cdpath);

$arg = $argv[1];
$dir = "";

if ($arg === "--show") {
  show_settings();
  exit(0);
} else if ($arg{0} === "/" && is_dir(realpath($arg))) {
  $dir = $arg;
} else foreach ($cdpath as $cp) {
  $dir = "$cp/$arg";
  if ($dir{0} === ".") $dir = $_SERVER["PWD"]. "/$dir";
  if (!is_dir(realpath($dir))) $dir = null;
  else break;
}
$dir = dotlesspath($dir);
if ($dir && array_key_exists($dir_index, $dir_history) &&
    realpath($dir) === realpath($dir_history[ $dir_index ]) ) {
  // just cd, but don't update history or position, unless it's cleaner
  cmd("cd ". esc($dir));
  if (strlen($dir) < strlen($dir_history[ $dir_index ])) {
    $dir_history[ $dir_index ] = $dir;
    update($dir_index, $dir_history);
  }
} else if ($dir) {
  // update the history and index.
  $dir_index ++;
  $dir_history = array_slice($dir_history, 0, $dir_index);
  $dir_history[ $dir_index ] = $dir;
  cmd("cd ". esc($dir));
  update($dir_index, $dir_history);
} else {
  if ($arg === "-") $arg = -1;
  $arg = 1 * $arg;
  if ($arg !== 0 && is_int($arg)) {
    $di = $dir_index + $arg;
    if ($di < 0) $di = 0;
    else if ($di >= count($dir_history)) $di = count($dir_history) - 1;
    if ($di !== (1*$dir_index)) {
      $dir_index = $di;
      cmd("cd ". esc($dir_history[$di]));
      update($di, $dir_history);
    }
  } else {
    error_log("bad arg: $arg");
    usage();
  }
}


//// helpers below
function esc ($dir) {
  return str_replace(" ", "\\ ", escapeshellcmd($dir));
}

function update ($dir_index, $dir_history) {
  cmd("__dir_index=$dir_index");
  cmd("export __dir_index");
  cmd("__dir_history=" . esc(implode(":", $dir_history)));
  cmd("export __dir_history");
}

function cmd ($c) {
  // error_log("        $c");
  static $f = false;
  if ($f) echo " && ";
  $f = true;
  echo $c;
}

function usage () {
  error_log("Usage:  ");
  error_log(basename($argv[0]) ." [<dir> | <n>]");
  error_log("  dir   - A directory to cd into");
  error_log("  n     - A positive or negative integer to move forward or back in dir history");
  error_log("");
  show_settings();
  exit(1);
}

function show_settings () {
  global $dir_history;
  global $dir_index;
  error_log("history: ");
  foreach ($dir_history as $k => $dir) {
    $n = ($k == $dir_index) ? "—–>" : ($k - $dir_index);
    while (strlen($n) < 3) $n = " $n";
    error_log("    $n: $dir");
  }
  error_log("  index: ". $dir_index);
  error_log('   $PWD: '. $_SERVER["PWD"]);
  error_log(" go dir: ". $dir_history[ $dir_index ]);
}

function dotlesspath ($path) {
  $path = explode("/", $path);
  $out = array();
  foreach ($path as $part) {
    if ($part === ".") continue;
    else if ($part === "..") array_pop($out);
    else $out[] = $part;
  }
  return implode("/", $out);
}
