package utils

type databasePaths struct {
	DBPath string
}

type EmptyRequest struct {
	ID string
}

type MacroOrDSEntry struct {
	StartMacroOrDSNo int
	EndMacroOrDSNo   int
	NumCommands      int
	StartAddress     int
	NumBytes         int
}

type MacroOrDSAddresses struct {
	MacroDSNo   int
	MacroDSType int
	Address     int
}

type MacroDetails struct {
	MacroNo      int
	NoOfCommands int
	Commands     []MacroCommand
}

type MacroCommand struct {
	MnemonicOrCode  string
	CommandMnemonic string
	CommandCode     string
	DataFromDS      bool
	TimeFromDS      bool
	Time            int
}

type MacroRequest struct {
	ID    string
	Macro MacroDetails
}

type MacroResponse struct {
	Macro   MacroDetails
	OK      bool
	Message string
}

type DatasetDetails struct {
	DatasetNo  int
	Executions []bool
	Data       []string
	Times      []int
}

type DatasetRequest struct {
	ID          string
	Dataset     DatasetDetails
	LinkedMacro int
	Description string
}

type DatasetResponse struct {
	Dataset DatasetDetails
	OK      bool
	Message string
}

type Acknowledgement struct {
	OK      bool
	Message string
}

type ValueRequest struct {
	ID    string
	Param string
}

type MultiValueResponse struct {
	Values  []string
	OK      bool
	Message string
}

type ValueResponse struct {
	Value   string
	OK      bool
	Message string
}

type CSVFileRequest struct {
	ID       string
	FileType string
	FileData string
}

type ParameterRequest struct {
	ID             string
	ParameterName  string
	ParameterValue string
}

type TCDatabase struct {
	CommandID   string
	CommandName string
	CommandType string
	CommandCode string
}

type MultiValueRequest struct {
	ID              string
	ParameterName   string
	ParameterValues []string
}

type CompletedMacros struct {
	Macros  []CompletedMacro
	OK      bool
	Message string
}

type CompletedMacro struct {
	MacroNo     int
	DatasetNo   int
	Description string
}

type InspectedCommand struct {
	Index           int
	CommandMnemonic string
	CommandCode     string
	Data            string
	Time            int
	Executed        bool
}

type InspectionItem struct {
	MacroNo     int
	DatasetNo   int
	Description string
	Commands    []InspectedCommand
}

type InspectionResponse struct {
	Items   []InspectionItem
	OK      bool
	Message string
}
