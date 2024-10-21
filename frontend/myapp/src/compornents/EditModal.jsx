import React, { useState, useEffect } from "react";
import classes from "./Modalstyle.module.scss";

export const EditModal = (props) => {
  const { task, onTaskUpdated,detailpath } = props; // タスクデータと更新後の処理
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [state, setState] = useState("");

  // 初期値として、選択されたタスクのデータを設定
  useEffect(() => {
    if (task) {
      setTitle(task.title);
      setContent(task.content); // task.content に修正
      setState(task.state);
    }
  }, [task]);

  const closeEditModal = () => {
    props.setShowEditModal(false);
  };

  const handleUpdateTask = () => {
    const updatepath = `${detailpath}/${task.id}/update`;
    console.log(updatepath);

    fetch(updatepath, {
      method: "PATCH", // PATCHメソッドを使用して部分更新
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        title,
        content,
        state,
      }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Task update failed.");
        }
        return response.json();
      })
      .then((data) => {
        console.log("Task updated successfully", data);
        alert("Task updated successfully!");

        onTaskUpdated(); // 更新後、タスクリストを更新する
        closeEditModal(); // モーダルを閉じる
      })
      .catch((error) => {
        console.error("Error updating task:", error);
        alert("Failed to update task.");
      });
  };

  return (
    <>
      {props.showFlag ? (
        <div className={classes.overlay}>
          <div className={classes.modalcontent}>
            <h2>Edit Task</h2>

            <div className={classes.tasktitle}>
              <p>Task Title</p>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
              />
              <br />
            </div>

            <div className={classes.taskcontent}>
              <p>Task Content</p>
              <textarea
                rows="10"
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />
              <br />
            </div>

            <div className={classes.taskstate}>
              <p>State</p>
              <select
                value={state}
                onChange={(e) => setState(e.target.value)}
              >
                <option value="InComplete" disabled={props.taskCount >= props.maxTasks}>Today Task</option>
                <option value="NotDoTask">Not Do Task</option>
              </select>
              <br />
            </div>

            <button className={classes.cancelbutton} onClick={closeEditModal}>Cancel</button>
            <button className={classes.submitbutton} onClick={handleUpdateTask}>Submit</button>
          </div>
        </div>
      ) : null}
    </>
  );
};
