package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
	"github.com/tamako8782/MyTodoWebApplication_practice/controllers"
	"github.com/tamako8782/MyTodoWebApplication_practice/db"
	"github.com/tamako8782/MyTodoWebApplication_practice/services"
)

func main() {
	r := mux.NewRouter()

	db, err := db.DBConn()
	if err != nil {
		log.Println(err)
	}

	s := services.NewMyTaskService(db)
	c := controllers.NewMyTaskControllers(s)

	r.HandleFunc("/task", c.ListTaskHandler).Methods(http.MethodGet)
	r.HandleFunc("/task/create", c.CreateTaskHandler).Methods(http.MethodPost)
	r.HandleFunc("/task/{id:[0-9]+}", c.DetailTaskHandler).Methods(http.MethodGet)
	r.HandleFunc("/task/{id:[0-9]+}/update", c.UpdateTaskHandler).Methods(http.MethodPatch)
	r.HandleFunc("/task/{id:[0-9]+}/delete", c.DeleteTaskHandler).Methods(http.MethodDelete)
	r.HandleFunc("/task/{id:[0-9]+}/change", c.ChangeTaskHandler).Methods(http.MethodPatch)

	co := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"}, // ReactアプリのURL
		AllowedMethods:   []string{"GET", "POST", "PATCH", "DELETE"},
		AllowedHeaders:   []string{"Authorization", "Content-Type"},
		AllowCredentials: true,
	})

	// CORSミドルウェアをラップ

	myHandler := co.Handler(r)

	log.Println("listen to port :8080")
	http.ListenAndServe(":8080", myHandler)

}
