-- name: StoreMacroAddresses :exec
Insert into "MacroAddresses" 
("MacroNo", "NoOfCommands", "Address") 
values 
(?, ?, ?);

-- name: StoreDatasetAddresses :exec
Insert into "DatasetAddresses" 
("DatasetNo", "NoOfCommands", "Address") 
values 
(?, ?, ?);

-- name: StoreMacroDetails :exec
Insert into "MacroDetails" 
("MacroNo", "Details") 
values 
(?, ?);

-- name: StoreDatasetDetails :exec
Insert into "DatasetDetails" 
("DatasetNo", "Details", "LinkedMacro", "Description") 
values 
(?, ?, ?, ?);

-- name: StoreTelecommands :exec
Insert into "Telecommands" 
("CommandID", "Mnemonics", "Code", "Type") 
values 
(?, ?, ?, ?);

-- name: StoreMacroRelatedTCs :exec
Update MacroRelatedTCs set
"MacroUpdate" = ?,
"DatasetUpdate" = ?,
"MacroEnable" = ?,
"MacroInit" = ?,
"MasterMacroEnable" = ? ;

-- name: GetMacroDetails :one
Select * from "MacroDetails"
where "MacroNo" = ? Limit 1;

-- name: GetDatasetDetails :one
Select * from "DatasetDetails"
where "DatasetNo" = ? Limit 1;

-- name: GetAllTCMnemonics :many
Select "Mnemonics" from "Telecommands" ;

-- name: GetCommandType :one
Select "Type" from "Telecommands" where "Mnemonics" = ? Limit 1;

-- name: GetMacroTypes :many
Select Distinct "NoOfCommands" from "MacroAddresses" ;

-- name: GetMacroNoBasedOnType :many
Select "MacroNo" from "MacroAddresses" where "NoOfCommands" = ?;

-- name: ClearMacroAddress :exec
Delete from "MacroAddresses";

-- name: ClearDatasetAddress :exec
Delete from "DatasetAddresses";

-- name: ClearTelecommands :exec
Delete from "Telecommands";

-- name: GetMappedMacroCommands :many
Select * from "MacroRelatedTCs";

-- name: GetAllMacros :many
Select "MacroNo"  from "MacroAddresses";

-- name: GetAllDatasets :many
Select "DatasetNo"  from "DatasetAddresses";

-- name: GetSavedMacroNos :many
Select "MacroNo"  from "MacroDetails";

-- name: GetDatasetNosBasedOnMacroType :many
Select "DatasetNo" from "DatasetAddresses" where "NoOfCommands" is 
(Select "NoOfCommands" from "MacroAddresses" where "MacroNo"  = ?);

-- name: GetMacroTypeBasedOnNumber :one
Select "NoOfCommands" from "MacroAddresses" where "MacroNo" = ?;

-- name: ClearMacroDetails :exec
Delete from "MacroDetails" where "MacroNo" = ? ;

-- name: ClearDatasetDetails :exec
Delete from "DatasetDetails" where "DatasetNo" = ? ;

-- name: GetCompletedMacroDetails :many
Select "LinkedMacro", "DatasetNo", "Description" from "DatasetDetails";

-- name: GetMacNoDSNoBasedOnDescription :one
Select "DatasetNo", "LinkedMacro" from "DatasetDetails" where "Description" = ? Limit 1;

-- name: GetMacroAddress :one
Select "Address" from "MacroAddresses" where "MacroNo" = ? Limit 1;

-- name: GetDatasetAddress :one
Select "Address" from "DatasetAddresses" where "DatasetNo" = ? Limit 1;

-- name: GetCommandCode :one
Select "Code" from "Telecommands" where "Mnemonics" = ? Limit 1;

-- name: GetDescriptionForDataset :one
Select "Description" from "DatasetDetails" where "DatasetNo" = ? Limit 1;



