// Online Examination System - OS Concepts Demo
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define STUDENTS 5

pthread_mutex_t lock;
int submitted_answers = 0;

// Critical Section
void submit_answer(int id)
{
    pthread_mutex_lock(&lock);

    printf("Student %d is submitting answers...\n", id);

    submitted_answers++;
    FILE *log = fopen("exam_log.txt", "a");
    fprintf(log, "Student %d submitted answers.\n", id);
    fclose(log);

    printf("Submission Recorded. Total = %d\n", submitted_answers);

    pthread_mutex_unlock(&lock);
}

void *student_session(void *arg)
{
    int id = *(int *)arg;

    printf("Student %d started exam session.\n", id);

    sleep(rand() % 3 + 1);

    submit_answer(id);

    printf("Student %d completed exam.\n", id);

    pthread_exit(NULL);
}

int main()
{
    pthread_t students[STUDENTS];
    int ids[STUDENTS];

    pthread_mutex_init(&lock, NULL);

    printf("=== ONLINE EXAMINATION SYSTEM ===\n");

    for(int i = 0; i < STUDENTS; i++)
    {
        ids[i] = i + 1;
        pthread_create(&students[i], NULL,
                       student_session, &ids[i]);
    }

    for(int i = 0; i < STUDENTS; i++)
    {
        pthread_join(students[i], NULL);
    }

    printf("\nAll submissions completed.\n");
    printf("Total Answers Submitted = %d\n", submitted_answers);

    pthread_mutex_destroy(&lock);

    return 0;
}