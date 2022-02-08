# PIC rucio server deployment on k8s
Rucio is a data lake orchestrator developed by CERN. It maintains a database of where data is located in attached Rucio Storage Elements (RSEs) and, through a suite of daemons, monitors and updates the state of the data lake according to user requests. In addition to upload and deletion of data, Rucio brokers data transfers between sites.


## Rucio Deployment

### Prerequisites
- Machines to use for K8s cluster head and worker nodes with sudo access
- A robot certificate

### Setup


