package services

import (
	"github.com/tamako8782/MyTodoWebApplication_practice/models"
	"github.com/tamako8782/MyTodoWebApplication_practice/repositories"
)

func (s MyTaskService) ListTaskService(page int) ([]models.MyTodo, error) {

	var Tasks []models.MyTodo
	Tasks, err := repositories.ListTaskRepo(s.db, page)
	if err != nil {
		return []models.MyTodo{}, err
	}

	return Tasks, nil
}

func (s MyTaskService) CreateTaskService(task models.MyTodo) (models.MyTodo, error) {

	addtask, err := repositories.CreateTaskRepo(s.db, task)
	if err != nil {

		return models.MyTodo{}, err
	}

	return addtask, nil
}

func (s MyTaskService) DetailTaskService(id int) (models.MyTodo, error) {
	task, err := repositories.DetailTaskRepo(id, s.db)
	if err != nil {

		return models.MyTodo{}, err
	}

	return task, nil
}

func (s MyTaskService) UpdateTaskService(id int, task models.MyTodo) (models.MyTodo, error) {
	upTask, err := repositories.UpdateTaskRepo(id, task, s.db)
	if err != nil {

		return models.MyTodo{}, err
	}

	return upTask, nil
}

func (s MyTaskService) DeleteTaskService(id int) (bool, error) {
	dlTask, err := repositories.DeleteTaskRepo(id, s.db)
	if err != nil {
		return false, err
	}

	return dlTask, nil

}

func (s MyTaskService) ChangeTaskService(id int, taskState string) (models.MyTodo, error) {
	chTask, err := repositories.ChangeTaskRepo(id, taskState, s.db)
	if err != nil {
		return models.MyTodo{}, err
	}

	return chTask, err
}
