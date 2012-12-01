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
<head>
    {{& assets.css.all }}
    {{& assets.js.all }}
    {{& assets.jst.all }}
</head>
```

## Development & Production Modes

### Development:

- Reference individual files in template
- Process LESS/CoffeeScript/Mustache into CSS & JavaScript
- Hash file contents into version number and concat w/ querystring

Example:

```html
<head>
    <link href="/assets/css/a.less-11c79d7af01a966bb9ffc85dc2f263a5.css" rel="stylesheet" />
    <link href="/assets/css/b.less-42d332172f5921f12af280991b3471cd.css" rel="stylesheet" />
    <script src="/assets/js/a.js-b445739a15cb081a291454401bb98627.js"></script>
    <script src="/assets/js/b.js-c6e6cf9f70dd97eea7164bf89cd5c015.js"></script>
    <script src="/assets/jst/a.mustache-3c88bce4627932bf7aa1387d59eb5cd4.js"></script>
    <script src="/assets/jst/b.mustache-163b93966aa63e7713eabc8e88deb711.js"></script>
</head>
```

### Production:

- Reference combined files in template
- Convert images to data URIs
- Hash file contents into version number and concat w/ filename
- Minify HTML

Example:

```html
<head>
    <link href="//kelvin.cloudfront.net/assets/css/all-11c79d7af01a966bb9ffc85dc2f263a5.css" rel="stylesheet" />
    <script src="//kelvin.cloudfront.net/assets/js/all-b445739a15cb081a291454401bb98627.js"></script>
    <script src="//kelvin.cloudfront.net/assets/jst/all-163b93966aa63e7713eabc8e88deb711.js"></script>
</head>
```