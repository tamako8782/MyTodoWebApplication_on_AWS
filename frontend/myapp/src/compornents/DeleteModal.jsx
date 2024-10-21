//import React, { useState } from "react";
import classes from "./Modalstyle.module.scss";

export const DeleteModal = (props) => {
  const { task, onTaskDeleted, detailpath,setShowDeleteModal } = props; // タスクデータと削除後の処理
  

  // Detailモーダルを閉じる
  const closeDetailModal = () => {
    props.setShowDetailModal(false);
  };

  // 削除確認モーダルを閉じる
  const closeDeleteModal = () => {
    setShowDeleteModal(false);
  };

  // タスク削除処理
  const handleDeleteTask = () => {
    const deletepath = `${detailpath}/${task.id}/delete`;

    fetch(deletepath, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Task delete failed.");
        }
        return response.json();
      })
      .then((deleteResult) => {
        if (deleteResult) {
          console.log("Task deleted successfully", deleteResult);
          alert("Task deleted successfully!");

          onTaskDeleted(); // 削除後、タスクリストを更新
          closeDetailModal(); // Detailモーダルを閉じる
          closeDeleteModal();
        } else {
          console.error("Task deletion failed.");
          alert("Failed to delete task.");
        }
      })
      .catch((error) => {
        console.error("Error deleting task:", error);
        alert("Failed to delete task.");
      });
  };

  return (
    <>
      {props.showFlag ? (
              <div className={classes.deleteOverlay}>
              <div className={classes.deleteModalContent}>
                <h2>Confirm Delete</h2>
                <p>Are you sure you want to delete the task "{props.task.title}"?</p>
                <div className={classes.buttonGroup}>
                  <button className={classes.yesButton} onClick={handleDeleteTask}>
                    Yes
                  </button>
                  <button className={classes.noButton} onClick={closeDeleteModal}>
                    No
                  </button>
                </div>
              </div>
            </div>

      ) : null}
    </>
  );
};
