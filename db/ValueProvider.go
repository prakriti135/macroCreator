package db

import (
	"context"
	"fmt"
	"macro/utils"
	"strconv"
)

func GetAllTCMnemonics() ([]string, bool) {
	ctx := context.Background()
	mnemonics, err := dbObject.GetAllTCMnemonics(ctx)
	return mnemonics, err == nil
}

func GetCommandType(mnemonic string) (string, bool) {
	ctx := context.Background()
	cmdType, err := dbObject.GetCommandType(ctx, mnemonic)
	return cmdType, err == nil
}

func GetMacroTypes() ([]string, bool) {
	ctx := context.Background()
	cmdType, err := dbObject.GetMacroTypes(ctx)
	typesStr := make([]string, 0)
	for i := 0; i < len(cmdType); i++ {
		typeStr := strconv.FormatInt(cmdType[i], 10)
		typesStr = append(typesStr, typeStr)
	}
	return typesStr, err == nil

}

func GetMacroNumbersBasedOnTypes(macType int64) ([]string, bool) {
	ctx := context.Background()
	cmdType, err := dbObject.GetMacroNoBasedOnType(ctx, macType)
	typesStr := make([]string, 0)
	for i := 0; i < len(cmdType); i++ {
		typeStr := strconv.FormatInt(cmdType[i], 10)
		typesStr = append(typesStr, typeStr)
	}
	return typesStr, err == nil

}

func GetSavedMacroNumbers() ([]string, bool) {
	ctx := context.Background()
	savedMacNos, err := dbObject.GetSavedMacroNos(ctx)
	savedMacNosStr := make([]string, 0)
	for i := 0; i < len(savedMacNos); i++ {
		savedMacNoStr := strconv.FormatInt(savedMacNos[i], 10)
		savedMacNosStr = append(savedMacNosStr, savedMacNoStr)
	}
	return savedMacNosStr, err == nil

}

func GetAllMappedMacroTCs() ([]string, bool) {
	ctx := context.Background()
	allTC, err := dbObject.GetMappedMacroCommands(ctx)
	if err != nil {
		return nil, false
	} else {
		var mappedTC []string
		for _, tc := range allTC {
			mappedTC = append(mappedTC, tc.MacroUpdate, tc.DatasetUpdate,
				tc.MacroEnable, tc.MacroInit, tc.MasterMacroEnable)
		}
		return mappedTC, true

	}
}

func GetAllMacros() ([]string, bool) {
	ctx := context.Background()
	allMacros, err := dbObject.GetAllMacros(ctx)
	if err != nil {
		return nil, false
	}
	var allMacrosStr []string
	for _, macro := range allMacros {
		allMacrosStr = append(allMacrosStr, fmt.Sprintf("%d", macro))
	}
	return allMacrosStr, true

}

func GetAllDatasets() ([]string, bool) {
	ctx := context.Background()
	allDS, err := dbObject.GetAllDatasets(ctx)
	if err != nil {
		return nil, false
	}
	var allDSStr []string
	for _, ds := range allDS {
		allDSStr = append(allDSStr, fmt.Sprintf("%d", ds))
	}
	return allDSStr, true

}

func GetMacroTypeBasedOnNumber(macNo int64) (int64, bool) {
	ctx := context.Background()
	macType, err := dbObject.GetMacroTypeBasedOnNumber(ctx, macNo)
	return macType, err == nil
}

func GetAllDatasetsBasedOnMacroNumber(macNo int64) ([]string, bool) {
	ctx := context.Background()
	allDSBasedOnMacroType, err := dbObject.GetDatasetNosBasedOnMacroType(ctx, macNo)
	if err != nil {
		return nil, false
	}
	var allFilteredDSStr []string
	for _, ds := range allDSBasedOnMacroType {
		allFilteredDSStr = append(allFilteredDSStr, fmt.Sprintf("%d", ds))
	}
	return allFilteredDSStr, true

}

func GetCompletedMacro() ([]utils.CompletedMacro, bool) {
	ctx := context.Background()
	var val utils.CompletedMacro
	var values []utils.CompletedMacro
	completedMacro, err := dbObject.GetCompletedMacroDetails(ctx)
	if err != nil {
		return values, false
	}
	for i := 0; i < len(completedMacro); i++ {
		val.MacroNo = int(completedMacro[i].LinkedMacro)
		val.DatasetNo = int(completedMacro[i].DatasetNo)
		val.Description = completedMacro[i].Description
		values = append(values, val)
	}
	return values, true
}

func GetCompletedMacros(macros []utils.CompletedMacro) (utils.CompletedMacros, bool) {
	macros, _ = GetCompletedMacro()
	var val utils.CompletedMacros
	val.Macros = macros
	val.Message = "All completed macros fetched from database"
	val.OK = true
	fmt.Println(val)
	return val, true
}

func GetMacNosDSNos(desc string) (int, int, bool) {
	ctx := context.Background()
	item, err := dbObject.GetMacNoDSNoBasedOnDescription(ctx, desc)
	if err != nil {
		return 0, 0, false
	}
	macNo := int(item.LinkedMacro)
	dsNo := int(item.DatasetNo)
	return macNo, dsNo, true
}

func GetMacroAddress(macNo int) (int, bool) {
	ctx := context.Background()
	address, err := dbObject.GetMacroAddress(ctx, int64(macNo))
	if err != nil {
		return 0, false
	} else {
		return int(address), true
	}
}

func GetDatasetAddress(dsNo int) (int, bool) {
	ctx := context.Background()
	address, err := dbObject.GetDatasetAddress(ctx, int64(dsNo))
	if err != nil {
		return 0, false
	} else {
		return int(address), true
	}
}

func GetCommandCode(mnemonic string) (string, bool) {
	ctx := context.Background()
	cmdCode, err := dbObject.GetCommandCode(ctx, mnemonic)
	if err != nil {
		return "", false
	} else {
		return cmdCode, true
	}
}

func GetDescription(dsNo string)(string , bool){
	ctx := context.Background()
	datasetNo, _ := strconv.ParseInt(dsNo, 10,64)
	desc, err := dbObject.GetDescriptionForDataset(ctx, datasetNo)
	if err != nil {
		return "", false
	} else {
		return desc, true
	}

}
