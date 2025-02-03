import os
import time
from bottle import Bottle, run, response, request
import docker
import json
import threading
# import psycopg2
# from psycopg2.extras import RealDictCursor

dockerClient = docker.from_env()

app = Bottle()

# pgConn = psycopg2.connect(
#   host="127.0.0.1",
#   dbname="nanolocksec",
#   user="nanolocksec",
#   password="nanolocksec",
#   cursor_factory=RealDictCursor
# )

@app.hook('after_request')
def enable_cors():
    origin_url = os.getenv('MONITORING_CORS_URL')
    response.headers['Access-Control-Allow-Origin'] = origin_url
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'PUT, GET, POST, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'

dockerContainersStatus = {}

def getDockerContainersStatus ():
  di = {}
  try :
    for container in dockerClient.containers.list(all=True):
      state = container.stats(stream=False)

      containerCpuTotalUsagePercent = 0.0
      if container.status != 'exited' :
        cpuCount = len(state["cpu_stats"]["cpu_usage"].get("percpu_usage", ['']))
        print(1)
        containerCpuTotalUsage =  float(state["cpu_stats"]["cpu_usage"]["total_usage"])
        print(2)
        containerPreCpuTotalUsage = float(state["precpu_stats"]["cpu_usage"]["total_usage"])
        print(3)
        containerCpuUsageDelta =  containerCpuTotalUsage - containerPreCpuTotalUsage
        print(4)
      
        systemCpuTotalUsage =  float(state["cpu_stats"]["system_cpu_usage"])
        print(5)
        systemPreCpuTotalUsage =  float(state["precpu_stats"]["system_cpu_usage"])
        print(6)
        systemCpuUsageDelta = systemCpuTotalUsage -systemPreCpuTotalUsage
        print(7)

        containerCpuTotalUsagePercent  = containerCpuUsageDelta / systemCpuUsageDelta * 100.0 * cpuCount  if systemCpuUsageDelta > 0.0 else 0.0
        print(8)

      containerMemoryTotalUsagePercent = 0.0
      print(9)
      if container.status != 'exited' :
        print(10)
        containerMemoryTotalUsagePercent  = (state["memory_stats"]["usage"] / state["memory_stats"]["limit"]) * 100

      nameForVersion = container.name.replace("-","_").upper() + "_TAG"

      di[container.name] = {
      "status": container.status,
      "version": os.getenv(nameForVersion),
      "usage": {
        "cpu":  containerCpuTotalUsagePercent,
        "memory": containerMemoryTotalUsagePercent
      }
    }
    print(11)

  except :
    print("Failed to calculate cpu and memory")
    print(Exception) 

  return di

def getDockerContainersStatusLoop():
  while(1):
    global dockerContainersStatus
    dockerContainersStatus = getDockerContainersStatus()
    time.sleep(0.200)

@app.get('/container/StatusLive')
def getDockerStatus():
  return json.dumps(getDockerContainersStatus())

@app.get('/container/Status')
@app.get('/continuersStatus')
def getDockerStatusLooped():
  return json.dumps(dockerContainersStatus)

dockerStatusLoopThread = threading.Thread(target = getDockerContainersStatusLoop)
dockerStatusLoopThread.start()

# @app.get('/db/SessionStatus')
# def getPostgresSessionStatus():
#   cur = pgConn.cursor()
#   cur.execute(
#     """
#       SELECT 'session_stats' AS chart_name, pg_catalog.row_to_json(t) AS chart_data
#       FROM (SELECT
#         (SELECT count(*) FROM pg_catalog.pg_stat_activity) AS "Total",
#         (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = 'active')  AS "Active",
#         (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = 'idle')  AS "Idle"
#       ) t;
#     """
#   )
#   sessionStatus = cur.fetchone()

#   return json.dumps({"SessionStatus": sessionStatus['chart_data']})

# @app.get('/db/Transaction')
# def getPostgresTransaction():
#   cur = pgConn.cursor()
#   cur.execute(
#     """
#       SELECT sum(xact_commit) + sum(xact_rollback) as transaction FROM pg_catalog.pg_stat_database
#     """
#   )
#   transactionStatus = cur.fetchone()
#   return int(transactionStatus['transaction'])


# @app.get('/db/MasterSlaveData')
# def getPostgresMasterAndSlaveData():
#   cur = pgConn.cursor()
  
#   cur.execute(
#     """
#       select * from pg_stat_replication;
#     """
#   )
#   # at this moment in time there is always just one slave so we can use .fetchone()
#   slave = cur.fetchone()
  
#   cur.execute(
#     """
#       select * from pg_stat_wal_receiver;
#     """
#   )
#   master = cur.fetchone()

#   role = ""
#   data = {}

#   if master == None:
#     role = "master"
#     data = {"slave": {
#       "ip": slave["client_addr"],
#       "port": slave["client_port"],
#       "status": slave["state"]
#     }}
#   else : 
#     role = "slave"
#     data = {"master": {
#       "ip": master["sender_host"],
#       "port": master["sender_port"],
#       "status": master["status"]
#     }},


#   return json.dumps({"role":role,"data":data})

run(app, host='0.0.0.0', port=8082)

