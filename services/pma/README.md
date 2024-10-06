# Generate htpassword for http basic auth

- Generate

```shell
docker run --rm httpd:2.4-alpine htpasswd -nbB username password
```

- Result

```shell
username:$2y$05$hoC5xYfnFpvAVn3pvGPKeuCfuLQaRUnnBRwKz.vgy1lhF2MdUThim
```

- Add extra $ to make it work

```shell
username:$$2y$$05$$hoC5xYfnFpvAVn3pvGPKeuCfuLQaRUnnBRwKz.vgy1lhF2MdUThim
```
