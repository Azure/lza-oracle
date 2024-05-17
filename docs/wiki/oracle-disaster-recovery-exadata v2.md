---
title: Business continuity and disaster recovery (BCDR) for Oracle Database@Azure
description: Learn about continuity and disaster recovery (BCDR) for Oracle Database@Azure.
author: jfaurskov
ms.author: janfaurs,jsilver
ms.date: 12/20/2023
ms.topic: conceptual
ms.custom: 
  - think-tank
  - e2e-oracle
  - engagement-fy24
  - version: 2
--- 


# Business continuity and disaster recovery (BCDR) for Oracle Database@Azure

This article builds on the considerations and recommendations that are defined in the [Azure landing zone design area for BCDR](../../ready/landing-zone/design-area/management-business-continuity-disaster-recovery.md). 


The first step to building a resilient architecture for your workload environment is to determine availability requirements for your solution by identifying the recovery time objective (RTO) and recovery point objective (RPO) for different levels of failure, in addition to planned maintenance events. RTO is the maximum downtime time an application can tolerate to be unavailable after an incident and RPO is the maximum amount of data loss than can be tolerated due to a disaster. After you determine the requirements for your solution, the next step is to design your architecture to meet your RTO and RPO objectives. 

## Design Considerations

- Oracle Exadata Database Service on Dedicated Infrastructure with Oracle Database@Azure is colocated in Azure datacenters and placed in an Azure availability zone. In light of this, it is important to remember that availability zones are specific to a subscription, i.e., availability zone 1 is not necessarily the same physical datacenter in one subscription as availability zone 1 in another. This is described in more detail in  [What are availability zones](/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones)
- Oracle Database@Azure provides Oracle Exadata and Oracle Real Application Clusters (RAC) for ensuring out-of-the-box high availability, scalability, and extreme performance. Customers can leverage automated Oracle [Data Guard](https://www.oracle.com/database/data-guard/) deployments for data protection and disaster recovery. Additionally, Oracle [GoldenGate](https://www.oracle.com/integration/goldengate/) can be used for data replication and active-active deployments.
- Oracle Database@Azure resources are contained within individual zones of the chosen region during deployment, allowing for resilient deployments even when a single region is use.
- Oracle Database@Azure integrates automatic database backups to redundant OCI Object Storage. Oracle’s Autonomous Recovery Service is available and provides exceptional protection for Oracle Databases deployed on Exadata.


## Design Recommendations

### Cross-AZs, same region

For high availability and disaster recovery protection from database, database cluster, or entire availability zone (AZ) failure, leverage Oracle RAC on ExaDB-D and a recommended symmetric standby database located in another AZ. This configuration will enable you to achieve data center resiliency for database services. Application services dependent on the database, these should be in the same availability zone as the database services for best performance. This architectural approach is particularly relevant if the application services are in a different subscription than the database services. If that is the case, you should leverage the code found in [What are availability zones](https://learn.microsoft.com/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones) and, from the availabilityZoneMappings property, determine the physical availability zone where the services should be co-located.


- The above ExaDB-D without standby database corresponds to the Silver level of the [Oracle MAA Reference Architectures](https://docs.oracle.com/en/database/oracle/oracle-database/19/haiad/) with Oracle RAC for HA and the Gold level of the [Oracle MAA Reference Architectures](https://docs.oracle.com/en/database/oracle/oracle-database/19/haiad/) if Data Guard or Active Data Guard is leveraged to protect from localized disasters.
- When configuring Data Guard for comprehensive production database protection, you can configure Data Guard in Maximum Availability mode with SYNC transport to enable zero data loss failover, or Max Performance mode with ASYNC transport to enable zero application impact and near zero data loss.


### Cross-Regions
Resiliency for application services should be ensured through other means such as Virtual Machine Scale Sets, Azure Site Recovery, Azure Front Door, or other features that enable application service availability across availability zones or regions.


  - For regional disaster recovery, based on your application capabilities, and depending on the network latency between regions, you can configure Data Guard with maximum performance mode. For more details on network latency between regions, see [Azure Network Latency Test Results](https://learn.microsoft.com/azure/networking/azure-network-latency).
  - If you decide on regional disaster recovery, you must instantiate an additional Oracle Database@Azure Exadata Infrastructure in the target region.
  - The above combination of configurations aligns with the "Gold" level of the [Oracle MAA Reference Architectures](https://docs.oracle.com/en/database/oracle/oracle-database/19/haiad/). This Gold MAA architecture provides additional disaster recovery protection from a complete regional failure. 


For backup of databases, it is recommended to leverage managed backups, storing backup data to OCI Object Storage. 

## Additional Considerations

- Use Infrastructure-as-Code to deploy the initial Oracle Database@Azure instance and VM Clusters. This will enable you to easily replicate the same deployment to a disaster recovery site and minimize the risk of human errors.
- Use Infrastructure-as-Code to deploy databases in Oracle Cloud Infrastructure. This will enable you to easily replicate the same deployment and will minimize the risk of human errors.
- Test failover and switchback operations to ensure that you can execute them in a real disaster scenario. Automate failover and switchback operations as much as possible to minimize the risk of human errors.

## Next steps

### Oracle Maximum Availability Architecture for Oracle Database@Azure

[Oracle Database@Azure Evaluations by Oracle MAA](https://docs.oracle.com/en/database/oracle/oracle-database/19/haovw/db-azure1.html#GUID-91572193-DF8E-4D7A-AF65-7A803B89E840)
