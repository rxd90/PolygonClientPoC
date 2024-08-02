package main

import (
	"encoding/json"
	"log"
	"net/http"
	"bytes"
	"io/ioutil"
)

const rpcURL = "https://polygon-rpc.com/"

type RPCRequest struct {
	Jsonrpc string        `json:"jsonrpc"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params,omitempty"`
	ID      int           `json:"id"`
}

type RPCResponse struct {
	Jsonrpc string          `json:"jsonrpc"`
	ID      int             `json:"id"`
	Result  json.RawMessage `json:"result"`
	Error   *RPCError       `json:"error,omitempty"`
}

type RPCError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

var callRPC = func(reqBody RPCRequest) ([]byte, error) {
	reqBytes, err := json.Marshal(reqBody)
	if err != nil {
		log.Println("Error marshaling request body:", err)
		return nil, err
	}

	resp, err := http.Post(rpcURL, "application/json", bytes.NewBuffer(reqBytes))
	if err != nil {
		log.Println("Error making HTTP request:", err)
		return nil, err
	}
	defer resp.Body.Close()

	respBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error reading response body:", err)
		return nil, err
	}

	return respBytes, nil
}

func getBlockNumber(w http.ResponseWriter, r *http.Request) {
	log.Println("getBlockNumber called")
	reqBody := RPCRequest{
		Jsonrpc: "2.0",
		Method:  "eth_blockNumber",
		ID:      2,
	}

	respBody, err := callRPC(reqBody)
	if err != nil {
		log.Println("Error in getBlockNumber:", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(respBody)
}

func getBlockByNumber(w http.ResponseWriter, r *http.Request) {
	blockNumber := r.URL.Query().Get("blockNumber")
	if blockNumber == "" {
		log.Println("blockNumber query parameter is required")
		http.Error(w, "blockNumber query parameter is required", http.StatusBadRequest)
		return
	}

	reqBody := RPCRequest{
		Jsonrpc: "2.0",
		Method:  "eth_getBlockByNumber",
		Params:  []interface{}{blockNumber, true},
		ID:      2,
	}

	respBody, err := callRPC(reqBody)
	if err != nil {
		log.Println("Error in getBlockByNumber:", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(respBody)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	log.Println("Health check endpoint called")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func main() {
	log.Println("Starting server on port 8080...")
	http.HandleFunc("/getBlockNumber", getBlockNumber)
	http.HandleFunc("/getBlockByNumber", getBlockByNumber)
	http.HandleFunc("/health", healthCheck)
	log.Fatal(http.ListenAndServe(":8080", nil))
}