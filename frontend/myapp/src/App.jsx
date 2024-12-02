import { createContext, useEffect, useState } from 'react';
import './App.css';

import { CreateModal } from './compornents/CreateModal';
import { DetailModal } from './compornents/DetailModal';
import { EditModal } from './compornents/EditModal';  
import { DeleteModal } from './compornents/DeleteModal';  

export const TaskContext = createContext();

export const App = () => {
  /////////////モーダル制御用
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);  
  const [showDeleteModal, setShowDeleteModal] = useState(false);  
  const [selectedTask, setSelectedTask] = useState(null); 

  /////////////タスクリスト制御用
  const [inCompTask, setInCompTask] = useState([]);
  const [finishTask, setFinishTask] = useState([]);
  const [notDoTask, setNotDoTask] = useState([]);

  /////////////エラー制御用
  const [error, setError] = useState(null);

  /////////////6タスク数制御用
  const maxTasks = 6;
  const taskCount = inCompTask.length; // inCompTaskはタスクリストの配列

  /////////////apiパス定義用
  const apipath_env = process.env.REACT_APP_BACKEND_PATH;
  const listpath = apipath_env + "/task";
  const createpath = apipath_env + "/task/create";
  const detailpath = apipath_env + "/task"; // 詳細情報用のパス

  ///////////// モーダル参照用のコード(新規作成)
  const ShowCreateModal = () => {
    setShowCreateModal(true);
  };

  ///////////// タスク詳細を取得して詳細モーダルを表示する関数
  const ShowDetailModal = (id) => {
    setShowDetailModal(true);  // DetailModalを表示

    // APIからデータを取得
    fetch(`${detailpath}/${id}`)
      .then(response => {
        if (!response.ok) {
          throw new Error("Failed to fetch task details. Please try again later.");
        }
        return response.json();
      })
      .then(data => {
        setSelectedTask(data);  // 正常にデータを取得し、selectedTaskに保存
      })
      .catch(error => {
        console.error("Error fetching task details:", error);
        alert("Error: Unable to fetch task details. Please try again later.");
        setShowDetailModal(false);  // エラー時にモーダルを閉じる
      });
  };

  ///////////// 編集モーダルを表示する関数
  const ShowEditModal = (id) => {
    setShowEditModal(true);  // EditModalを表示
  };

  ///////////// 削除モーダルを表示する関数
  const ShowDeleteModal = (id) => {
    setShowDeleteModal(true);  
  };


  ///////////////リストをAPIから取得するためのコード
  const fetchTaskList = () => {
    fetch(listpath)
      .then(response => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then(data => {
        const inpro = data.filter(task => task.state === "InComplete");
        const notDo = data.filter(task => task.state === "NotDoTask");
        const fin = data.filter(task => task.state === "Finished");
        setInCompTask(inpro);
        setFinishTask(fin);
        setNotDoTask(notDo);
      })
      .catch(error => {
        setError(error);
      });
  };

  /////////////// changeapiとやり取りするための
  const handleChangeTask = (id,newState) => {
    
    const changepath = `${detailpath}/${id}/change`;

    fetch(changepath, {
      method: "PATCH", // PATCHメソッドを使用して部分更新
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        state:newState,
      }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Task update failed.");
        }
        return response.json();
      })
      .then((data) => {
        console.log("Task changed successfully", data);

        fetchTaskList();
      })
      .catch((error) => {
        console.error("Error changing task:", error);
        alert("Failed to changing task.");
      });
  };


  /////////////// 初回ロード時にタスクリストを取得
  useEffect(() => {
    fetchTaskList();
  }, []);

  // HTMLを返す
  return (
    <TaskContext.Provider value={createpath}>
      <>
        <header>
          <div className='main-title'>
            <h1>My<span className='titlespan'>Todo</span>Application</h1>
            <p>Optimize your tasks with this todo list!</p>
          </div>
        </header>

        <main>
          <div className='createtask'>
            <button onClick={ShowCreateModal}>Create task!</button>

            {/* CreateModalにonTaskCreatedを渡す */}
            <CreateModal
              showFlag={showCreateModal}
              setShowCreateModal={setShowCreateModal}
              onTaskCreated={fetchTaskList}  // タスク作成後にタスクリストを更新
              taskCount={taskCount} maxTasks={maxTasks}
            />
          </div>

          <div className='incompletetask'>
            
              <p className='task-title'>Today's 6 Tasks</p>
              {taskCount >= maxTasks && (<p className='task-warning'> Oops, you can only add up to 6 tasks!</p>
            )}
            
            <ul>
              {inCompTask.map(task => (
                <li key={task.id}>
                  <p className='task-title-text'>{task.title}</p>
                  <div className='button-group-main'>
                    <button onClick={() => handleChangeTask(task.id,"Finished")} className="comp-button">complete!</button>
                    <button onClick={() => ShowDetailModal(task.id)} className="detail-button">detail</button>
                  </div>
                </li>
              ))}
            </ul>
          </div>

          <div className='lower-task'>
            <div className='not-do-tasks'>
            <p className='task-title'>Not Do Tasks</p>
              <ul>
                {notDoTask.map(task => (
                  <li key={task.id}>
                    <p className='task-title-text'>{task.title}</p>
                    <div className='button-group-main'>
                      <button onClick={() => handleChangeTask(task.id,"InComplete")} className="dotoday-button"  disabled={taskCount >= maxTasks} >do today!</button>
                    
                    <button onClick={() => ShowDetailModal(task.id)} className="detail-button">detail</button>
                    </div>
                  </li>
                ))}
              </ul>
            </div>

            <div className='finishedtask'>
              <p className='task-title'>Finished Tasks</p>
              <ul>
                {finishTask.map(task => (
                  <li key={task.id}>
                    <p className='task-title-text'>{task.title}</p>
                    <div className='button-group-main'>
                      {/*<button onClick={() => handleChangeTask(task.id,"InComplete")}  className="restore-button-today"  disabled={taskCount >= maxTasks}>restore(Today)</button>*/}
                      <button onClick={() => handleChangeTask(task.id,"NotDoTask")}  className="restore-button-nottoday">restore</button>                    
                      <button onClick={() => ShowDetailModal(task.id)} className="detail-button">detail</button>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* DetailModalにeditモーダル表示の関数を渡す */}
          {selectedTask && (
            <DetailModal
              setShowDeleteModal={setShowDeleteModal} // ここで削除用モーダルを表示する
              showFlag={showDetailModal}
              setShowDetailModal={setShowDetailModal}
              task={selectedTask}
              onEdit={() => {
                setShowDetailModal(false); // DetailModalを閉じる
                ShowEditModal(selectedTask.id); // EditModalを表示する
              }}
              onDelete={() => {
                setShowDetailModal(false); // DetailModalを閉じる
                setShowDeleteModal(true);  // 削除モーダルを表示
              }}
            />
          )}
          {/* DeleteModalの表示 */}
          {selectedTask && (
            <DeleteModal
              setShowDetailModal={setShowDetailModal}
              showFlag={showDeleteModal}
              setShowDeleteModal={setShowDeleteModal}
              detailpath={detailpath}
              task={selectedTask}  // タスクの詳細をEditModalに渡す
              onTaskDeleted={fetchTaskList}  // タスク更新後にリストを再取得
            />
          )}

          {/* EditModalの表示 */}
          {selectedTask && (
            <EditModal
              showFlag={showEditModal}
              setShowEditModal={setShowEditModal}
              detailpath={detailpath}
              task={selectedTask}  // タスクの詳細をEditModalに渡す
              onTaskUpdated={fetchTaskList}  // タスク更新後にリストを再取得
              taskCount={taskCount} maxTasks={maxTasks}
            />
          )}
        </main>

        <footer></footer>
      </>
    </TaskContext.Provider>
  );
};
