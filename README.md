# ConcurrencyErlang
__The problem:__
In an emergency department facility in a hospital, patients arrive without prior appointment. They are sent to triage to determine
their priority. There are 3 types of priority, 1, 2 and 3. Patients with priority 3 are considered more urgent and are seen before
patients with priority 2 or 1 even if they arrived first and patients with priority 2 are seen before patients with priority 1.
Thid Erlang-based application simulates this process. Implement:
One process for the triage.
A central process to store waiting patients and their priority.
One processes for health providers that will see these patients removing them from the central process queue.

__Designing the solution:__
Using ETS (Erlang Term Storage) which is a built-in application that allows developers to create ram based key-value storage objects.
i created a shared table between the process. they are all able to access it for read and write. 

__How to run the hospitalV4?__
1. compiling the erlang file
     ```c("hospitalV4").```
2. run the start_hospital:
    ```hospitalV4:start_hospital().```
3. call the add_patient to add new patient 
    ```hospitalV4:addPatient("wewewa","broken arm").```
    
