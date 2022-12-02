#1st CRDB Node
docker run -d `
--name=roach1 `
--hostname=roach1 `
--net=roachnet `
-p 26257:26257 -p 8080:8080  `
-v "C:\Raghav\4th_Year\DS_proj/cockroach-data/roach1:/cockroach/cockroach-data"  `
cockroachdb/cockroach:v22.1.10 start `
--insecure `
--join=roach1,roach2,roach3

#2nd CRDB Node
docker run -d `
--name=roach2 `
--hostname=roach2 `
--net=roachnet `
-v "C:\Raghav\4th_Year\DS_proj/cockroach-data/roach2:/cockroach/cockroach-data"  `
cockroachdb/cockroach:v22.1.10 start `
--insecure `
--join=roach1,roach2,roach3

#3rd CRDB Node
docker run -d `
--name=roach3 `
--hostname=roach3 `
--net=roachnet `
-v "C:\Raghav\4th_Year\DS_proj/cockroach-data/roach3:/cockroach/cockroach-data"  `
cockroachdb/cockroach:v22.1.10 start `
--insecure `
--join=roach1,roach2,roach3

#Initializing cluster
docker exec -it roach1 ./cockroach init --insecure

#Starting a sql shell in the first container
docker exec -it roach1 ./cockroach sql --insecure

#Running a sample workload
#For this workload, you run workload init to load the schema and then workload run to generate data.
docker exec -it roach1 ./cockroach workload init movr 'postgresql://root@roach1:26257?sslmode=disable'
docker exec -it roach1 ./cockroach workload run movr 'postgresql://root@roach1:26257?sslmode=disable'

#view performance of the clusters on post 8080 as we had mapped the node's default HTTP port 8080 to 8080 on the host
http://localhost:8080/
#This demonstrates CockroachDB's automated replication of data via the Raft consensus protocol.

#This is the sql part to show the kind of db and tables created
CREATE DATABASE bank;
CREATE TABLE customer(cust_id INT PRIMARY KEY, name STRING, address STRING);
CREATE TABLE accounts(Type STRING, Balance FLOAT, cust_id INT REFERENCES customers (cust_id));


"""
1.Read the sql part of the docs
2.try implementing the transaction bit and to show concurrency in all the clusters

3.were trying to show how transactions work and how it reflects on a distributed cluster

ToDo:
1.Create bank database with 2 tables, one details and other, account -DONE

2.Code up transactions and test DONE
3.Figure out the workflow parameters -DONE

"""
#Transaction code
BEGIN;

## Cash withdrawal ##
#To check if there's balance
SELECT balance >= 5000 FROM accounts WHERE type = 'checking' AND cust_id = 1;
#Actual withdrawal
UPDATE accounts SET balance = balance-5000 WHERE type = 'checking' AND cust_id = 1;
#To retrieve user_id=1's record only
SELECT * FROM accounts WHERE type = 'checking' AND cust_id=1;