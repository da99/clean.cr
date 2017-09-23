clean.cr
==========

A Crystal shard full of functions to clean HTML-releated content.

You don't want to use this shard because it's too specific for my needs.

However, if you know of another sanitization shards,
please let me know in the "issues" section
so i can tell others about it.

Usage
=============

```crystal
  require "clean"

  Mu_Clean.attr("input", {"type"=>"hidden", "value"=>"my val"})
  Mu_Clean.attr("meta", {"name"=>"keywords", "content"=>" <my content> "})
  Mu_Clean.escape_html("my <html>")
```

