package main

import (
	"fmt"
	"log"
	"net/http"
)

func health(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("got /health request\n")
	w.WriteHeader(http.StatusOK)
}

func metrics(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("got /metrics request\n")
	w.WriteHeader(http.StatusOK)
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("got root request\n")
		w.WriteHeader(http.StatusOK)
	})
	http.HandleFunc("/health", health)
	http.HandleFunc("/metrics", metrics)

	fmt.Printf("Starting server at port 8080\n")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
