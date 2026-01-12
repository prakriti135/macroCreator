package db

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	database "macro/dbGenerated"
	"macro/utils"
	"strconv"
	"strings"

	"github.com/xuri/excelize/v2"
)

func ReadTelecommandXLSX(data []byte) ([]utils.TCDatabase, error) {
	var telecommands []utils.TCDatabase
	f, err := excelize.OpenReader(bytes.NewReader(data))
	if err != nil {
		return nil, err
	}

	targetSheet := "Base_Cmd_Info"
	sheetName := ""
	for _, name := range f.GetSheetList() {
		if strings.EqualFold(name, targetSheet) {
			sheetName = name
			break
		}
	}

	if sheetName == "" {
		return nil, fmt.Errorf("sheet %s not found in the uploaded file", targetSheet)
	}

	rows, err := f.GetRows(sheetName)
	if err != nil {
		return nil, err
	}

	if len(rows) == 0 {
		return telecommands, nil
	}

	header := rows[0]
	colIndices := make(map[string]int)
	for i, colName := range header {
		switch {
		case strings.EqualFold(colName, "CDB_Cmd_CID") || strings.EqualFold(colName, "cdb_cid"):
			colIndices["CDB_Cmd_CID"] = i
		case strings.EqualFold(colName, "CDB_Cmd_Mnemonic") || strings.EqualFold(colName, "cdb_cmd_mnemonic"):
			colIndices["CDB_Cmd_Mnemonic"] = i
		case strings.EqualFold(colName, "Cmd_Code") || strings.EqualFold(colName, "cmd_code"):
			colIndices["Cmd_Code"] = i
		case strings.EqualFold(colName, "Cmd_Type") || strings.EqualFold(colName, "cmd_type"):
			colIndices["Cmd_Type"] = i
		}
	}

	if _, ok := colIndices["CDB_Cmd_CID"]; !ok {
		return nil, fmt.Errorf("required column 'CDB_Cmd_CID' or 'cdb_cid' not found in sheet '%s'", sheetName)
	}

	for _, row := range rows[1:] {
		var tc utils.TCDatabase
		if cid, ok := colIndices["CDB_Cmd_CID"]; ok {
			if len(row) > cid {
				tc.CommandID = row[cid]
			}
		}
		if mnemonic, ok := colIndices["CDB_Cmd_Mnemonic"]; ok {
			if len(row) > mnemonic {
				tc.CommandName = row[mnemonic]
			}
		}
		if code, ok := colIndices["Cmd_Code"]; ok {
			if len(row) > code {
				tc.CommandCode = row[code]
			}
		}
		if cmdType, ok := colIndices["Cmd_Type"]; ok {
			if len(row) > cmdType {
				tc.CommandType = row[cmdType]
			}
		}
		telecommands = append(telecommands, tc)
	}

	return telecommands, nil
}

func ReadCSV(data []byte) []utils.MacroOrDSEntry {

	//func ReadCSV() []utils.MacroOrDSEntry {
	//	filepath := "/Users/ankur/Downloads/macros.csv"
	//	data, _ := os.ReadFile(filepath)
	fileData := string(data)
	lines := strings.Split(fileData, "\n")
	var entries []utils.MacroOrDSEntry
	var entry utils.MacroOrDSEntry
	for i, line := range lines {
		line = strings.ReplaceAll(line, "\r", "")
		if i == 0 {
			continue
		}
		if strings.TrimSpace(line) == "" {
			continue
		}
		fields := strings.Split(line, ",")
		if len(fields) < 5 {
			continue
		}
		startMacroOrDSNo, _ := strconv.Atoi(fields[0])
		endMacroOrDSNo, _ := strconv.Atoi(fields[1])
		numCommands, _ := strconv.Atoi(fields[2])
		startAddress, _ := strconv.Atoi(fields[3])
		numBytes, _ := strconv.Atoi(fields[4])

		entry.StartMacroOrDSNo = startMacroOrDSNo
		entry.EndMacroOrDSNo = endMacroOrDSNo
		entry.NumCommands = numCommands
		entry.StartAddress = startAddress
		entry.NumBytes = numBytes

		entries = append(entries, entry)

	}
	return entries
}

func GetMacrosOrDatasets(entries []utils.MacroOrDSEntry) []utils.MacroOrDSAddresses {
	var val utils.MacroOrDSAddresses
	var result []utils.MacroOrDSAddresses
	macroNo := 0
	for _, entry := range entries {
		fmt.Println(len(entries))
		fmt.Println(entry)
		NoOfMacrosOfType := (entry.EndMacroOrDSNo - entry.StartMacroOrDSNo) + 1

		for i := 0; i < NoOfMacrosOfType; i++ {
			Address := entry.StartAddress + (i * entry.NumBytes)
			val.MacroDSNo = macroNo + i
			val.MacroDSType = entry.NumCommands
			val.Address = Address
			result = append(result, val)

		}
		macroNo = macroNo + NoOfMacrosOfType
	}
	return result
}

