import React from "react";
import classes from "./Modalstyle.module.scss";

export const DetailModal = (props) => {
  const closeDetailModal = () => {
    props.setShowDetailModal(false);
  };


  return (
    <>
      {props.showFlag ? (
        <div className={classes.overlay}>
          <div className={classes.modalcontent}>
            <h2>detail task</h2>
            <div className={classes.detailtasks}>
              <ul>
                <li>title</li>
                <p>{props.task.title}</p>
                <li>content</li>
                <p>{props.task.content}</p>
                <li>state</li>
                <p>{props.task.state}</p>
                <li>create at</li>
                <p>{props.task.created_at}</p>
                <li>update at</li>
                <p>{props.task.updated_at}</p>
              </ul>
            </div>
            <button className={classes.cancelbutton} onClick={closeDetailModal}>cancel</button>
            <button className={classes.deletebutton} onClick={props.onDelete}>delete</button> 
            <button className={classes.editbutton} onClick={props.onEdit}>edit</button> 
          </div>
        </div>
      ) : null}
    </>
  );
};
