package server

import (
	"fmt"
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func Listen(logDir string) {
	/*
		currentTime := time.Now()
		t := currentTime.Format("02-Jan-2006-15-04-05")
		logPath := logDir + "/macroPath" + t + ".log"

			logFile, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0660)
			if err != nil {
				fmt.Println("Unable to open log file", logPath)
			}

			gin.DefaultWriter = io.MultiWriter(logFile, os.Stdout)*/

	r := gin.Default()
	r.Use(cors.Default())

	// Serve the static files from the "server/web" directory
	r.Static("/", "./server/web")

	r.POST("/saveCSVFiles", loadCSVFiles)
	r.POST("/register", register)
	r.POST("/getMacroDetails", getMacroInfo)
	r.POST("/saveMacroDetails", saveMacroInfo)
	r.POST("/saveParameterValue", saveValue)
	r.POST("/saveParameterValues", saveValues)
	r.POST("/getTCDatabase", getTCdatabase)
	r.POST("/getValue", getValue)
	r.POST("/getMultipleValues", getMultipleValues)
	r.POST("/saveMacros", saveMacroInfo)
	r.POST("/getMacros", getMacroInfo)
	r.POST("/saveDatasetDetails", saveDSInfo)
	r.POST("/getDatasets", getDatasetInfo)
	r.POST("/getCompletedMacros", getCompletedMacros)
	r.POST("/getInspectionData", getInspectionData)

	err := r.Run(":8609")
	if err != nil {
		fmt.Println("Cannot listen on 8609")
		return
	}
	log.Println()

}
