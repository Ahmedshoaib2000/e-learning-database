create  database E_Learning
use  E_Learning
create schema users_schema
create table users_schema.learners (
    learner_id int primary key identity(1,1),
    fname varchar(30),
    lname varchar(30),
    email varchar(255) unique,
    password_ varchar(20),
    country varchar(30),
    created_at datetime default getdate()
);
create table users_schema.instructors (
    instructor_id int primary key identity(1,1),
    fname varchar(30),
    lname varchar(30),
    email varchar(255) unique,
    password_ varchar(20),
    qualification varchar(255),
    created_at datetime default getdate()
);

create table users_schema.admins (
    admin_id int primary key identity(1,1),
    fname varchar(30),
    lname varchar(30),
    email varchar(255) unique,
    password_ varchar(20),
    role varchar(50) check (role in ('superadmin', 'supportadmin', 'contentadmin')),
    created_at datetime default getdate()
);

create schema course_schema;

create table course_schema.course (
    course_id int primary key identity(1,1),
    c_name varchar(110) not null,
    c_description varchar(500),
    category varchar(100) not null,
    created_at datetime default getdate(),
    instructor_id int,
    constraint course_mange_fk foreign key (instructor_id) references users_schema.instructors(instructor_id)
);

create table course_schema.course_content (
    content_id int primary key identity(1,1),
    content_type varchar(45) check (content_type in ('video', 'pdf', 'quiz', 'text')),
    created_at datetime default getdate(),
    content_url varchar(100),
    course_id int,
    constraint course_content_fk foreign key (course_id) references course_schema.course(course_id)
);

create schema enrollment_schema;

create table enrollment_schema.enrollment (
    enrollment_id int primary key identity(1,1),
    learner_id int,
    course_id int,
    progress decimal(5,2) default (0.00),
    enrollment_date datetime default getdate(),
    constraint course_enrollment_fk foreign key (course_id) references course_schema.course(course_id),
    constraint learner_enrollment_fk foreign key (learner_id) references users_schema.learners(learner_id)
);

alter table enrollment_schema.enrollment
add constraint unique_learnercourse unique (learner_id, course_id);

create schema evaluation;

create table evaluation.quizze (
    quizze_id int primary key identity(1,1),
    course_id int,
    title varchar(75) not null,
    constraint course_quizze_fk foreign key (course_id) references course_schema.course(course_id)
);

create table evaluation.quizzequestions (
    question_id int primary key identity(1,1),
    quizze_id int,
    correct_answer varchar(255),
    question_text varchar(500),
    constraint question_quizze_fk foreign key (quizze_id) references evaluation.quizze(quizze_id)
);

create table evaluation.answers (
    answer_id int primary key identity(1,1),
    learner_id int,
    question_id int,
    selected_answer varchar(255),
    is_correct bit check (is_correct in (1, 0)),
    constraint learner_answers_fk foreign key (learner_id) references users_schema.learners(learner_id),
    constraint question_answers_fk foreign key (question_id) references evaluation.quizzequestions(question_id)
);

create schema feedback_schema;

create table feedback_schema.feedback (
    feedback_id int primary key identity(1,1),
    learner_id int,
    course_id int,
    comments varchar(300),
    rating int check (rating between 1 and 5),
    created_at datetime default getdate(),
    constraint learner_feedback_fk foreign key (learner_id) references users_schema.learners(learner_id),
    constraint course_feedback_fk foreign key (course_id) references course_schema.course(course_id)
);

create schema certification_schema;

create table certification_schema.certification (
    certification_id int primary key identity(1,1),
    learner_id int,
    course_id int,
    date_of_acquisition datetime default getdate(),
    constraint learner_certification_fk foreign key (learner_id) references users_schema.learners(learner_id),
    constraint course_certification_fk foreign key (course_id) references course_schema.course(course_id)
);

create schema support_schema;

create table support_schema.support (
    support_id int primary key identity(1,1),
    admin_id int,
    user_id int,
    support_message varchar(500),
    response varchar(500) not null,
    status varchar(20) default 'open' check (status in ('open', 'resolved')),
    constraint user_support_fk foreign key (user_id) references users_schema.learners(learner_id),
    constraint admin_support_fk foreign key (admin_id) references users_schema.admins(admin_id)
);

