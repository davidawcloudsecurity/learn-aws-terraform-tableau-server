### Deepseek for 2 node
To set up a High Availability (HA) configuration for Tableau Server with two nodes, you must address critical components like the **Repository** (PostgreSQL) and **Coordination Service** (Zookeeper). While Tableau officially recommends at least three nodes for HA, a two-node setup can achieve partial redundancy with trade-offs. Here's a step-by-step guide:

---

### **Key Components & Considerations**
1. **Repository (PostgreSQL)**:  
   The metadata database is a single point of failure. Use an **external PostgreSQL HA cluster** (e.g., streaming replication, Patroni, or pgPool) across both nodes to ensure failover.
   
2. **Coordination Service**:  
   Requires an **odd number of nodes** for quorum. With two nodes, use a **3-node Zookeeper ensemble** (e.g., deploy a lightweight third "observer" node or a cloud-based witness) to avoid split-brain scenarios. If not possible, accept that node failures may disrupt coordination.

3. **Shared Processes**:  
   Distribute stateless processes across both nodes for redundancy:
   - **Gateway** (reverse proxy)
   - **VizQL Server** (renders views)
   - **Application Server** (API/UI)
   - **Backgrounder** (scheduled tasks)
   - **Cache Server** (caches queries)
   - **Data Server** (metadata management)

---

### **Setup Steps**
1. **Deploy External PostgreSQL HA**:
   - Configure streaming replication between Node 1 (primary) and Node 2 (standby).
   - Use tools like `pg_auto_failover` or `repmgr` for automated failover.
   - Point Tableau Server to the PostgreSQL cluster’s virtual IP or DNS.

2. **Install Tableau Server on Both Nodes**:
   - Use the same version and configuration on both nodes.
   - During installation, specify the external PostgreSQL cluster as the repository.

3. **Configure Coordination Service**:
   - If possible, add a lightweight third node (e.g., cloud instance) to form a 3-node Zookeeper ensemble.
   - If not, deploy Zookeeper on both nodes and accept quorum risks during failures.

4. **Distribute Processes**:
   - Use `tsm topology` commands to spread processes across both nodes. Example:
     ```bash
     tsm topology set-process -n node1 --process gateway,vizql,application
     tsm topology set-process -n node2 --process gateway,vizql,application
     ```
   - Ensure redundant Backgrounders for task continuity.

5. **Load Balancing**:
   - Use a load balancer (e.g., NGINX, HAProxy) to distribute traffic to both Gateway processes.
   - Configure health checks to route traffic away from failed nodes.

6. **Test Failover**:
   - Simulate node failures to validate PostgreSQL failover and process redistribution.
   - Monitor Tableau Server logs (`tsm logs`) for errors.

---

### **Limitations**
- **Coordination Service**: Two-node Zookeeper lacks quorum; failures may cause service unavailability.
- **Manual Intervention**: PostgreSQL failover might require manual steps if automation isn’t configured.
- **Unsupported Configuration**: Tableau officially requires ≥3 nodes for HA. This setup may not qualify for support.

---

### **Recommended Architecture**
```
               [Load Balancer]
                /           \
        [Node 1]           [Node 2]
        |- Gateway          |- Gateway
        |- VizQL            |- VizQL
        |- Application       |- Application
        |- Backgrounder      |- Backgrounder
        |- PostgreSQL (Primary) |- PostgreSQL (Standby)
        |- Zookeeper        |- Zookeeper
```

For production environments, **use three nodes** to meet Tableau’s HA requirements. Reserve two-node setups for non-critical workloads where partial downtime is acceptable.
