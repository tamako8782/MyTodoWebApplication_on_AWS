package repositories

import (
	"database/sql"
	"log"

	"github.com/tamako8782/MyTodoWebApplication_practice/models"
)

const (
	todoPerPage = 100
)

func ListTaskRepo(db *sql.DB, page int) ([]models.MyTodo, error) {

	sqlStr := `
		select task_id ,title, task_state
		from task
		limit ? offset ?;
	`

	rows, err := db.Query(sqlStr, todoPerPage, ((page - 1) * todoPerPage))
	if err != nil {
		log.Println(err)
	}

	taskArray := make([]models.MyTodo, 0)
	for rows.Next() {
		var task models.MyTodo
		rows.Scan(&task.ID, &task.Title, &task.State)

		taskArray = append(taskArray, task)
	}

	return taskArray, nil

}

func CreateTaskRepo(db *sql.DB, task models.MyTodo) (models.MyTodo, error) {
	sqlStr := `
	insert into task (title, contents,task_state) 
	values 
	(?,?,?);
	`

	var createTask models.MyTodo
	createTask.Title = task.Title
	createTask.Content = task.Content
	createTask.State = task.State

	result, err := db.Exec(sqlStr, task.Title, task.Content, task.State)
	if err != nil {
		log.Println(err)
		return models.MyTodo{}, err
	}

	taskId, _ := result.LastInsertId()
	createTask.ID = int(taskId)

	return createTask, nil

}

func DetailTaskRepo(id int, db *sql.DB) (models.MyTodo, error) {
	sqlStr := `
	select * from task
	where task_id=?;
	`

	row := db.QueryRow(sqlStr, id)
	if err := row.Err(); err != nil {
		log.Println(err)
		return models.MyTodo{}, err
	}

	var task models.MyTodo

	var createTime = sql.NullTime{}
	var updateTime = sql.NullTime{}

	if err := row.Scan(&task.ID, &task.Title, &task.Content, &task.State, &createTime, &updateTime); err != nil {
		log.Println(err)
		return models.MyTodo{}, err
	}

	if createTime.Valid {
		task.CreatedAt = createTime.Time
	}
	if updateTime.Valid {
		task.UpdatedAt = updateTime.Time
	}

	return task, nil

}

func UpdateTaskRepo(id int, task models.MyTodo, db *sql.DB) (models.MyTodo, error) {
	sqlStr := `
	UPDATE task
	SET title=?,
	contents=?,
	task_state=?
	where task_id=?;
	`

	tx, err := db.Begin()
	if err != nil {
		return models.MyTodo{}, err
	}

	_, err = tx.Exec(
		sqlStr,
		task.Title,
		task.Content,
		task.State,
		id)

	if err != nil {
		log.Println(err)
		tx.Rollback()
	}

	tx.Commit()

	resultData, err := DetailTaskRepo(id, db)
	if err != nil {
		return models.MyTodo{}, err
	}

	return resultData, nil

}

func DeleteTaskRepo(id int, db *sql.DB) (bool, error) {
	sqlStr := `
		delete from task
		where task_id = ?; 
	`

	result, err := db.Exec(sqlStr, id)
	if err != nil {
		log.Println(err)
		return false, err
	}

	delResult, err := result.RowsAffected()
	if err != nil {
		log.Println(err)
		return false, err
	} else if delResult >= 0 {
		return true, nil
	} else {
		return false, err
	}

}

func ChangeTaskRepo(id int, taskState string, db *sql.DB) (models.MyTodo, error) {
	sqlStr := `
	UPDATE task
	SET task_state=?
	where task_id=?;
	`

	tx, err := db.Begin()
	if err != nil {
		return models.MyTodo{}, err
	}

	_, err = tx.Exec(
		sqlStr,
		taskState,
		id)

	if err != nil {
		log.Println(err)
		tx.Rollback()
	}

	tx.Commit()

	resultData, err := DetailTaskRepo(id, db)
	if err != nil {
		return models.MyTodo{}, err
	}

	return resultData, nil

}
