
CREATE TABLE "MacroAddresses" (
	"MacroNo"	INTEGER NOT NULL Constraint pkMacro PRIMARY KEY,
	"NoOfCommands"	INTEGER NOT NULL,
	"Address"	INTEGER NOT NULL
);

CREATE TABLE "DatasetAddresses" (
	"DatasetNo"	INTEGER NOT NULL Constraint pkDS PRIMARY KEY,
	"NoOfCommands"	INTEGER NOT NULL,
	"Address"	INTEGER NOT NULL
);

CREATE TABLE "MacroDetails" (
	"MacroNo"	INTEGER NOT NULL Constraint pkMacroDetails PRIMARY KEY,
	"Details"	TEXT NOT NULL
);

CREATE TABLE "DatasetDetails" (
	"DatasetNo"	INTEGER NOT NULL Constraint pkDSDetails PRIMARY KEY,
	"Details"	TEXT NOT NULL,
	"LinkedMacro" INTEGER NOT NULL,
	"Description" TEXT NOT NULL
);

CREATE TABLE "Telecommands" (
	"CommandID"	TEXT NOT NULL Constraint pkTC PRIMARY KEY,
	"Mnemonics"	TEXT NOT NULL,
	"Code"	TEXT NOT NULL,
	"Type" TEXT NOT NULL
);

CREATE TABLE "MacroRelatedTCs" (
	"ID"	INTEGER NOT NULL Constraint pkMacroTC PRIMARY KEY,
	"MacroUpdate"	TEXT NOT NULL,
	"DatasetUpdate"	TEXT NOT NULL,
	"MacroEnable"	TEXT NOT NULL,
	"MacroInit"	TEXT NOT NULL,
	"MasterMacroEnable"	TEXT NOT NULL
);