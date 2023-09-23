import Foundation
import Matter

let cluster = MTRClusterIDType(rawValue: 29)!
print(cluster)
if MTRClusterIDType.descriptorID == cluster {
    print ("Yay")
} else {
    print ("Nay")
}

print(String(reflecting: cluster))

String(format: "%X", 319486977)
/*
 "Supported Clusters: [29, 31, 40, 42, 48, 49, 51, 53, 60, 62, 63]"
 * MTRClusterIDTypeDescriptorID
 * MTRClusterIDTypeAccessControlID
 * MTRClusterIDTypeBasicInformationID
 * MTRClusterIDTypeOTASoftwareUpdateRequestorID
 * MTRClusterIDTypeGeneralCommissioningID
 * MTRClusterIDTypeNetworkCommissioningID
 * MTRClusterIDTypeGeneralDiagnosticsID
 * MTRClusterIDTypeThreadNetworkDiagnosticsID
 * MTRClusterIDTypeAdministratorCommissioningID
 * MTRClusterIDTypeGroupKeyManagementID
 
 "Supported Endpoints: [1]"
 "Supported Clients: [41]"
 "Reading Endpoint: 1"
 "Supported Clusters: [3, 4, 6, 29, 319486977]"
 * MTRClusterIDTypeIdentifyID
 * MTRClusterIDTypeGroupsID
 * MTRClusterIDTypeOnOffID
 * MTRClusterIDTypeDescriptorID
 * MTRClusterIDTypeUnitTestingID
 "OnOff: 1"
 */
