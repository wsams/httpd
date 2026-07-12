def application(environ, start_response):
    body = (
        b"<!DOCTYPE html><html><head><title>httpd python</title></head>"
        b"<body><h1>Python (mod_wsgi) is working</h1></body></html>"
    )
    start_response(
        "200 OK",
        [
            ("Content-Type", "text/html; charset=utf-8"),
            ("Content-Length", str(len(body))),
        ],
    )
    return [body]
