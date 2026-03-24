# casm-curl

##  Introduction

This is an exploratory project to learn more about low-level languages and network programming. It is an HTTP client for sending requests across the internet. Given that it is written in Assembly and C, the name is casm-curl (C + Assembly - cURL).

## Functionality

The Assembly code parses the program parameters and handles the syscalls for creating a socket, establishing a connection, sending the request, and printing the response.

Given that domain resolution happens in user space instead of kernel space, writing that logic in Assembly would have been too complex. Therefore, it was implemented in a C function, which handles all URL parsing, including the extraction of the scheme, domain, and port, and ultimately resolves that domain into an IP address. Besides, handling strings in Assembly is too cumbersome, so I took this opportunity to explore how to combine two different programming languages.

## Limitations

This a simplistic project, it is not meant for production use. It has several constraints:

- Doesn **NOT** support HTTPS
- Only sends GET requests
- Does **NOT** set the `Host` header on the Request, which can cause errors with remote servers
- Does **NOT** send sub-paths or query params

## Execution

- Install libcurl library
- The source code can be compiled with the `make` command
- It can be used against any server that returns an HTTP response (**NOT** HTTPs), such as a local python server or this [custom Go http server](https://github.com/elielberra/http-server) I wrote
- Execute the `casm-curl` binary, passing the URL to which you want to send the request as the first parameter

### Example for Debian distro

```bash
sudo apt install libcurl4-openssl-dev -y
python3 -m http.server 8000 --bind 127.0.0.1
make
./casm-curl "localhost:8000"
```
