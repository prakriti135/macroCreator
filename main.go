package main

import (
	"fmt"
	"macro/db"
	"macro/server"
	"macro/utils"
)

func main() {
	fmt.Println("Macro Creator Server started")
	utils.ReadConfiguration("config.json")
	ok := db.Connect()
	if !ok {
		fmt.Println("Database not created")
		return
	}
	desc := make([]string, 0)
	desc = append(desc, "Dataset50", "Dataset-21")
	//desc = append(desc, "Dataset65")

	db.GenerateProcedure(desc)
	server.Listen("/home/csrspdev/macros/Log/")

}
