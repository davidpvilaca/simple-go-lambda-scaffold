package report

import (
	"encoding/json"
	"io"
	"net/http"
)

type Report struct {
	Results []struct {
		Name struct {
			First string `json:"first"`
			Last  string `json:"last"`
		} `json:"name"`
		Gender string `json:"gender"`
		Email  string `json:"email"`
		Phone  string `json:"phone"`
	} `json:"results"`
	Info struct {
		Seed    string `json:"seed"`
		Results int    `json:"results"`
		Page    int    `json:"page"`
		Version string `json:"version"`
	} `json:"info"`
}

func GetReport() (Report, error) {
	res, err := http.Get("https://randomuser.me/api?results=50")
	if err != nil {
		return Report{}, err
	}
	defer res.Body.Close()

	data, err := io.ReadAll(res.Body)
	if err != nil {
		return Report{}, err
	}

	var jsonData Report

	err = json.Unmarshal(data, &jsonData)
	if err != nil {
		return Report{}, err
	}

	return jsonData, nil
}
