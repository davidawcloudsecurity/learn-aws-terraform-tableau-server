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

Would you like more specific details about any particular part of this setup process?
