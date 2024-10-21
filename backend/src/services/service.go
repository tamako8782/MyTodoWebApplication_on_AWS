package services

import "database/sql"

type MyTaskService struct {
	db *sql.DB
}

func NewMyTaskService(db *sql.DB) *MyTaskService {
	return &MyTaskService{db: db}
}
