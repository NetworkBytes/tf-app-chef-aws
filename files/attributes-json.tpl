{
  "chef-server": {
    "accept_license": ${license},
    "addons": [${addons}],
    "configuration": {
      "notification_email": "john@bencic.net",
      "chef-server-webui": {
        "enable": true
      }
    }
  },
  "run_list": [
    "recipe[chef-server::default]"
  ]
}
