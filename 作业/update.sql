use mysql;
delete from user where user='';
create database bbs;
grant all on bbs.* to runbbs@'%' identified by 'uplooking';
flush privileges;
