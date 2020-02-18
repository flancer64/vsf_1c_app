# vsf_1c_app

VueStorefront app to test integration with 1C.

# Links
- https://api.test.vsf21c.flancer64.com/
- https://front.test.vsf21c.flancer64.com/

Attention: SSL certs are self-signed, so you need to go to API first and accept self-signed cert before front URL opening.



# Deployment
```
$ cp cfg.init.sh cfg.local.sh
$ nano cfg.local.sh
...
$ bash ./bin/deploy/all.sh
```



# Start/stop the app
```
$ bash ./bin/start.sh
$ bash ./bin/stop.sh
```