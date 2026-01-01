package db

import (
	"database/sql"
	"fmt"
	database "macro/dbGenerated"
	"macro/utils"
	"os"

	_ "modernc.org/sqlite"
)

var dbObject *database.Queries

func Connect() bool {
	dbExists := checkIfDatabaseExists(utils.Config.Database)
	db, err := sql.Open("sqlite", utils.Config.Database)
	db.SetMaxOpenConns(1)
	var ok = true
	if err != nil {
		return false
	}
	if !dbExists {
		ok = createDatabase(db)
		if !ok {
			fmt.Println("Cannot Create Database")
		}
	}
	dbObject = database.New(db)
	return ok
}

func checkIfDatabaseExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func createDatabase(db *sql.DB) bool {
	tx, err := db.Begin()
	if err != nil {
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "MacroAddresses" (
			"MacroNo"	INTEGER NOT NULL Constraint pkMacro PRIMARY KEY,
			"NoOfCommands"	INTEGER NOT NULL,
			"Address"	INTEGER NOT NULL
		)`)
	if err != nil {
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "DatasetAddresses" (
			"DatasetNo"	INTEGER NOT NULL Constraint pkDS PRIMARY KEY,
			"NoOfCommands"	INTEGER NOT NULL,
			"Address"	INTEGER NOT NULL
		)`)
	if err != nil {
		tx.Rollback()
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "MacroDetails" (
		"MacroNo"	INTEGER NOT NULL Constraint pkMacroDetails PRIMARY KEY,
		"Details"	TEXT 
	)`)
	if err != nil {
		tx.Rollback()
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "DatasetDetails" (
		"DatasetNo"	    INTEGER NOT NULL Constraint pkDSDetails PRIMARY KEY,
		"Details"	    TEXT,
		"LinkedMacro"	INTEGER
		"Description:   TEXT,
	)`)
	if err != nil {
		tx.Rollback()
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "Telecommands" (
		"CommandID"	TEXT NOT NULL Constraint pkTC PRIMARY KEY,
		"Mnemonics"	TEXT NOT NULL,
		"Code"	TEXT NOT NULL,
		"Type" TEXT NOT NULL
	)`)
	if err != nil {
		tx.Rollback()
		return false
	}
	_, err = tx.Exec(`CREATE TABLE "MacroRelatedTCs" (
		"ID"	INTEGER NOT NULL Constraint pkMacroTC PRIMARY KEY,
		"MacroUpdate"	TEXT NOT NULL,
		"DatasetUpdate"	TEXT NOT NULL,
		"MacroEnable"	TEXT NOT NULL,
		"MacroInit"	TEXT NOT NULL,
		"MasterMacroEnable"	TEXT NOT NULL
	)`)
	if err != nil {
		tx.Rollback()
		return false
	}
	_, err = tx.Exec(`INSERT INTO "MacroRelatedTCs" Values (1,"","","","","");`)
	if err != nil {
		tx.Rollback()
		return false
	}

	tx.Commit()
	return true
}
