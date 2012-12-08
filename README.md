# wintersmith-kelvin

A production-ready asset management plugin for [Wintersmith](https://github.com/jnordberg/wintersmith).

[![Build Status](https://travis-ci.org/christophercliff/wintersmith-kelvin.png)](https://travis-ci.org/christophercliff/wintersmith-kelvin)

## Features

- Concatenate and minify client-side JavaScript, CSS (LESS) and compiled JavaScript templates (Hogan.js).
- Separate modes for development and production.
- Embed fonts and images in your CSS.
- Versioned file names.
- Compatible with CDN.

## Installation

Install the package locally using npm:

`npm install wintersmith-kelvin`

Then add the plugin to your `config.json`:

```json
{
  "plugins": [
    "./node_modules/wintersmith-kelvin/"
  ]
}
````

## Usage

### Configuration

Use the `locals` object in the [Wintersmith config](https://github.com/jnordberg/wintersmith#config) to configure Kelvin.

<table>
    <tr>
        <th>Name</th>
        <th>Default</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>assets</td>
        <td>{}</td>
        <td>The assets object containing your package declarations.</td>
    </tr>
    <tr>
        <td>mode</td>
        <td>development</td>
        <td>E.g. "development" or "production".</td>
    </tr>
    <tr>
        <td>cdn</td>
        <td>undefined</td>
        <td>If defined, will prepend a CDN host to asset references in production mode. E.g. "foo.cloudfront.net". Kelvin will generate protocol-relative URLs.</td>
      </tr>
</table>

### Rendering

Kelvin will convert your package declarations into `<script>` and `<link>` tags to be rendered in template files. Using Mustache syntax:

```mustache
    {{& assets.css.all }}
    {{& assets.js.all }}
    {{& assets.jst.all }}
```

## Modes

### Development

Development mode is meant to be run locally on the preview server. Files are transformed into CSS or JavaScript, but loaded separately and cache busted. An example [development config](https://github.com/christophercliff/wintersmith-kelvin/blob/master/example/config.json) might render the following:

```html
<link href="/assets/css/a.less-1e2e639b152465ce8f19922f7e1eb00c.css" rel="stylesheet" />
<link href="/assets/css/b.less-87b645564b890cdf0c9243d7fc00e8fd.css" rel="stylesheet" />
<script src="/assets/js/a.js-b445739a15cb081a291454401bb98627.js"></script>
<script src="/assets/js/b.js-c6e6cf9f70dd97eea7164bf89cd5c015.js"></script>
<script>var Hogan=Hogan||{},JST=JST||{};(function(e,t){function a(e){return String(e===null||e===undefined?"":e)}function f(e){return e=a(e),u.test(e)?e.replace(n,"&amp;").replace(r,"&lt;").replace(i,"&gt;").replace(s,"&#39;").replace(o,"&quot;"):e}e.Template=function(e,n,r,i){this.r=e||this.r,this.c=r,this.options=i,this.text=n||"",this.buf=t?[]:""},e.Template.prototype={r:function(e,t,n){return""},v:f,t:a,render:function(t,n,r){return this.ri([t],n||{},r)},ri:function(e,t,n){return this.r(e,t,n)},rp:function(e,t,n,r){var i=n[e];return i?(this.c&&typeof i=="string"&&(i=this.c.compile(i,this.options)),i.ri(t,n,r)):""},rs:function(e,t,n){var r=e[e.length-1];if(!l(r)){n(e,t,this);return}for(var i=0;i<r.length;i++)e.push(r[i]),n(e,t,this),e.pop()},s:function(e,t,n,r,i,s,o){var u;return l(e)&&e.length===0?!1:(typeof e=="function"&&(e=this.ls(e,t,n,r,i,s,o)),u=e===""||!!e,!r&&u&&t&&t.push(typeof e=="object"?e:t[t.length-1]),u)},d:function(e,t,n,r){var i=e.split("."),s=this.f(i[0],t,n,r),o=null;if(e==="."&&l(t[t.length-2]))return t[t.length-1];for(var u=1;u<i.length;u++)s&&typeof s=="object"&&i[u]in s?(o=s,s=s[i[u]]):s="";return r&&!s?!1:(!r&&typeof s=="function"&&(t.push(o),s=this.lv(s,t,n),t.pop()),s)},f:function(e,t,n,r){var i=!1,s=null,o=!1;for(var u=t.length-1;u>=0;u--){s=t[u];if(s&&typeof s=="object"&&e in s){i=s[e],o=!0;break}}return o?(!r&&typeof i=="function"&&(i=this.lv(i,t,n)),i):r?!1:""},ho:function(e,t,n,r,i){var s=this.c,o=this.options;o.delimiters=i;var r=e.call(t,r);return r=r==null?String(r):r.toString(),this.b(s.compile(r,o).render(t,n)),!1},b:t?function(e){this.buf.push(e)}:function(e){this.buf+=e},fl:t?function(){var e=this.buf.join("");return this.buf=[],e}:function(){var e=this.buf;return this.buf="",e},ls:function(e,t,n,r,i,s,o){var u=t[t.length-1],a=null;if(!r&&this.c&&e.length>0)return this.ho(e,u,n,this.text.substring(i,s),o);a=e.call(u);if(typeof a=="function"){if(r)return!0;if(this.c)return this.ho(a,u,n,this.text.substring(i,s),o)}return a},lv:function(e,t,n){var r=t[t.length-1],i=e.call(r);if(typeof i=="function"){i=a(i.call(r));if(this.c&&~i.indexOf("{{"))return this.c.compile(i,this.options).render(r,n)}return a(i)}};var n=/&/g,r=/</g,i=/>/g,s=/\'/g,o=/\"/g,u=/[&<>\"\']/,l=Array.isArray||function(e){return Object.prototype.toString.call(e)==="[object Array]"}})(typeof exports!="undefined"?exports:Hogan)</script>
<script src="/assets/jst/a.mustache-3c88bce4627932bf7aa1387d59eb5cd4.js"></script>
<script src="/assets/jst/b.mustache-163b93966aa63e7713eabc8e88deb711.js"></script>
```

### Production

Production mode is meant to be run programatically. Files are transformed, combined and minified. An example [production config](https://github.com/christophercliff/wintersmith-kelvin/blob/master/example/config_prod.json) might render the following:

```html
<link href="//abc.cloudfront.net/assets/css/all-411db7247c935a328a264bee62881196.css" rel="stylesheet">
<script src="//abc.cloudfront.net/assets/js/all-e08d2578b50d4bd9d3ab3b4c892f1f7b.js"></script>
<script src="//abc.cloudfront.net/assets/jst/all-b098f354b09fe46fe4f125b5b66ba481.js"></script>
```

## Acknowledgements

Kelvin was inspired by and incorporates code from the following projects:

- [nap](https://github.com/craigspaeth/nap)
- [wintersmith-hogan](https://github.com/sfrdmn/wintersmith-hogan)
- [wintersmith-less](https://github.com/jnordberg/wintersmith-less)