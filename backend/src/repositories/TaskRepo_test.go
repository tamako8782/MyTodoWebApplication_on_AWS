package repositories_test

import (
	"log"
	"testing"

	"github.com/tamako8782/MyTodoWebApplication_practice/models"
	"github.com/tamako8782/MyTodoWebApplication_practice/repositories"
)

func TestListTaskRepo(t *testing.T) {

	expectedNum := 3
	log.Println("test")
	got, err := repositories.ListTaskRepo(testDB, 1)
	if err != nil {

		t.Fatal(err)
	}

	if num := len(got); num != expectedNum {
		t.Errorf("want %d but got %d todo\n", expectedNum, num)

	}

}

func TestCreateTaskRepo(t *testing.T) {
	testTask := TestCreateData[0]

	exceptedNum := 4

	exec, err := repositories.CreateTaskRepo(testDB, testTask)
	if err != nil {
		t.Fatal(err)
	}

	if exec.ID != exceptedNum {
		t.Errorf("new task id is expected %d but got %d \n", exceptedNum, exec.ID)
	}

	t.Cleanup(func() {
		const sqlStr = `
		delete from task
		where task_id=?;
		`
		testDB.Exec(sqlStr, exec.ID)
	})

}

func TestDetailRepo(t *testing.T) {

	tests := []struct {
		testTitle string
		excpted   models.MyTodo
	}{
		{
			testTitle: "subtest1",
			excpted:   TestData[0],
		},
		{
			testTitle: "subtest2",
			excpted:   TestData[1],
		},
	}

	for _, test := range tests {
		t.Run(test.testTitle, func(t *testing.T) {
			got, err := repositories.DetailTaskRepo(test.excpted.ID, testDB)
			if err != nil {
				t.Fatal(err)
			}

			if got.ID != test.excpted.ID {
				t.Errorf("ID:get %d but want %d\n", got.ID, test.excpted.ID)
			}
		})
	}

}

func TestUpdateRepo(t *testing.T) {

	testBfTask := TestUpdateData[0]
	testAfTask := TestUpdateData[1]

	_, err := repositories.CreateTaskRepo(testDB, testBfTask)
	if err != nil {
		t.Fatal(err)
	}

	testAf, err := repositories.UpdateTaskRepo(testBfTask.ID, testAfTask, testDB)
	if err != nil {
		t.Fatal(err)
	}

	if testAf.ID != testAfTask.ID {
		t.Errorf("new task id is expected %d but got %d", testAfTask.ID, testAf.ID)
	}

	if testAf.Title != testAfTask.Title {
		t.Errorf("new task title is expected %s but got %s", testAfTask.Title, testAf.Title)
	}

	t.Cleanup(func() {
		const sqlStr = `
		delete from task
		where task_id=?;
		`
		testDB.Exec(sqlStr, testAf.ID)
	})

}

func TestDeleteRepo(t *testing.T) {

	testTask := TestDeleteData[0]

	_, err := repositories.CreateTaskRepo(testDB, testTask)
	if err != nil {
		t.Fatal(err)
	}

	testDel, err := repositories.DeleteTaskRepo(testTask.ID, testDB)
	if err != nil {
		t.Fatal(err)
	}

	if !testDel {
		t.Fatal("delete failed")
	}
}

func TestChangeRepo(t *testing.T) {

	testBfTask := TestChangeData[0]
	testInCompTask := TestChangeData[1]
	testFinTask := TestChangeData[2]
	testNotDoTask := TestChangeData[3]

	bf, err := repositories.CreateTaskRepo(testDB, testBfTask)
	if err != nil {
		t.Fatal(err)
	}
	//作成済みテストタスクのID確認
	if bf.ID != testBfTask.ID {
		t.Errorf("new task id is expected %d but got %d", testBfTask.ID, bf.ID)
	}
	//タスクの状態をincompに変更
	testInComp, err := repositories.ChangeTaskRepo(testBfTask.ID, testInCompTask.State, testDB)
	if err != nil {
		t.Fatal(err)
	}
	//incompになってるよね?を確認
	if testInComp.State != testInCompTask.State {
		t.Errorf("new task state is expected %s but got %s", testInCompTask.State, testInComp.State)
	}
	//タスクの状態をfinishedに変更
	testFinised, err := repositories.ChangeTaskRepo(testBfTask.ID, testFinTask.State, testDB)
	if err != nil {
		t.Fatal(err)
	}
	//finishedになってるよね?を確認
	if testFinised.State != testFinTask.State {
		t.Errorf("new task state is expected %s but got %s", testFinTask.State, testFinised.State)
	}

	//タスクの状態をNotDoに変更
	testNotDo, err := repositories.ChangeTaskRepo(testBfTask.ID, testNotDoTask.State, testDB)
	if err != nil {
		t.Fatal(err)
	}
	//NotDoになってるよね?を確認
	if testNotDo.State != testNotDoTask.State {
		t.Errorf("new task state is expected %s but got %s", testNotDoTask.State, testNotDo.State)
	}

	t.Cleanup(func() {
		const sqlStr = `
		delete from task
		where task_id=?;
		`
		testDB.Exec(sqlStr, testNotDoTask.ID)
	})

}
