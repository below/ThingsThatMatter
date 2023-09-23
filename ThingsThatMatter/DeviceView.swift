//
//  DeviceView.swift
//  ThingsThatMatter
//
//  Created by Alexander von Below on 11.09.23.
//

import SwiftUI
import HomeKit
import Matter

struct DeviceView: View {
    let home: HMHome
    let accessory: HMAccessory
    @State var vendorName: String = ""
    @State var lightOn = false
    @State var clusterOnOff: VBBaseClusterOnOff?
    
    var body: some View {
        let mcid = home.matterControllerID
        let controller = MTRDeviceController.sharedController(withID: mcid as NSCopying,
                                                              xpcConnect: home.matterControllerXPCConnectBlock)
        VStack {
            Text("Vendor: \(self.vendorName)")
                .padding()
            Image(systemName: lightOn ? "lightbulb" : "lightbulb.fill")
                .font(.largeTitle)
                .padding()
            Button("Toggle") {
                Task {
                    guard let clusterOnOff = self.clusterOnOff else {
                        return
                    }
                    do {
                        try await clusterOnOff.toggle()
                        self.lightOn = try await clusterOnOff.readAttributeOnOff().boolValue

                    } catch {
                        debugPrint("Error switching light: \(error)")
                    }
                }
            }
            .padding()
        }
            .task {
                    if let nid = accessory.matterNodeID {
                        let baseDevice = MTRBaseDevice(nodeID: NSNumber(value: nid), controller: controller)
                        do {
                            let clusterBasicInformation = VBBaseClusterBasicInformation(
                                baseDevice: baseDevice,
                                endpointID: NSNumber(value: 0))
                            self.vendorName = try await clusterBasicInformation.readAttributeVendorName()
                            print (vendorName)
                            
                            let clusterDescriptor = VBBaseClusterDescriptor(baseDevice: baseDevice, endpointID: NSNumber(value: 0))
                            let servers = try await clusterDescriptor.readAttributeServerList()
                            debugPrint("Supported Clusters: \(servers)")
                            let parts = try await clusterDescriptor.readAttributePartsList()
                            debugPrint("Supported Endpoints: \(parts)")
                            let clients = try await clusterDescriptor.readAttributeClientList()
                            debugPrint("Supported Clients: \(clients)")
                            
                            for endpoint in parts {
                                debugPrint("Reading Endpoint: \(endpoint)")
                                let clusterDescriptor = VBBaseClusterDescriptor(
                                    baseDevice: baseDevice,
                                    endpointID: NSNumber(value: endpoint))
                                let servers = try await clusterDescriptor.readAttributeServerList()
                                debugPrint("Supported Clusters: \(servers)")
                                if servers.contains(UInt64(MTRClusterIDType.onOffID.rawValue)) {
                                    let clusterOnOff = VBBaseClusterOnOff(
                                        baseDevice: baseDevice,
                                        endpointID: NSNumber(value: endpoint))
                                    let value = try await clusterOnOff.readAttributeOnOff()
                                    lightOn = value.boolValue
                                    debugPrint ("OnOff: \(value)")
                                    self.clusterOnOff = clusterOnOff
                                    try await clusterOnOff.toggle()
                                }
                            }
                        } catch {
                            debugPrint ("\(error)")
                        }
                    }
            }
    }
}

//#Preview {
//    DeviceView()
//}

/*
 
 [["attributePath": <MTRAttributePath> endpoint 1 cluster 29 attribute 1, "data": {
    type = Array;
    value =     (
        {
            data =             {
                type = UnsignedInteger;
                value = 3;
                                };
        },
        {
            data =             {
            type = UnsignedInteger;
            value = 4;
                                };
        },
        {
            data =             {
            type = UnsignedInteger;
            value = 6;
                                };
        },
        {
            data =             {
            type = UnsignedInteger;
            value = 29;         // Cluster ID
                                };
        },
        {
            data =             {
            type = UnsignedInteger;
            value = 319486977; // 0x130AFC01
                                };
        }
    );
 }]]
 */
