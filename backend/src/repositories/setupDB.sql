-- マイグレーションのアップ用（適用）
create table if not exists task (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    contents TEXT,
    task_state ENUM('InComplete', 'Finished','NotDoTask') DEFAULT 'NotDoTask',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

insert into task (title, contents,task_state, created_at) values 

    ('firstTask', 'This is my first task@mysql',"InComplete", now());

insert into task (title, contents,task_state, created_at) values 

    ('SecondTask', 'This is my second task',"Finished", now());

insert into task (title, contents,task_state, created_at) values 

    ('ThirdTask', 'This is my third task',"NotDoTask", now());