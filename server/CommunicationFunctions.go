package server

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"macro/db"
	"macro/utils"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

func register(c *gin.Context) {
	var request utils.EmptyRequest
	var response utils.Acknowledgement
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	fmt.Println("Register Client ID", request.ID)
	s := getServer(request.ID)
	if s == nil {
		s = createServer(request.ID)
	}
	response.OK = true

	c.IndentedJSON(http.StatusOK, response)
}

func loadCSVFiles(c *gin.Context) {
	var request utils.CSVFileRequest
	var response utils.Acknowledgement
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusBadRequest, response)
		return
	}
	switch request.FileType {
	case "macro":
		output := db.ReadCSV([]byte(request.FileData))
		macros := db.GetMacrosOrDatasets(output)
		response.OK = db.StoreMacroAddresses(macros)
	case "dataset":
		output := db.ReadCSV([]byte(request.FileData))
		dataset := db.GetMacrosOrDatasets(output)
		response.OK = db.StoreDatasetAddresses(dataset)
	case "tc":
		decoded, err := base64.StdEncoding.DecodeString(request.FileData)
		if err != nil {
			response.OK = false
			response.Message = "Invalid file data"
			c.JSON(http.StatusBadRequest, response)
			return
		}
		telecommands, err := db.ReadTelecommandXLSX(decoded)
		if err != nil {
			response.OK = false
			response.Message = "Failed to read telecommand file: " + err.Error()
			c.JSON(http.StatusBadRequest, response)
			return
		}
		if !db.ClearTelecommand() {
			response.OK = false
			response.Message = "Failed to clear telecommand table"
			c.JSON(http.StatusBadRequest, response)
			return
		}
		for _, tc := range telecommands {
			if !db.StoreTelecommand(tc) {
				response.OK = false
				response.Message = "Failed to store telecommand"
				c.JSON(http.StatusBadRequest, response)
				return
			}
		}
		response.OK = true
	}
	if !response.OK {
		response.Message = "Unable to store address to database"
	}
	c.IndentedJSON(http.StatusOK, response)
}

func getMacroInfo(c *gin.Context) {
	var request utils.ValueRequest
	var response utils.MacroResponse
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusOK, response)
		return
	}
	var ok bool
	macDetails, _, ok := db.FetchMacroDetails(request.Param)
	if !ok {
		response.OK = false
		response.Message = "Cannot read database"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	response.Macro = macDetails
	response.OK = true
	c.IndentedJSON(http.StatusOK, response)
}

func saveMacroInfo(c *gin.Context) {
	var request utils.MacroRequest
	var response utils.Acknowledgement
	response.Message = ""
	response.OK = false
	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusOK, response)
		return
	}

	ok := db.StoreMacroDetails(request.Macro.MacroNo, request.Macro)
	if !ok {
		response.OK = false
		response.Message = "Failed to store in Database"
		c.JSON(http.StatusOK, response)
		return
	}
	response.OK = true
	response.Message = "Macro saved successfully"
	c.JSON(http.StatusOK, response)
}

func saveDSInfo(c *gin.Context) {
	var request utils.DatasetRequest
	var response utils.Acknowledgement
	response.Message = ""
	response.OK = false
	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusOK, response)
		return
	}
	ok := db.ClearDatasetDetails(int64(request.Dataset.DatasetNo))
	if !ok {
		response.OK = false
		response.Message = "Failed to clear DatasetDetails Table"
		c.JSON(http.StatusOK, response)
		return
	}
	ok = db.StoreDatasetDetails(request.Dataset.DatasetNo, request.Dataset, request.LinkedMacro, request.Description)
	if !ok {
		response.OK = false
		response.Message = "Failed to store in Database"
		c.JSON(http.StatusOK, response)
		return
	}
	response.OK = true
	response.Message = "Dataset saved successfully"
	c.JSON(http.StatusOK, response)
}

func getDatasetInfo(c *gin.Context) {
	var request utils.ValueRequest
	var response utils.DatasetResponse
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusOK, response)
		return
	}
	var ok bool
	fmt.Println("Request for DS No", request.Param)
	dsDetails, ok := db.FetchDatasetDetails(request.Param)
	if !ok {
		macroNo := s.clientMap["MacroNumber"]
		_, noOfCmds, _ := db.FetchMacroDetails(macroNo)
		var ds = utils.DatasetDetails{}
		ds.Data = make([]string, noOfCmds)
		ds.Executions = make([]bool, noOfCmds)
		ds.Times = make([]int, noOfCmds)
		ds.DatasetNo, _ = strconv.Atoi(request.Param)
		response.Dataset = ds
		fmt.Printf("%+v\n", response.Dataset)
		response.OK = true
		response.Message = ""
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	response.Dataset = dsDetails
	description, ok := db.GetDescription(request.Param)
	if !ok {
		response.OK = false
	}
	response.OK = true
	response.Message = description
	c.IndentedJSON(http.StatusOK, response)
}

