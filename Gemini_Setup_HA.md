Okay, let's break down how to set up a Tableau Server configuration with two nodes for increased availability and which processes should be duplicated or shared across them.

**Important Caveat: True High Availability (HA) vs. Redundancy**

* **True HA:** Tableau Server's standard HA configuration, especially for critical stateful components like the Repository (database) and Coordination Service (Zookeeper), typically requires a minimum of **three nodes**. This is mainly because the Coordination Service needs a "quorum" (a majority) to operate reliably during failures, which isn't possible with only two nodes.
* **Two-Node Redundancy:** With two nodes, you can achieve *redundancy* for many processes, meaning if one node fails, the other node *might* be able to handle the workload (though potentially with degraded performance). However, failover for the Repository will likely be **manual**, and the Coordination Service remains a potential single point of failure if configured inappropriately.

**Two-Node Configuration Strategy**

The goal is to distribute processes so that if one node goes down, essential services continue running on the remaining node.

**Node 1 (Initial Node):**

1.  Install Tableau Server here first.
2.  This node typically runs the primary instance of services that cannot or should not be run active-active across only two nodes, along with redundant copies of other services.
3.  Hosts the **Licensing Service** (only runs on one node).
4.  Hosts the **TSM Controller** (primary).
5.  Hosts the **Active Repository** (PostgreSQL database).
6.  **Crucially, hosts the File Store.**
7.  Hosts instances of Gateway, Application Server (VizPortal), VizQL Server, Cache Server, Backgrounder, Data Server.
8.  **Coordination Service:** *See discussion below.*

**Node 2 (Additional Node):**

1.  Install the Tableau Server Worker software here.
2.  Add this node to the cluster using TSM (Tableau Services Manager).
3.  This node hosts redundant instances of processes and the passive/failover components.
4.  Hosts the **TSM Agent**.
5.  Hosts the **Passive Repository** (if configured for manual failover).
6.  **Crucially, hosts the File Store.** (File Store *must* run on all nodes running Data Engine or VizQL Server, and for redundancy, you want it on both).
7.  Hosts additional instances of Gateway, Application Server (VizPortal), VizQL Server, Cache Server, Backgrounder, Data Server.

**Which Processes Should Be "Shared" (Duplicated for Redundancy) across Both Nodes?**

These are the key processes you should configure to run on *both* Node 1 and Node 2:

1.  **Gateway:** Handles requests and routes them to appropriate Tableau processes. Running on both nodes allows a load balancer (required for HA/redundancy) to direct traffic to the active node if one fails.
2.  **Application Server (VizPortal):** Handles Browse, searching, web authoring, and user authentication. Running on both provides UI redundancy.
3.  **VizQL Server:** Renders views and handles user interactions. Multiple instances across both nodes improve capacity and provide redundancy.
4.  **Cache Server:** Stores cached query results. Distributing this helps performance and provides some cache redundancy.
5.  **Backgrounder:** Executes server tasks like extract refreshes, subscriptions, etc. Running instances on both nodes ensures these tasks can continue (or be picked up) if one node fails.
6.  **Data Server:** Manages connections to Tableau data sources. Running on both provides redundancy.
7.  **File Store:** ***Essential***. The File Store manages Tableau Extracts (.hyper files). If you want extracts to be available when one node is down, you *must* have the File Store process running on both nodes. Tableau automatically replicates extracts between File Store instances.

**Processes Requiring Special Handling in a 2-Node Setup:**

1.  **Repository (PostgreSQL):**
    * You cannot have an automatic failover configuration with only two nodes.
    * **Configuration:** Configure an *active* Repository on Node 1 and a *passive* Repository on Node 2.
    * **Failover:** If Node 1 fails, the Repository on Node 2 **does not** automatically become active. You must **manually** promote the passive Repository on Node 2 to active using TSM commands (`tsm topology failover-repository`). This means downtime while you perform the manual failover.
2.  **Coordination Service (Apache ZooKeeper):**
    * This service manages cluster coordination, leader election for the Repository, and configuration consistency.
    * It requires a quorum (majority) to function correctly during failures. With 2 nodes, a quorum isn't possible ( (2/2)+1 = 2, meaning both nodes must be up).
    * **Recommendation:** In a 2-node setup, it's often recommended to run **only a single instance** of the Coordination Service (usually on the initial node). Adding a second instance doesn't create a fault-tolerant ensemble and can cause issues.
    * **Implication:** If the node running the single Coordination Service instance fails, the entire Tableau Server cluster may become unavailable or enter a degraded state until that node is recovered or the service is manually reconfigured. This is a significant limitation of the 2-node approach.
3.  **Licensing Service:** Runs on only one node (usually the initial node). If that node fails, licensing checks might eventually fail, but the server often continues to operate for a grace period.
4.  **Cluster Controller:** Runs on every node, manages service states.
5.  **TSM Controller & Agent:** Controller runs on the initial node, Agent runs on additional nodes.

**High-Level Setup Steps:**

1.  **Prepare Nodes:** Ensure both servers meet Tableau Server requirements (OS, hardware, network configuration, firewall ports open).
2.  **Install Tableau Server:** Install on Node 1.
3.  **Initialize TSM:** Initialize Tableau Server on Node 1 (`tsm initialize`).
4.  **Activate and Register:** Activate your Tableau Server license.
5.  **Configure Initial Node Processes:** Set up the initial process configuration (TSM UI or command line).
6.  **Install Worker Software:** Install the worker software package on Node 2.
7.  **Generate Node Bootstrap File:** On Node 1, generate a bootstrap file (`tsm topology nodes get-bootstrap-file --file <bootstrap-file.json>`).
8.  **Add Node 2:** Copy the bootstrap file to Node 2 and run the `initialize-worker` script using the bootstrap file. This joins Node 2 to the cluster.
9.  **Configure Process Distribution:** Use TSM (`tsm topology set-process...`) to add instances of Gateway, VizQL, Backgrounder, etc., to Node 2. Configure the passive Repository on Node 2. Ensure File Store is configured on both nodes. *Do not* add a second Coordination Service instance unless specifically instructed by Tableau Support for a niche scenario (generally not recommended).
10. **Apply Pending Changes:** (`tsm pending-changes apply`). This restarts Tableau Server with the new topology.
11. **Configure Load Balancer:** Set up an external load balancer to distribute traffic across the Gateway processes on both Node 1 and Node 2. Configure health checks.
12. **Test Failover:** Simulate node failures (shut down one node) and test:
    * Can users still access Tableau via the load balancer URL?
    * Do Backgrounder tasks continue?
    * Manually test the Repository failover process (`tsm topology failover-repository`) and verify functionality. Test failing back.

**Summary:**

A 2-node Tableau Server setup provides **redundancy** for most stateless processes (Gateway, VizQL, Backgrounder, etc.) and the File Store if configured correctly. However, it falls short of true automatic HA primarily because the Repository requires **manual failover**, and the Coordination Service remains a **single point of failure**. For full, automated HA, a minimum of three nodes is strongly recommended by Tableau.
