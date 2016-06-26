# lua-haproxy

**lua-haproxy** provides:

* a high-level Lua binding for the [HAProxy stats interface](https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#9.2)
* an embedded HTTP API that runs as a [service inside HAProxy](http://www.arpalert.org/src/haproxy-lua-api/1.6/)

## Requirements

* Linux
* HAProxy 1.6+ with Lua support

    To check if your version includes Lua, run:

    ```
    haproxy -vv | grep Lua
    ```
* HAProxy must run in single-process mode (default)
* Lua 5.3 and Luarocks for development

## Install

1. Clone the repo.

    ```
    git clone https://github.com/benwebber/lua-haproxy
    ```
2. Install the rock.

    ```
    luarocks install haproxy-scm-0.rockspec
    ```
3. Configure HAProxy to run the Lua service.

    It might be convenient to run the API on a dedicated port:

    ```
    global
      stats socket /run/haproxy/admin.sock mode 660 level admin
      lua-load /usr/local/bin/lua-haproxy-api

    listen http
      bind *:8000
      mode http
      http-request use-service lua.haproxy-api
    ```

## Embedded API

The [main entry point](lua/main.lua) for this package provides an embedded HTTP API. The API runs as a Lua service inside HAProxy. Use it to introspect the parent process.

### Overview

Requests that create or modify resources should be encoded as JSON (`Content-Type: application/json`).

The API will return structured data as JSON, and unstructured data as plain text (`Content-Type: text/plain`).

### Endpoints

#### `config`

| METHOD | PATH      | DESCRIPTION                                         |
|--------|-----------|-----------------------------------------------------|
| `GET`  | `/config` | Return the active configuration file in plain text. |


#### `stats`

| METHOD  | PATH                                              | DESCRIPTION                                                    |
|---------|---------------------------------------------------|----------------------------------------------------------------|
| `GET`   | `/stats`                                          | Query the stats socket for process statistics.                 |
| `GET`   | `/stats/backends`                                 | Show statistics for all backends.                              |
| `GET`   | `/stats/backends/:backend`                        | Show statistics for the named backend.                         |
| `GET`   | `/stats/backends/:backend/servers`                | Show statistics for all servers in the named backend.          |
| `GET`   | `/stats/backends/:backend/servers/:server`        | Show statistics for the a specific server in the named backed. |
| `GET`   | `/stats/backends/:backend/servers/:server/weight` | Get the current weight of a server.                            |
| `PATCH` | `/stats/backends/:backend/servers/:server/weight` | Set the weight of a server.                                    |
| `GET`   | `/stats/backends/:backend/servers/:server/state`  | Get the current state of a server.                             |
| `PATCH` | `/stats/backends/:backend/servers/:server/state`  | Set the state of a server.                                     |
| `GET`   | `/stats/info`                                     | Query the stats socket for process info.                       |
| `GET`   | `/stats/frontends`                                | Show statistics for all frontends.                             |
| `GET`   | `/stats/frontends/:frontend`                      | Show statistics for the named frontend.                        |

## Documentation

Refer to the Lua API documentation for details:

https://benwebber.github.io/lua-haproxy/

## Caveats

**lua-haproxy** is *not* production-ready. Both the internal Lua API and embedded HTTP APIs are unstable.

## License

MIT
