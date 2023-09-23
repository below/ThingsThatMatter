//
//  VBBaseClusters.swift
//  ThingsThatMatter
//
//  Created by Alexander von Below on 18.09.23.
//

import Foundation
import Matter

class VBBaseCluster {
    let baseDevice: MTRBaseDevice
    let endpointID: NSNumber
    
    init(baseDevice: MTRBaseDevice, endpointID: NSNumber) {
        self.baseDevice = baseDevice
        self.endpointID = endpointID
    }
}

enum VBClusterError: Error {
    case parseError
    case illegalArgument
}

class VBBaseClusterDescriptor: VBBaseCluster {
    
    func UInt64Array(from attributes: [[String: Any]]) throws -> [UInt64] {
        var result = [UInt64]()
        guard attributes.count >= 1 else {
            throw VBClusterError.illegalArgument
        }
        if let data = attributes[0]["data"] as? NSDictionary {
            if let array = data["value"] as? [NSDictionary] {
                result = array.compactMap { element -> UInt64? in
                    if let data = element["data"] as? NSDictionary, let value = data["value"] as? UInt64 {
                        return value
                    } else {
                        return nil
                    }
                }
            }
        }
        guard result.count > 0 else {
            throw VBClusterError.parseError
        }
        return result
    }
    
    func readAttributeServerList() async throws -> [UInt64] {
        let attributes = try await baseDevice.readAttributes(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.descriptorID.rawValue),
            attributeID: NSNumber(value: MTRAttributeIDType.clusterDescriptorAttributeServerListID.rawValue),
            params: nil,
            queue: .main)
        return try UInt64Array(from: attributes)
    }
    
    func readAttributeClientList() async throws -> [UInt64] {
        let attributes = try await baseDevice.readAttributes(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.descriptorID.rawValue),
            attributeID: NSNumber(value: MTRAttributeIDType.clusterDescriptorAttributeClientListID.rawValue),
            params: nil,
            queue: .main)
        return try UInt64Array(from: attributes)
    }
    
    func readAttributePartsList() async throws -> [UInt64] {
        let attributes: [[String: Any]] = try await baseDevice.readAttributes(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.descriptorID.rawValue),
            attributeID: NSNumber(value: MTRAttributeIDType.clusterDescriptorAttributePartsListID.rawValue),
            params: nil,
            queue: .main)
        return try UInt64Array(from: attributes)
    }
}

class VBBaseClusterBasicInformation: VBBaseCluster {
    func readAttributeVendorName() async throws -> String {
        let attributes: [[String: Any]] = try await baseDevice.readAttributes(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.basicInformationID.rawValue),
            attributeID: NSNumber(value: MTRAttributeIDType.clusterBasicInformationAttributeVendorNameID.rawValue),
            params: nil,
            queue: .main)
        let vendorAttribute = attributes[0]
        guard let vendorData = vendorAttribute["data"] as? NSDictionary,
              let vendorName = vendorData["value"] as? String else {
            throw VBClusterError.parseError
        }
        return vendorName
    }
}

class VBBaseClusterOnOff: VBBaseCluster {
    
    func toggle() async throws {
        let fields: NSDictionary = [
                "type" : "Structure",
                "value" : []
            ]
        try await baseDevice.invokeCommand(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.onOffID.rawValue),
            commandID: NSNumber(value: MTRCommandIDType.clusterOnOffCommandToggleID.rawValue),
            commandFields: fields,
            timedInvokeTimeout: nil,
            queue: .main)
    }
    
    func readAttributeOnOff() async throws -> NSNumber {
        let attributes: [[String: Any]] = try await baseDevice.readAttributes(
            withEndpointID: endpointID,
            clusterID: NSNumber(value: MTRClusterIDType.onOffID.rawValue),
            attributeID: NSNumber(value: MTRAttributeIDType.clusterOnOffAttributeOnOffID.rawValue),
            params: nil,
            queue: .main)
        let onOffAttribute = attributes[0]
        guard let data = onOffAttribute["data"] as? NSDictionary,
              let onOffValue = data["value"] as? Bool else {
            throw VBClusterError.parseError
        }
        return NSNumber(booleanLiteral: onOffValue)
    }
}
