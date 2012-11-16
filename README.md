# wintersmith-kelvin

A production-ready asset management plugin for [Wintersmith](https://github.com/jnordberg/wintersmith).

## Features

- Compiles and combines JavaScript, LESS and Mustache templates.
- Separate modes for development and production.
- Embed fonts and images in your CSS.
- Versioned file names.
- Compatible with your CDN.

## Overview

1. Declare asset packages in an `assets.json` file located in the `./contents` directory.

```json
{
  "css": {
    "all": [
      "./assets/css/*"
    ]
  },
  "js": {
    "all": [
      "./assets/js/*"
    ]
  },
  "jst": {
      "all": [
        "./assets/jst/*"
      ]
    }
}
````

2. Render asset packages in your templates.

```mustache
<html>
    <head>
        {{& css.all }}
        {{& js.all }}
        {{& jst.all }}
    </head>
</html>
```