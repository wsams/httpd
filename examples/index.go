// Go CGI example for the go flavor.
// Build inside the container:
//   go build -o /var/www/html/index.cgi /path/to/index.go
//   chmod 755 /var/www/html/index.cgi
package main

import (
	"fmt"
	"net/http"
	"net/http/cgi"
	"runtime"
)

func main() {
	err := cgi.Serve(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(
			w,
			`<!DOCTYPE html><html><head><title>httpd go</title></head><body><h1>Go (CGI) is working</h1><p>%s</p></body></html>`,
			runtime.Version(),
		)
	}))
	if err != nil {
		panic(err)
	}
}
