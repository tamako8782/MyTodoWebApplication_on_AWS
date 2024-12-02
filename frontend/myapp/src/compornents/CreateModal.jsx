import React, { useState, useContext } from "react";
import classes from "./Modalstyle.module.scss";
import { TaskContext } from "../App"; 

export const CreateModal = (props) => {
  // モーダル内で使用する入力値の状態管理
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [state, setState] = useState("NotDoTask");  

  const createpath = useContext(TaskContext);

  // モーダルを閉じるための関数
  const closeCreateModal = () => {
    props.setShowCreateModal(false);
  };

  // title が空の場合、submitDisabled は true になる
  const submitDisabled = title.trim() === "";

  // タスク作成のための関数
  const handleCreateTask = () => {
    fetch(createpath, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ title, content, state }),  // 入力されたデータを送信
    }).then(response => {
      if (!response.ok) {
        throw new Error('Task creation failed');
      }
      return response.json();
    }).then(data => {
      console.log('Task created successfully', data);
      
      // タスク作成が成功したことを通知
      alert('Task added successfully!');  // alertを使用して通知

      setTitle('');  // フォームをリセット
      setContent('');
      setState('NotDoTask');
      
      closeCreateModal();  // モーダルを閉じる
      props.onTaskCreated();  // タスク作成後、リストを更新するコールバック関数を呼び出す

    }).catch(error => {
      console.error('Error creating task:', error);
      alert('Failed to add task. Please try again.');  // エラー時の通知もalertを使用
    });
  };

  // "Submit" ボタンをクリックしたときに呼ばれる関数
  const onCreate = () => {
    handleCreateTask();  // タスク作成の関数を実行
  };

  return (
    <>
      {props.showFlag ? (
        <div className={classes.overlay}>
          <div className={classes.modalcontent}>
            <h2>task input here</h2>

            <div className={classes.tasktitle}>
              <p>task title</p>
              <input 
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)} 
              /><br/>
            </div>

            <div className={classes.taskcontent}>
              <p>task content</p>
              <textarea 
                rows="5" 
                value={content}
                onChange={(e) => setContent(e.target.value)}
              ></textarea><br/>
            </div>

            <div className={classes.taskstate}>
              <p>state</p>
              <select 
                value={state}
                onChange={(e) => setState(e.target.value)}
              >
                <option value="InComplete" disabled={props.taskCount >= props.maxTasks}>today task</option>
                <option value="NotDoTask">not do task</option>
              </select><br/>
            </div>

            <button className={classes.cancelbutton} onClick={closeCreateModal}>Cancel</button>
            <button 
              className={classes.submitbutton} 
              onClick={onCreate}
              disabled={submitDisabled}
            >Submit</button>
          </div>
        </div>
      ) : (
        <></>
      )}
    </>
  );
};
