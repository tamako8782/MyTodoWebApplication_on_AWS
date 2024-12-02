package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var (
	dbUser     = os.Getenv("MYSQL_USER")
	dbPassword = os.Getenv("MYSQL_PASSWORD")
	dbDatabase = os.Getenv("MYSQL_DATABASE")
	dbHost     = os.Getenv("MYSQL_HOST")

	dbConn = fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?parseTime=true", dbUser, dbPassword, dbHost, dbDatabase)
)

func DBConn() (*sql.DB, error) {
	db, err := sql.Open("mysql", dbConn)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	if err = db.Ping(); err != nil {
		log.Fatalln(err)
		return nil, err
	}

	return db, nil

}
