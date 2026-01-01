package db

import (
	"fmt"
	"macro/utils"
	"slices"
	"strconv"
	"strings"
)

var stepNo = 10

var increment = 10

var procedureNo = "8000"

func getStepNo() (step string) {
	step = procedureNo + "." + fmt.Sprintf("%d  ", stepNo)
	stepNo = stepNo + increment
	return step
}

func GenerateProcedure(descriptions []string) (string, bool) {
	allMacNos := make([]int, 0)
	macroNos := make([]int, 0)
	dsNos := make([]int, 0)
	for i := 0; i < len(descriptions); i++ {
		macNo, dsNo, ok := GetMacNosDSNos(descriptions[i])
		if !ok {
			return "Cannot get exported macro and dataset numbers", false
		}
		allMacNos = append(allMacNos, macNo)
		if slices.Index(macroNos, macNo) == -1 {
			macroNos = append(macroNos, macNo)
		}
		dsNos = append(dsNos, dsNo)

	}
	cmds, _ := GetAllMappedMacroTCs()
	macroUpdateCmd := cmds[0]
	datasetUpdateCmd := cmds[1]
	macroEnableCmd := cmds[2]
	macroInitCmd := cmds[3]
	masterMacroEnableCmd := cmds[4]

	var builder strings.Builder
	builder.WriteString("!************************************************************!\n")
	builder.WriteString("!            Software Generated Macro and Dataset            !\n")
	builder.WriteString("!************************************************************!\n")

	builder.WriteString(getStepNo())
	builder.WriteString("\tTestName\tMacroUpload\n\n")
	builder.WriteString(getStepNo() + "\tSet\t\tTC APID Normal\n\n")
	disableMacros := getDisableMacros(macroEnableCmd, macroNos)
	builder.WriteString(disableMacros + "\n\n")
	builder.WriteString(getStepNo() + "\tSet\t\tTC APID Remote\n\n")

	for _, dsNo := range dsNos {
		builder.WriteString(getDataset(dsNo) + "\n\n")
	}

	for _, macNo := range macroNos {
		builder.WriteString(getMacro(macNo) + "\n\n")
	}
	builder.WriteString(getStepNo() + "Set\t\tTC APID Normal\n\n")

	builder.WriteString(getDatasetUpdate(datasetUpdateCmd, dsNos) + "\n\n")

	builder.WriteString(getMacroUpdate(macroUpdateCmd, macroNos) + "\n\n")

	builder.WriteString(getEnableMacros(macroEnableCmd, macroNos) + "\n\n")

	builder.WriteString(getStepNo() + "Send\t" + masterMacroEnableCmd + "\n\n")

	builder.WriteString(getDescriptionWithCommands(macroInitCmd, allMacNos, dsNos, descriptions) + "\n\n")

	builder.WriteString(getStepNo() + "End \n\n")

	//fmt.Println(builder.String())
	return builder.String(), true
}

