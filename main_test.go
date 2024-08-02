package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

const mockRPCResponse = `{
	"jsonrpc": "2.0",
	"id": 2,
	"result": "0x10d4f"
}`

func TestGetBlockNumber(t *testing.T) {
	req, err := http.NewRequest("GET", "/getBlockNumber", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(getBlockNumber)

	// Mock the callRPC function
	callRPC = func(reqBody RPCRequest) ([]byte, error) {
		return []byte(mockRPCResponse), nil
	}

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Normalize the actual response
	var actual map[string]interface{}
	if err := json.Unmarshal(rr.Body.Bytes(), &actual); err != nil {
		t.Fatalf("could not unmarshal actual response: %v", err)
	}

	// Normalize the expected response
	var expected map[string]interface{}
	expectedStr := `{"jsonrpc":"2.0","id":2,"result":"0x10d4f"}`
	if err := json.Unmarshal([]byte(expectedStr), &expected); err != nil {
		t.Fatalf("could not unmarshal expected response: %v", err)
	}

	if !jsonEqual(actual, expected) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedStr)
	}
}

func TestGetBlockByNumber(t *testing.T) {
	req, err := http.NewRequest("GET", "/getBlockByNumber?blockNumber=0x10d4f", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(getBlockByNumber)

	// Mock the callRPC function
	callRPC = func(reqBody RPCRequest) ([]byte, error) {
		return []byte(mockRPCResponse), nil
	}

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Normalize the actual response
	var actual map[string]interface{}
	if err := json.Unmarshal(rr.Body.Bytes(), &actual); err != nil {
		t.Fatalf("could not unmarshal actual response: %v", err)
	}

	// Normalize the expected response
	var expected map[string]interface{}
	expectedStr := `{"jsonrpc":"2.0","id":2,"result":"0x10d4f"}`
	if err := json.Unmarshal([]byte(expectedStr), &expected); err != nil {
		t.Fatalf("could not unmarshal expected response: %v", err)
	}

	if !jsonEqual(actual, expected) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedStr)
	}
}

func TestHealthCheck(t *testing.T) {
	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(healthCheck)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := "OK"
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}

// jsonEqual checks if two JSON objects are equal
func jsonEqual(a, b map[string]interface{}) bool {
	return jsonString(a) == jsonString(b)
}

// jsonString converts a JSON object to a string
func jsonString(v map[string]interface{}) string {
	bytes, _ := json.Marshal(v)
	return string(bytes)
}