func saveValue(c *gin.Context) {
	var request utils.ParameterRequest
	var response utils.Acknowledgement
	response.OK = false
	response.Message = ""
	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}
	var paramName = request.ParameterName
	var paramValue = request.ParameterValue

	s := getServer(request.ID)
	fmt.Println(s)
	if s == nil {
		response.OK = false
		response.Message = "Unknown ClientID"
		c.IndentedJSON(http.StatusOK, response)
		return
	}

	if paramName == "" {
		response.OK = false
		response.Message = "No Parameters to Set"
	} else if paramValue == "" {
		fmt.Println(paramName)
		response.OK = false
		response.Message = "Parameter Value cannot be empty"
	} else {
		s.clientMap[paramName] = paramValue
		response.OK = true
		response.Message = ""
	}
	fmt.Println(paramName, paramValue)
	c.IndentedJSON(http.StatusOK, response)
}

func saveValues(c *gin.Context) {
	var request utils.MultiValueRequest
	var response utils.Acknowledgement
	response.OK = false
	response.Message = ""
	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, response)
		return
	}
	var paramName = request.ParameterName
	var paramValues = request.ParameterValues

	fmt.Printf("%+v\n", request)

	s := getServer(request.ID)
	fmt.Println(s)
	if s == nil {
		response.OK = false
		response.Message = "Unknown ClientID"
		c.IndentedJSON(http.StatusOK, response)
		return
	}

	if len(paramName) == 0 {
		response.OK = false
		response.Message = "No Parameters to Set"
	} else if paramValues == nil {
		response.OK = false
		response.Message = "Parameter Values cannot be empty"
	} else if strings.EqualFold(request.ParameterName, "macrocommands") {
		s.clientMap[request.ParameterName] = strings.Join(request.ParameterValues, ";;;")
		response.OK = true
		response.Message = ""
		db.StoreMacroRelatedTCs(s.clientMap[request.ParameterName])
	} else if strings.EqualFold(request.ParameterName, "exportedmacros") {
		s.clientMap[request.ParameterName] = strings.Join(request.ParameterValues, ";;;")
		response.OK = true
		response.Message = ""
		fmt.Println(s.clientMap)
		desc := strings.Split(s.clientMap[request.ParameterName], ";;;")
		procedure, ok := db.GenerateProcedure(desc)
		if !ok {
			response.OK = false
			response.Message = "Unable to generate Macros"
		}
		response.Message = procedure
		c.IndentedJSON(http.StatusOK, response)
	}
}

func getTCdatabase(c *gin.Context) {
	var request utils.EmptyRequest
	var ack utils.Acknowledgement
	if err := c.BindJSON(&request); err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, ack)
		return
	}
	s := getServer(request.ID)
	fmt.Println("IN get tc database", request.ID, s)
	ip := s.clientMap["SCCMainIP"]
	scName := s.clientMap["SCName"]
	urlString := db.GetTCDatabaseURL(ip, scName)
	response, err := http.Get(urlString)
	if err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, ack)
		return
	}
	data, err := io.ReadAll(response.Body)
	if err != nil {
		ack.OK = false
		ack.Message = "Bad Request"
		c.IndentedJSON(http.StatusBadRequest, ack)
		return
	}
	clearTC := db.ClearTelecommand()
	if !clearTC {
		ack.OK = false
		ack.Message = "Cannot clear existing Telecommand Database"
		c.IndentedJSON(http.StatusBadRequest, ack)
		return
	}
	var cmdStruct []utils.TCDatabase
	err = json.Unmarshal(data, &cmdStruct)
	if err != nil {
		return
	}
	var ok bool
	for _, cmd := range cmdStruct {

		ok = db.StoreTelecommand(cmd)
		if !ok {
			break
		}
	}
	ack.OK = ok
	ack.Message = "Telecommands Updated in Database"
	c.IndentedJSON(http.StatusOK, ack)

}

