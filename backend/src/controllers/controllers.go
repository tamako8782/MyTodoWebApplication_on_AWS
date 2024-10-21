package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/tamako8782/MyTodoWebApplication_practice/models"
	"github.com/tamako8782/MyTodoWebApplication_practice/services"
)

type MyTaskControllers struct {
	s *services.MyTaskService
}

func NewMyTaskControllers(s *services.MyTaskService) *MyTaskControllers {
	return &MyTaskControllers{s: s}
}

func (c MyTaskControllers) ListTaskHandler(w http.ResponseWriter, r *http.Request) {
	queryMap := r.URL.Query()

	var page int
	if p, ok := queryMap["page"]; ok && len(p) > 0 {
		var err error
		page, err = strconv.Atoi(p[0])
		if err != nil {
			http.Error(w, "failed get query parameter", http.StatusBadRequest)

		}
	} else {
		page = 1
	}

	taskList, err := c.s.ListTaskService(page)
	if err != nil {
		http.Error(w, "internal exec ", http.StatusInternalServerError)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(taskList)

}

func (c MyTaskControllers) CreateTaskHandler(w http.ResponseWriter, r *http.Request) {

	var reqTask models.MyTodo

	if err := json.NewDecoder(r.Body).Decode(&reqTask); err != nil {
		http.Error(w, "Decode failed", http.StatusBadRequest)
		return
	}

	task, err := c.s.CreateTaskService(reqTask)
	if err != nil {
		http.Error(w, "internal exec", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)

}

func (c MyTaskControllers) DetailTaskHandler(w http.ResponseWriter, r *http.Request) {
	taskId, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "failed get the task ", http.StatusBadRequest)
		return
	}

	task, err := c.s.DetailTaskService(taskId)
	if err != nil {
		http.Error(w, "internal exec", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)

}

func (c MyTaskControllers) UpdateTaskHandler(w http.ResponseWriter, r *http.Request) {
	taskId, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "failed get the task ", http.StatusBadRequest)
		return
	}

	var reqTask models.MyTodo
	if err := json.NewDecoder(r.Body).Decode(&reqTask); err != nil {
		http.Error(w, "Decode failed", http.StatusBadRequest)
		return
	}

	task, err := c.s.UpdateTaskService(taskId, reqTask)
	if err != nil {
		http.Error(w, "internal exec", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func (c MyTaskControllers) DeleteTaskHandler(w http.ResponseWriter, r *http.Request) {

	taskId, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "failed get the task", http.StatusBadRequest)
		return
	}

	delResult, err := c.s.DeleteTaskService(taskId)
	if err != nil {
		http.Error(w, "internal exec", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(delResult)

}

func (c MyTaskControllers) ChangeTaskHandler(w http.ResponseWriter, r *http.Request) {
	taskId, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, "failed get the task ", http.StatusBadRequest)
		return
	}

	var reqTask models.MyTodo
	if err := json.NewDecoder(r.Body).Decode(&reqTask); err != nil {
		http.Error(w, "Decode failed", http.StatusBadRequest)
		return
	}

	chTask, err := c.s.ChangeTaskService(taskId, reqTask.State)
	if err != nil {
		http.Error(w, "internal exec", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(chTask)
}
