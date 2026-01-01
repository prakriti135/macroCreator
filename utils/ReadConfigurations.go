package utils

import (
	"encoding/json"
	"fmt"
	"os"
)

type configuration struct {
	BaseFolder string
	Database   string
}

var Config configuration

func ReadConfiguration(filename string) {
	configFile, err := os.Open(filename)
	if err != nil {
		fmt.Println("File ", filename, " doesn't exist")
		os.Exit(1)
	}
	defer configFile.Close()

	jsonParser := json.NewDecoder(configFile)
	jsonParser.Decode(&Config)
}
