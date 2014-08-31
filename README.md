# Execjs

[![Build Status](https://api.travis-ci.org/devinus/execjs.svg?branch=master)](https://travis-ci.org/devinus/execjs)

[![Support via Gratipay](https://raw.githubusercontent.com/twolfson/gittip-badge/0.2.1/dist/gittip.png)](https://gratipay.com/devinus/)

`Execjs` allows you run JavaScript from Elixir. It can automatically pick the
best runtime available on the system.

## Runtimes

`Execjs` supports the following runtimes:

- [Node.js](http://nodejs.org/)
- [SpiderMonkey](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey)
- [JavaScriptCore](http://trac.webkit.org/wiki/JSC)
- [Rhino](https://developer.mozilla.org/en-US/docs/Rhino)

Use the application environment (application key: `:execjs`, key: `:runtime`)
to set the runtime `Execjs` uses. Alternatively, the `EXECJS_RUNTIME`
environment variable can also be used to set the runtime.

## Usage

### `eval`

```iex
iex> Execjs.eval "'red yellow blue'.split(' ')"
["red", "yellow", "blue"]
```

### `compile`/`call`

```iex
iex> source = System.cmd("curl -sL --compressed https://rawgit.com/jashkenas/coffeescript/master/extras/coffee-script.js")
iex> context = Execjs.compile(source)
iex> Execjs.call(context, "CoffeeScript.compile", ["square = (x) -> x * x"])
"(function() {\n  var square;\n\n  square = function(x) {\n    return x * x;\n  };\n\n}).call(this);\n"
```


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/devinus/execjs/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
