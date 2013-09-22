
require.config
  paths:
    jquery: "vendor/jquery"
    underscore: "vendor/underscore"
    backbone: "vendor/backbone"
    forbid:   "vendor/forbid-selected"
  shim:
    underscore: 
      exports: "_"
    backbone:
      deps: ["underscore", "jquery"]
      exports: "Backbone"

window.App =
  # apiHost: 'http://my.sunzhimeng.com'
  apiHost: 'http://0.0.0.0:3001'

require ["app"]

