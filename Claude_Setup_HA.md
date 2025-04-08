# Setting Up High Availability for Tableau Server with 2 Nodes

Setting up high availability (HA) for Tableau Server with just 2 nodes requires careful planning to ensure resilience while maintaining performance. Here's how to approach this:

## Basic Architecture for 2-Node HA

1. **Node 1 (Primary)**: Will host the primary instance of critical services
2. **Node 2 (Secondary)**: Will host failover instances of critical services

## Process Distribution Recommendation

### Node 1 (Primary)
- Gateway
- Application Server (VizPortal)
- VizQL Server
- Backgrounder (2-3 instances)
- Data Server
- Data Engine
- File Store (Primary)
- Repository (Primary)
- Coordination Service (Primary)
- Client File Service

### Node 2 (Secondary)
- Gateway
- Application Server (VizPortal)
- VizQL Server
- Backgrounder (2-3 instances)
- Data Server
- Data Engine
- File Store (Secondary)
- Repository (Secondary, in failover mode)
- Coordination Service (Secondary)
- Client File Service

## Implementation Steps

1. Install Tableau Server on Node 1 and configure it as the initial server
2. Add Node 2 to the cluster
3. Configure the Repository for failover
4. Set up the Coordination Service ensemble
5. Configure File Store replication
6. Distribute the remaining processes as recommended

## Additional Considerations

- Ensure both nodes have identical hardware specifications
- Configure external load balancer for the Gateway process
- Set up a shared network location for backups
- Implement monitoring to check the health of both nodes
- Test failover scenarios regularly

For true HA, you would ideally have at least 3 nodes to avoid split-brain scenarios with the Coordination Service, but 2 nodes will provide basic redundancy for most critical services.

# Configuring Repository Failover on Node 2 for Tableau Server

Here's a step-by-step guide to configure the Repository (PostgreSQL database) for failover on Node 2:

1. **Access the TSM Web Interface**:
   - Open a browser and go to https://[Node1Name]:8850
   - Sign in with your TSM administrator credentials

2. **Configure the Repository on Node 2**:
   - Navigate to the "Configuration" tab
   - Click on "Topology" in the left navigation pane
   - Under Node 2, check the box for "Repository"
   - Under the Repository settings, select "Secondary" from the dropdown

3. **Apply the Changes**:
   - Click "Save Pending Changes" in the upper right
   - Click "Apply Changes and Restart"

4. **Verify via Command Line (Alternative Method)**:
   ```bash
   # SSH into Node 1 (primary node)
   ssh [username]@[Node1IP]
   
   # Configure repository on Node 2
   tsm topology set-process -n node2 -pr repository -c 1
   
   # Apply the pending changes
   tsm pending-changes apply
   ```

5. **Verify the Configuration**:
   ```bash
   # Check repository status
   tsm status -v
   
   # Should show repository running on both nodes, with Node 2 in passive mode
   ```

6. **Test Failover**:
   - You can test failover by temporarily stopping the repository on Node 1:
   ```bash
   tsm topology set-process -n node1 -pr repository -c 0
   tsm pending-changes apply
   ```
   - Verify that Node 2's repository becomes active
   - Restore Node 1's repository afterward:
   ```bash
   tsm topology set-process -n node1 -pr repository -c 1
   tsm pending-changes apply
   ```

The repository failover is automatic once properly configured. If the primary repository fails, Tableau Server will automatically switch to using the secondary repository with minimal downtime.

Would you like me to explain how to set up any other components for your 2-node HA configuration?