func getDisableMacros(macroEnable string, macroNos []int) string {
	var builder strings.Builder
	builder.WriteString(getStepNo() + "\tSendlist\t")
	if len(macroNos) == 1 {
		macNo := macroNos[0]
		builder.WriteString(macroEnable + "\t0\t" + fmt.Sprintf("%d", macNo) + "\n")
	} else {
		for i := 0; i < len(macroNos); i++ {
			macNo := macroNos[i]
			if i == 0 {
				builder.WriteString(macroEnable + "\t0\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			} else if i == len(macroNos)-1 {
				builder.WriteString("\t\t\t" + macroEnable + "\t0\t" + fmt.Sprintf("%d", macNo) + "\n")
			} else {
				builder.WriteString("\t\t\t" + macroEnable + "\t0\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			}
		}
	}
	return builder.String()
}

func getEnableMacros(macroEnable string, macroNos []int) string {
	var builder strings.Builder
	builder.WriteString(getStepNo() + "Sendlist\t")
	if len(macroNos) == 1 {
		macNo := macroNos[0]
		builder.WriteString(macroEnable + "\t1\t" + fmt.Sprintf("%d", macNo) + "\n")
	} else {
		for i := 0; i < len(macroNos); i++ {
			macNo := macroNos[i]
			if i == 0 {
				builder.WriteString(macroEnable + "\t1\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			} else if i == len(macroNos)-1 {
				builder.WriteString("\t\t\t" + macroEnable + "\t1\t" + fmt.Sprintf("%d", macNo) + "\n")
			} else {
				builder.WriteString("\t\t\t" + macroEnable + "\t1\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			}
		}
	}
	return builder.String()
}

func getDataset(dsNo int) string {
	var builder strings.Builder
	builder.WriteString("!Dataset Number\t" + fmt.Sprintf("%d", dsNo) + "\n")
	dsAddress, _ := GetDatasetAddress(dsNo)
	addressMSB := dsAddress & 0xFFFFFFFF
	addressMSB = addressMSB >> 16
	addressLSB := dsAddress & 0xFFFF
	checksum := addressMSB + addressLSB
	builder.WriteString(getStepNo() + "\tSendlist\t")
	builder.WriteString("Dataword\t" + fmt.Sprintf("%04x;\t!Dataset Address MSB\n", addressMSB))
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!Dataset Address LSB\n", addressLSB))

	var noOfWords = 4 //word1: Dataset No, 2 words: Cmd Flag, 1Word: Spare
	noOfWords = noOfWords + (getNoOfDatainDS(dsNo) * 2)
	noOfWords = noOfWords + (getNoOfTimeinDS(dsNo) * 2)
	checksum = checksum + noOfWords
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!NoOfWords\n", noOfWords))
	checksum = checksum + dsNo
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!DSNo\n", dsNo))
	cntrlMSB := getDSControlMSB(dsNo) & 0xFFFF
	checksum = checksum + cntrlMSB
	cntrlLSB := getDSControlLSB(dsNo) & 0xFFFF
	checksum = checksum + cntrlLSB
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!MSBControlBits\n", cntrlMSB))
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!LSBControlBits\n", cntrlLSB))
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!Spare Hole\n", 0))

	data := getData(dsNo)
	for _, dataWord := range data {
		dataLong, err := strconv.ParseInt(dataWord, 16, 64)
		if err != nil {
			return ""
		}
		dataMSB := (dataLong >> 16) & 0xFFFF
		dataLSB := dataLong & 0xFFFF
		checksum = checksum + int(dataMSB) + int(dataLSB)
		builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!dataMSB\n", dataMSB))
		builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!dataLSB\n", dataLSB))

	}
	timeVals := getTime(dsNo)
	for _, t := range timeVals {
		timeVal := (t / 32) & 0xFFFF
		checksum = checksum + timeVal
		builder.WriteString(fmt.Sprintf("\t\t\tDataWord\t%04X;\t!TimeVal\n", timeVal))
	}
	checksum = checksum & 0xFFFF
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", checksum))
	checksum = 65535 - checksum
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", checksum))
	return builder.String()

}

func getNoOfDatainDS(dsNo int) int {
	var noOfData = 0
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)
	for i := 0; i < len(dsDetails.Executions); i++ {
		if dsDetails.Executions[i] {
			if len(dsDetails.Data[i]) != 0 {
				noOfData = noOfData + 1
			}
		}
	}
	return noOfData
}

func getNoOfTimeinDS(dsNo int) int {
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)

	var noOfTime = 0
	for i := 0; i < len(dsDetails.Executions); i++ {
		if dsDetails.Executions[i] {
			if dsDetails.Times[i] != 0 {
				noOfTime = noOfTime + 1
			}
		}
	}
	return noOfTime
}

func getDSControlMSB(dsNo int) int {
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)
	var ctrl = 0
	for i := 0; i < 16; i++ {
		ctrl = ctrl << 1
		if i < len(dsDetails.Executions) {
			if dsDetails.Executions[i] {
				ctrl = ctrl + 1
			}
		}
	}
	return ctrl
}

func getDSControlLSB(dsNo int) int {
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)
	var ctrl = 0
	for i := 16; i < 32; i++ {
		ctrl = ctrl << 1
		if i < len(dsDetails.Executions) {
			if dsDetails.Executions[i] {
				ctrl = ctrl + 1
			}
		}
	}
	return ctrl
}

func getData(dsNo int) []string {
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)
	data := make([]string, 0)
	for i := 0; i < len(dsDetails.Executions); i++ {
		if dsDetails.Executions[i] {
			if len(dsDetails.Data[i]) != 0 {
				data = append(data, dsDetails.Data[i])
			}
		}
	}
	return data
}

func getTime(dsNo int) []int {
	datasetNoStr := fmt.Sprintf("%d", dsNo)
	dsDetails, _ := FetchDatasetDetails(datasetNoStr)
	time := make([]int, 0)
	for i := 0; i < len(dsDetails.Executions); i++ {
		if dsDetails.Executions[i] {
			if dsDetails.Times[i] != 0 {
				time = append(time, dsDetails.Times[i])
			}
		}
	}
	return time
}

func getDataFromDatasets(macDetails utils.MacroDetails) int {
	mask := 0x80000000
	value := 0
	for i := 0; i < macDetails.NoOfCommands; i++ {
		if macDetails.Commands[i].DataFromDS {
			value = value | mask
		}
		mask = mask >> 1
	}
	return value

}

func getTimeFromDatasets(macDetails utils.MacroDetails) int {
	mask := 0x80000000
	value := 0
	for i := 0; i < macDetails.NoOfCommands; i++ {
		if macDetails.Commands[i].TimeFromDS {
			value = value | mask
		}
		mask = mask >> 1
	}
	return value

}

func getMacro(macroNo int) string {
	macroNoString := fmt.Sprintf("%d", macroNo)
	macDetails, _, _ := FetchMacroDetails(macroNoString)
	var builder strings.Builder
	builder.WriteString("!Macro Number\t" + fmt.Sprintf("%d", macDetails.MacroNo) + "\n")
	macAddress, _ := GetMacroAddress(macDetails.MacroNo)
	addressMSB := int64(macAddress) & 0xFFFFFFFF
	addressMSB = addressMSB >> 16
	addressLSB := int64(macAddress) & 0xFFFF
	checksum := addressMSB + addressLSB
	builder.WriteString(getStepNo() + "\tSendlist\t")
	builder.WriteString("Dataword\t" + fmt.Sprintf("%04x;\t!Macro Address MSB\n", addressMSB))
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!Macro Address LSB\n", addressLSB))

	var noOfWords = 6 //word1: No Of Commands, Word2: MacroNo, 2Words: UserDataReq, 2Words: Execution Time
	noOfWords = noOfWords + (macDetails.NoOfCommands * 4) + 2
	checksum = checksum + int64(noOfWords)
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!No Of Words\n", noOfWords))
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!Macro Number\n", int64(macDetails.MacroNo)))
	checksum = checksum + int64(macDetails.MacroNo)
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!No Of Commands\n", int64(macDetails.NoOfCommands)))
	checksum = checksum + int64(macDetails.NoOfCommands)

	userData := int64(getDataFromDatasets(macDetails))
	dataFromDSMSB := (userData >> 16) & 0xFFFF
	checksum = checksum + dataFromDSMSB
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!IsDataFromDS-first16cmds\n", dataFromDSMSB))
	dataFromDSLSB := userData & 0xFFFF
	checksum = checksum + dataFromDSLSB
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!IsDataFromDS-last16cmds\n", dataFromDSLSB))

	userTime := int64(getTimeFromDatasets(macDetails))
	timeFromDSMSB := (userTime >> 16) & 0xFFFF
	checksum = checksum + timeFromDSMSB
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!IsTimeFromDS-first16cmds\n", timeFromDSMSB))
	timeFromDSLSB := userTime & 0xFFFF
	checksum = checksum + timeFromDSLSB
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!IsTimeFromDS-last16cmds\n", timeFromDSLSB))

	for i := 0; i < macDetails.NoOfCommands; i++ {
		var cmdCode int64
		if macDetails.Commands[i].MnemonicOrCode == "Mnemonic" {
			temp, _ := GetCommandCode(macDetails.Commands[i].CommandMnemonic)

			cmdCode, _ = strconv.ParseInt(temp,16, 64)
		} else if macDetails.Commands[i].MnemonicOrCode == "Code" {
			cmdCode, _ = strconv.ParseInt(macDetails.Commands[i].CommandCode, 16, 64)
		}
		cmdMSB := (cmdCode >> 32) & 0xFFFF
		cmdMid := (cmdCode >> 16) & 0xFFFF
		cmdLSB := cmdCode & 0xFFFF

		checksum = checksum + cmdMSB
		builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\t!Command\n", cmdMSB))

		if macDetails.Commands[i].DataFromDS {
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", 0))
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", 0))
		} else {
			checksum = cmdMSB + cmdMid + cmdLSB
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", cmdMid))
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", cmdLSB))
		}
		if macDetails.Commands[i].TimeFromDS {
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", 0))
		} else {
			var time = int64(macDetails.Commands[i].Time / 32)
			time = time & 0xFFFF
			checksum = checksum + time
			builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", time))
		}
	}
	checksum = checksum & 0xFFFF
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", checksum))
	checksum = 65535 - checksum
	builder.WriteString("\t\t\tDataword\t" + fmt.Sprintf("%04x;\n", checksum))
	return builder.String()
}

func getDatasetUpdate(dsUpdate string, dsNos []int) string {
	var builder strings.Builder
	builder.WriteString(getStepNo() + "Sendlist\t")
	if len(dsNos) == 1 {
		dsNo := dsNos[0]
		builder.WriteString(dsUpdate + "\t1\t" + fmt.Sprintf("%d", dsNo) + "\n")
	} else {
		for i := 0; i < len(dsNos); i++ {
			dsNo := dsNos[i]
			if i == 0 {
				builder.WriteString(dsUpdate + "\t1\t" + fmt.Sprintf("%d", dsNo) + ";" + "\n")
			} else if i == len(dsNos)-1 {
				builder.WriteString("\t\t\t" + dsUpdate + "\t1\t" + fmt.Sprintf("%d", dsNo) + "\n")
			} else {
				builder.WriteString("\t\t\t" + dsUpdate + "\t1\t" + fmt.Sprintf("%d", dsNo) + ";" + "\n")
			}
		}
	}
	return builder.String()
}

func getMacroUpdate(macroUpdate string, macNos []int) string {
	var builder strings.Builder
	builder.WriteString(getStepNo() + "Sendlist\t")
	if len(macNos) == 1 {
		macNo := macNos[0]
		builder.WriteString(macroUpdate + "\t1\t" + fmt.Sprintf("%d", macNo) + "\n")
	} else {
		for i := 0; i < len(macNos); i++ {
			macNo := macNos[i]
			if i == 0 {
				builder.WriteString(macroUpdate + "\t1\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			} else if i == len(macNos)-1 {
				builder.WriteString("\t\t\t" + macroUpdate + "\t1\t" + fmt.Sprintf("%d", macNo) + "\n")
			} else {
				builder.WriteString("\t\t\t" + macroUpdate + "\t1\t" + fmt.Sprintf("%d", macNo) + ";" + "\n")
			}
		}
	}
	return builder.String()
}

func getDescriptionWithCommands(macInit string, allMacNos []int, dsNos []int, desc []string) string {
	var builder strings.Builder

	for i := 0; i < len(dsNos); i++ {
		macNo := allMacNos[i]
		dsNo := dsNos[i]
		descr := desc[i]
		builder.WriteString(getStepNo() + "\t!Macro\t")
		builder.WriteString(descr + "\t" + macInit + "\t\t" + fmt.Sprintf("%d", macNo) + "\t0\t")
		builder.WriteString(fmt.Sprintf("%d", dsNo) + "\t	MacroNo 0 DatasetNo" + "\n")
	}
	return builder.String()
}