func StoreMacroAddresses(macros []utils.MacroOrDSAddresses) bool {
	ctx := context.Background()
	err := dbObject.ClearMacroAddress(ctx)
	if err != nil {
		fmt.Println("Cannot clear the MacroAddress table", err.Error())
		return false
	}

	var store database.StoreMacroAddressesParams
	for i := 0; i < len(macros); i++ {
		store.MacroNo = int64(macros[i].MacroDSNo)
		store.NoOfCommands = int64(macros[i].MacroDSType)
		store.Address = int64(macros[i].Address)

		ctx := context.Background()
		err := dbObject.StoreMacroAddresses(ctx, store)

		if err != nil {
			fmt.Println("Cannot Insert into the MacroAddress table", err.Error())
			return false
		}
	}
	return true
}

func StoreDatasetAddresses(datasets []utils.MacroOrDSAddresses) bool {
	ctx := context.Background()
	err := dbObject.ClearDatasetAddress(ctx)
	if err != nil {
		fmt.Println("Cannot clear the MacroAddress table", err.Error())
		return false
	}

	var store database.StoreDatasetAddressesParams
	for i := 0; i < len(datasets); i++ {
		store.DatasetNo = int64(datasets[i].MacroDSNo)
		store.NoOfCommands = int64(datasets[i].MacroDSType)
		store.Address = int64(datasets[i].Address)

		ctx := context.Background()
		err := dbObject.StoreDatasetAddresses(ctx, store)

		if err != nil {
			return false
		}
	}
	return true
}

func ClearMacroDetails(macNo int64) bool {
	ctx := context.Background()
	err := dbObject.ClearMacroDetails(ctx, macNo)
	if err != nil {
		fmt.Println("Cannot clear the MacroDetails table", err.Error())
		return false
	}
	return true
}

func StoreMacroDetails(macNo int, macroDetails utils.MacroDetails) bool {
	ctx := context.Background()
	var store database.StoreMacroDetailsParams
	store.MacroNo = int64(macNo)

	err := dbObject.ClearMacroDetails(ctx, store.MacroNo)
	if err != nil {
		return false
	}

	data, err := json.MarshalIndent(macroDetails, "", " ")
	if err != nil {
		return false
	}
	macroDetailsStr := string(data)
	store.Details = macroDetailsStr
	//store.Details.Valid = true

	err = dbObject.StoreMacroDetails(ctx, store)
	if err != nil {
		fmt.Println(err)
		return false
	}
	return true
}

func FetchMacroDetails(macroNo string) (utils.MacroDetails, int, bool) {
	ctx := context.Background()

	macroNoInt, _ := strconv.ParseInt(macroNo, 10, 64)
	details, err := dbObject.GetMacroDetails(ctx, macroNoInt)
	if err != nil {
		return utils.MacroDetails{}, 0, false
	}

	var macroDetails utils.MacroDetails
	err = json.Unmarshal([]byte(details.Details), &macroDetails)
	if err != nil {
		return utils.MacroDetails{}, macroDetails.NoOfCommands, true
	}
	return macroDetails, macroDetails.NoOfCommands, true
}

func ClearDatasetDetails(dsNo int64) bool {
	ctx := context.Background()
	err := dbObject.ClearDatasetDetails(ctx, dsNo)
	if err != nil {
		fmt.Println("Cannot clear the DatasetDetails table", err.Error())
		return false
	}
	return true
}
func StoreDatasetDetails(DSNo int, dsDetails utils.DatasetDetails, linkedMacro int, description string) bool {
	var store database.StoreDatasetDetailsParams
	store.DatasetNo = int64(DSNo)
	data, err := json.MarshalIndent(dsDetails, "", " ")
	if err != nil {
		return false
	}
	dsDetailsStr := string(data)
	store.Details = dsDetailsStr
	store.LinkedMacro = int64(linkedMacro)
	store.Description = description
	fmt.Println("Dataset details are:", store.Details, store.LinkedMacro, store.Description)

	ctx := context.Background()
	err = dbObject.StoreDatasetDetails(ctx, store)
	if err != nil {
		return false
	} else {
		return true
	}
}

