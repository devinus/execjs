# Execjs

[![Build Status](https://travis-ci.org/devinus/execjs.svg?branch=master)](https://travis-ci.org/devinus/execjs)
[![Hex.pm Version](https://img.shields.io/hexpm/v/execjs.svg?style=flat-square)](https://hex.pm/packages/execjs)
[![Hex.pm Download Total](https://img.shields.io/hexpm/dt/execjs.svg?style=flat-square)](https://hex.pm/packages/execjs)

`Execjs` allows you easily run JavaScript from Elixir. It can automatically
pick the best runtime available on the system.

## Runtimes

`Execjs` supports the following runtimes:

- [Node.js](https://nodejs.org/en/)
- [V8](https://developers.google.com/v8/)
- [SpiderMonkey](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/SpiderMonkey)
- [JavaScriptCore](https://trac.webkit.org/wiki/JSC)
- [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino)

Use the application environment (application key: `:execjs`, key: `:runtime`)
to set the runtime `Execjs` uses. Alternatively, the `EXECJS_RUNTIME`
environment variable can also be used to set the runtime.

## Usage

### `eval`

```iex
iex> "'red yellow blue'.split(' ')" |> Execjs.eval
["red", "yellow", "blue"]
```

### `compile`/`call`

```iex
iex> {source, 0} = System.cmd("curl", ["-fsSL", "--compressed", "https://coffeescript.org/browser-compiler/coffeescript.js"])
iex> context = Execjs.compile(source)
iex> Execjs.call(context, "CoffeeScript.compile", ["square = (x) -> x * x"])
"(function() {\n  var square;\n\n  square = function(x) {\n    return x * x;\n  };\n\n}).call(this);\n"
```