func getMultipleValues(c *gin.Context) {
	var request utils.ValueRequest
	var response utils.MultiValueResponse
	response.Values = make([]string, 0)
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Server Request Error"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	var param = strings.ToLower(request.Param)
	switch param {
	case "tcmnemonics":
		mnemonics, ok := db.GetAllTCMnemonics()
		if ok {
			response.Values = mnemonics
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from Telecommands Table"
		}
	case "macrotypes":
		macroTypes, ok := db.GetMacroTypes()
		if ok {
			response.Values = macroTypes
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from Macro Address Table"
		}
	case "macronumbers":
		mactype := s.clientMap["SelectedMacroType"]
		mactypeInt, _ := strconv.ParseInt(mactype, 10, 64)
		macroNumbers, ok := db.GetMacroNumbersBasedOnTypes(mactypeInt)
		if ok {
			response.Values = macroNumbers
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from Macro Address Table"
		}
	case "mappedtc":
		mappedTCs, ok := db.GetAllMappedMacroTCs()
		if ok {
			response.Values = mappedTCs
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from MacroRelatedTC Table"
		}
	case "totalmacros":
		allMacros, ok := db.GetAllMacros()
		if ok {
			response.Values = allMacros
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from MacroAddresses Table"
		}
	case "totaldatasets":
		allDS, ok := db.GetAllDatasets()
		if ok {
			response.Values = allDS
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from DatasetAddresses Table"
		}
	case "savedmacronumbers":
		savedMacroNumbers, ok := db.GetSavedMacroNumbers()
		if ok {
			response.Values = savedMacroNumbers
			response.OK = true
			response.Message = ""
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from Macro Details Table"
		}
	case "filtereddsnumbers":
		macNumber := s.clientMap["MacroNumber"]
		macNoInt, err := strconv.ParseInt(macNumber, 10, 64)
		if err != nil {
			fmt.Println(err)
			response.OK = false
			response.Message = "Invalid macro number"
			c.IndentedJSON(http.StatusBadRequest, response)
			return
		}
		filteredDatasetNumbers, ok := db.GetAllDatasetsBasedOnMacroNumber(macNoInt)
		if ok {
			response.Values = filteredDatasetNumbers
			response.OK = true
			response.Message = "Corresponding Datasets are fetched"
		} else {
			response.Values = []string{}
			response.OK = false
			response.Message = "Cannot read from Dataset Address Table"
		}

	default:
		response.OK = false
		response.Message = "Unknown Parameter"
	}
	c.IndentedJSON(http.StatusOK, response)
}

func getValue(c *gin.Context) {
	var request utils.ValueRequest
	var response utils.ValueResponse
	response.Value = ""
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Server Request Error"
		c.IndentedJSON(http.StatusOK, response)
		return
	}
	var param = strings.ToLower(request.Param)
	switch param {
	case "cmdtype":
		cmdMnemonic := s.clientMap["SelectedMnemonic"]
		response.Value, response.OK = db.GetCommandType(cmdMnemonic)
		if !response.OK {
			response.Message = "Cannot get type of Telecommand"
		}

	default:
		response.Value = ""
		response.OK = false
		response.Message = "Unknown Parameter"
	}
	c.IndentedJSON(http.StatusOK, response)
}

func getCompletedMacros(c *gin.Context) {
	var request utils.EmptyRequest
	var resp utils.CompletedMacros

	if err := c.BindJSON(&request); err != nil {
		resp.OK = false
		resp.Message = "Bad Request"
		c.IndentedJSON(http.StatusOK, resp)
		return
	}
	s := getServer(request.ID)
	if s == nil {
		resp.OK = false
		resp.Message = "Client not connected"
		return

	}
	macros, _ := db.GetCompletedMacro()
	macroDetails, ok := db.GetCompletedMacros(macros)
	if ok {
		resp.Macros = macroDetails.Macros
		resp.Message = macroDetails.Message
		resp.OK = macroDetails.OK
		fmt.Println("response", resp)
		resp.OK = true
		resp.Message = ""
	} else {
		resp.OK = false
		resp.Message = "Cannot read all macro details"
	}
	c.IndentedJSON(http.StatusOK, resp)
}

func getInspectionData(c *gin.Context) {
	var request utils.EmptyRequest
	var response utils.InspectionResponse
	response.OK = false
	response.Message = ""

	if err := c.BindJSON(&request); err != nil {
		response.OK = false
		response.Message = "Bad Request"
		c.JSON(http.StatusOK, response)
		return
	}

	s := getServer(request.ID)
	if s == nil {
		response.OK = false
		response.Message = "Failed to get Client ID"
		c.JSON(http.StatusOK, response)
		return
	}

	items, ok := db.FetchAllInspectionData()
	if !ok {
		response.OK = false
		response.Message = "Failed to fetch inspection data"
		c.JSON(http.StatusOK, response)
		return
	}

	response.Items = items
	response.OK = true
	c.JSON(http.StatusOK, response)
}