func FetchDatasetDetails(datasetNo string) (utils.DatasetDetails, bool) {
	ctx := context.Background()

	dsNoInt, _ := strconv.ParseInt(datasetNo, 10, 64)
	details, err := dbObject.GetDatasetDetails(ctx, dsNoInt)
	if err != nil {
		return utils.DatasetDetails{}, false
	}

	var dsDetails utils.DatasetDetails
	err = json.Unmarshal([]byte(details.Details), &dsDetails)
	if err != nil {
		return utils.DatasetDetails{}, false
	}
	return dsDetails, true
}

func GetTCDatabaseURL(sccMainIP string, SatName string) string {
	url := "http://" + sccMainIP + ":8888/PEPSUMMARY/GetTC.jsp?ScName=" + SatName
	return url
}

func StoreTelecommand(cmdDetails utils.TCDatabase) bool {

	var store database.StoreTelecommandsParams
	store.CommandID = cmdDetails.CommandID
	store.Code = cmdDetails.CommandCode
	store.Mnemonics = cmdDetails.CommandName
	store.Type = cmdDetails.CommandType
	ctx := context.Background()

	err := dbObject.StoreTelecommands(ctx, store)
	if err != nil {
		fmt.Println("Cannot Insert into the Telecommands table", err.Error())
		return false
	}
	return true
}

func ClearTelecommand() bool {
	ctx := context.Background()
	err := dbObject.ClearTelecommands(ctx)
	if err != nil {
		fmt.Println("Cannot clear the Telecommands table", err.Error())
		return false
	}
	return true
}

func StoreMacroRelatedTCs(cmds string) bool {
	cmd := strings.Split(cmds, ";;;")
	var store database.StoreMacroRelatedTCsParams
	store.MacroUpdate = cmd[0]
	store.DatasetUpdate = cmd[3]
	store.MacroEnable = cmd[1]
	store.MacroInit = cmd[2]
	store.MasterMacroEnable = cmd[4]
	ctx := context.Background()
	err := dbObject.StoreMacroRelatedTCs(ctx, store)
	if err != nil {
		fmt.Println("Cannot store macro related TCs")
		return false
	}
	return true
}

func FetchAllInspectionData() ([]utils.InspectionItem, bool) {
	ctx := context.Background()

	// Step 1: Get all completed datasets
	completedMacros, err := dbObject.GetCompletedMacroDetails(ctx)
	if err != nil {
		fmt.Println("Cannot fetch completed macro details:", err.Error())
		return nil, false
	}

	var inspectionItems []utils.InspectionItem

	// Step 2: For each dataset, fetch and merge details
	for _, row := range completedMacros {
		macroNo := row.LinkedMacro
		datasetNo := row.DatasetNo
		description := row.Description

		// Step 3: Fetch Macro Details
		macroDetails, err := dbObject.GetMacroDetails(ctx, macroNo)
		if err != nil {
			fmt.Printf("Skipping Macro %d: %v\n", macroNo, err)
			continue
		}

		// Step 4: Fetch Dataset Details
		datasetDetails, err := dbObject.GetDatasetDetails(ctx, datasetNo)
		if err != nil {
			fmt.Printf("Skipping Dataset %d: %v\n", datasetNo, err)
			continue
		}

		// Step 5: Unmarshal JSON
		var macro utils.MacroDetails
		err = json.Unmarshal([]byte(macroDetails.Details), &macro)
		if err != nil {
			fmt.Printf("Failed to unmarshal Macro %d: %v\n", macroNo, err)
			continue
		}

		var dataset utils.DatasetDetails
		err = json.Unmarshal([]byte(datasetDetails.Details), &dataset)
		if err != nil {
			fmt.Printf("Failed to unmarshal Dataset %d: %v\n", datasetNo, err)
			continue
		}

		// Step 6: Merge Macro Commands with Dataset Data/Times
		var commands []utils.InspectedCommand
		for i := 0; i < macro.NoOfCommands; i++ {
			data := ""
			time := 0
			executed := false

			// Safely access dataset arrays
			if i < len(dataset.Data) {
				data = dataset.Data[i]
			}
			if i < len(dataset.Times) {
				time = dataset.Times[i]
			}
			if i < len(dataset.Executions) {
				executed = dataset.Executions[i]
			}

			cmd := utils.InspectedCommand{
				Index:           i,
				CommandMnemonic: macro.Commands[i].CommandMnemonic,
				CommandCode:     macro.Commands[i].CommandCode,
				Data:            data,
				Time:            time,
				Executed:        executed,
			}
			commands = append(commands, cmd)
		}

		// Step 7: Build Inspection Item
		item := utils.InspectionItem{
			MacroNo:     int(macroNo),
			DatasetNo:   int(datasetNo),
			Description: description,
			Commands:    commands,
		}

		inspectionItems = append(inspectionItems, item)
	}

	return inspectionItems, true
}
