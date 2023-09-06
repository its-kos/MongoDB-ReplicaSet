package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	healthy     = true
	mongoClient *mongo.Client
)

func isMongoDBHealthy() bool {
	if mongoClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		err := mongoClient.Ping(ctx, nil)
		if err == nil {
			return true
		}
	}
	return false
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if healthy && isMongoDBHealthy() {
		fmt.Fprintln(w, "Cluster is up and healthy!")
		w.WriteHeader(http.StatusOK)
	} else {
		fmt.Fprintln(w, "Cluster is unhealthy!")
		w.WriteHeader(http.StatusServiceUnavailable) // 503 Service Unavailable Error
	}
}

func main() {
	// Initialize the MongoDB client.
	mongoURI := "mongodb://mongodb-1:27017,mongodb-2:27017,mongodb-3:27017/?replicaSet=aws_replicaset" // Replicaset id comes from Ansible config
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
	if err != nil {
		fmt.Println("Failed to connect to MongoDB:", err)
		healthy = false
	} else {
		mongoClient = client
	}

	// Create /health endpoint.
	http.HandleFunc("/health", healthHandler)
	// Create /metrics endpoint
	http.Handle("/metrics", promhttp.Handler())

	// Start the HTTP server.
	fmt.Println("App is listening on :8080")
	http.ListenAndServe(":8080", nil)
}
