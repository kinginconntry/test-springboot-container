package test_springboot_container

import (
	"log"
	"net/http"
	"os"
)

func main() {
	//api接口
	http.HandleFunc("/api/v1/hello", func(writer http.ResponseWriter, request *http.Request) {
		return
	}) //用于存活检测

	err := http.ListenAndServe("0.0.0.0:8080", nil)

	if err != nil {
		log.Printf("ListenAndServe:%v", err)
		os.Exit(2)
	}
}
