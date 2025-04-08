For a **high availability (HA) Tableau Server cluster**, the minimum specifications depend on node roles. While Tableau officially recommends three nodes for true HA, here are the hardware requirements for a functional HA-capable setup:  

---

### **Minimum Specifications per Node**  
| **Component**         | **Initial Node**                | **Additional Nodes**           |  
|------------------------|----------------------------------|---------------------------------|  
| **CPU**               | 8 physical cores (16 vCPUs)[1][3] | 4 physical cores (8 vCPUs)[1][5] |  
| **RAM**               | 128 GB[3]                      | 16 GB (Prep Conductor)[1][5]   |  
| **Storage**           | 50 GB (OS) + 500 GB+ (data)[3][7] | 100 GB (dedicated nodes)[5]   |  
| **OS**                | Windows/Linux (x64)[3][7]      | Same as initial node           |  

---

### **HA-Specific Requirements**  
1. **Three-Node Minimum**  
   - **Coordination Service**: Requires ≥3 nodes for quorum and automatic failover[6][8].  
   - **Repository**: Requires a primary and standby instance across nodes[4][6].  

2. **Prep Conductor Dedication**  
   - A dedicated node for Prep Conductor requires **4 physical cores, 16 GB RAM**[1][5].  

3. **Virtualization Guidelines**  
   - Use **dedicated CPU affinity** (no resource sharing)[2].  
   - Allocate vCPUs as **2:1 ratio** (e.g., 16 vCPUs = 8 physical cores)[1][2].  

---

### **Critical Notes**  
- **Two-node clusters lack HA**: Cannot host redundant repositories or Coordination Service[6][8].  
- **Resource Monitoring Tool (RMT)**: Requires a separate server (8 cores, 64 GB RAM) for deployments >10k views/hour[3].  
- **Enterprise deployments**: Contact Tableau for tailored guidance[1][5].  

For true HA, prioritize three nodes with the above specifications and dedicated roles.

Citations:
[1] https://help.tableau.com/current/server/en-us/server_baseline_config.htm
[2] https://viziblydiffrnt.wordpress.com/2016/07/21/choosing-a-tableau-server-architecture/
[3] https://www.tableau.com/products/techspecs
[4] https://hevodata.com/learn/tableau-high-availability/
[5] https://help.tableau.com/current/server/en-us/server-upgrade-prepare-min-HW-recommendations.htm
[6] https://help.tableau.com/current/server/en-us/distrib_ha_install_3node.htm
[7] https://help.tableau.com/current/server-linux/en-us/server_hardware_min.htm
[8] https://help.tableau.com/current/server/en-us/server_hardware_min.htm

---
Answer from Perplexity: pplx.ai/share
