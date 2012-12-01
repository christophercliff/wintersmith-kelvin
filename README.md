# wintersmith-kelvin

A production-ready asset management plugin for [Wintersmith](https://github.com/jnordberg/wintersmith).

## Features

- Concatenate and minify client-side JavaScript, CSS (LESS) and compiled JavaScript templates (Hogan.js).
- Separate modes for development and production.
- Embed fonts and images in your CSS.
- Versioned file names.
- Compatible with CDN.

## Usage

1. Add an `assets` configuration object to config.json.

```json
{
  "plugins": [
    "./node_modules/wintersmith-kelvin/"
  ],
  "locals": {
    "assets": {
      "css": {
        "all": [
          "/assets/css/*"
        ]
      },
      "js": {
        "all": [
          "/assets/js/*"
        ]
      },
      "jst": {
        "all": [
          "/assets/jst/*"
        ]
      }
    }
  }
}

````

2. Render asset packages in your templates.

```html
<html>
    <head>
        {{& assets.css.all }}
        {{& assets.js.all }}
        {{& assets.jst.all }}
    </head>
</html>
```

## Development & Production Modes

Preview server:

- Reference individual files in template
- Process LESS/CoffeeScript/Mustache into CSS & JavaScript
- Hash file contents into version number and concat w/ querystring

Production build:

- Reference combined files in template
- Convert images to data URIs
- Hash file contents into version number and concat w/ filename
- Minify HTML