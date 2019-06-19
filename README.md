# mu.semte.ch LDF example
This is a proof of concept setup of linked data fragments in a mu.semte.ch stack. To run, clone this repository and run `docker-compose up -d`. You may want to add a port mapping (`80:80`) to the mandaten service, the entrypoint of this stack.

To add LDF to a linked data stack the following steps were taken:

1. add the service to the docker-compose:
```
  ldf:
    image: linkeddatafragments/server.js:release-v2.2.5
    volumes:
      - ./config/ldf.json:/app/config.json
    command: "/app/config.json"
```

2. create the proper [configuration](config/ldf.json), note that baseURL was set to `/ldf/`. This needs to correspond to the path used in the dispatcher.

3. add the proper rule to the dispatcher (this snippet overrides the host header on the request, as detailed in the [server.js repository](https://github.com/LinkedDataFragments/Server.js#optional-set-up-a-reverse-proxy)):
```
  match "/ldf/*path" do
    forwarded_for_host =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-for")
      |> Enum.at(0)
    new_headers =
      conn.req_headers
      |> List.keydelete("host", 0)
      |> put_new_key("Host", forwarded_for_host)
    conn
    |> Map.put(:req_headers, new_headers)
    |> Map.put(:host, forwarded_for_host)
    |> Proxy.forward(path, "http://ldf:3000/ldf/")
  end
```

To also handle the landing page (which runs on /ldf and not /ldf/ ) add an extra rule:

```
  # handle landing page of linked data fragments
  get "/ldf/" do
    forwarded_for_host =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-for")
      |> Enum.at(0)
    new_headers =
      conn.req_headers
      |> List.keydelete("host", 0)
      |> put_new_key("Host", forwarded_for_host)
    conn
    |> Map.put(:req_headers, new_headers)
    |> Map.put(:host, forwarded_for_host)
    |> Proxy.forward([], "http://ldf:3000/ldf")
  end
```
